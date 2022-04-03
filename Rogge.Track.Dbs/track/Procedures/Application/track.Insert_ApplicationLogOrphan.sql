CREATE PROCEDURE [track].[Insert_ApplicationLogOrphan]
AS
BEGIN

	SET NOCOUNT ON;
	SET LOCK_TIMEOUT 100;
	SET DEADLOCK_PRIORITY HIGH;

	DECLARE @TxnCount		INT				= @@TRANCOUNT;
	DECLARE @TxnActive		VARCHAR(32)		= REPLACE(CONVERT(VARCHAR(36), NEWID(), 0), '-', '');
	DECLARE @ErrorCode		INT				= 0;

	DECLARE @TrackingLogId	INT;
	EXECUTE @TrackingLogId	= [track].[Insert_ProcedureLogBegin] @@PROCID;

	IF (@TxnCount = 0) BEGIN TRANSACTION @TxnActive ELSE SAVE TRANSACTION @TxnActive;
	BEGIN TRY
	-----------------------------------------------------------------------------------------------

		INSERT INTO [track].[ApplicationLogOrphans]
		(
			[ApplicationLogId]
		)
		SELECT
			[b].[ApplicationLogId]
		FROM
			[track].[ApplicationLogBegin]		[b]	WITH (NOLOCK)
		LEFT OUTER JOIN
			[track].[ApplicationLogEnd]			[e]	WITH (NOLOCK)
				ON	([b].[ApplicationLogId]	=	[e].[ApplicationLogId])
		LEFT OUTER JOIN
			[track].[ApplicationLogErrors]		[r]	WITH (NOLOCK)
				ON	([b].[ApplicationLogId]	=	[r].[ApplicationLogId])
		LEFT OUTER JOIN
			[track].[ApplicationLogOrphans]		[o]	WITH (NOLOCK)
				ON	([b].[ApplicationLogId]	=	[o].[ApplicationLogId])
		WHERE
				([e].[ApplicationLogId]	IS NULL)
			AND	([r].[ApplicationLogId]	IS NULL)
			AND	([o].[ApplicationLogId]	IS NULL)
			AND	([b].[txInserted]		<	GETDATE());

	-----------------------------------------------------------------------------------------------
	IF (@TxnCount = 0) COMMIT TRANSACTION @TxnActive ELSE SAVE TRANSACTION @TxnActive;
	END TRY
	BEGIN CATCH

		SET @ErrorCode = @@ERROR;

		IF (XACT_STATE() = -1) ROLLBACK	TRANSACTION	@TxnActive;
		IF (XACT_STATE() =  1) COMMIT	TRANSACTION	@TxnActive;

		EXECUTE [track].[Insert_ProcedureLogError] @TrackingLogId;

		THROW;

		RETURN @ErrorCode;

	END CATCH;

	EXECUTE [track].[Insert_ProcedureLogEnd] @TrackingLogId;

	RETURN @ErrorCode;

END;