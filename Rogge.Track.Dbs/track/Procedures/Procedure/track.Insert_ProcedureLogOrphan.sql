CREATE PROCEDURE [track].[Insert_ProcedureLogOrphan]
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

		INSERT INTO [track].[ProcedureLogOrphans]
		(
			[ProcedureLogId]
		)
		SELECT
			[b].[ProcedureLogId]
		FROM
			[track].[ProcedureLogBegin]			[b]	WITH (NOLOCK)
		LEFT OUTER JOIN
			[track].[ProcedureLogEnd]			[e]	WITH (NOLOCK)
				ON	([b].[ProcedureLogId]	=	[e].[ProcedureLogId])
		LEFT OUTER JOIN
			[track].[ProcedureLogErrors]		[r]	WITH (NOLOCK)
				ON	([b].[ProcedureLogId]	=	[r].[ProcedureLogId])
		LEFT OUTER JOIN
			[track].[ProcedureLogOrphans]		[o]	WITH (NOLOCK)
				ON	([b].[ProcedureLogId]	=	[o].[ProcedureLogId])
		WHERE
				([e].[ProcedureLogId]	IS NULL)
			AND	([r].[ProcedureLogId]	IS NULL)
			AND	([o].[ProcedureLogId]	IS NULL)
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