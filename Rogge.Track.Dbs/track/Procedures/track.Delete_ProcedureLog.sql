CREATE PROCEDURE [track].[Delete_ProcedureLog]
(
	@proc_id				INT
)
AS
BEGIN

	SET NOCOUNT ON;
	SET LOCK_TIMEOUT 100;
	SET DEADLOCK_PRIORITY HIGH;

	DECLARE @TxnCount		INT				= @@TRANCOUNT;
	DECLARE @TxnActive		VARCHAR(32)		= REPLACE(CONVERT(VARCHAR(36), NEWID(), 0), '-', '');
	DECLARE @TxnId			NUMERIC(18, 0)	= NULL;

	IF (@TxnCount = 0) BEGIN TRANSACTION @TxnActive ELSE SAVE TRANSACTION @TxnActive;
	BEGIN TRY
	-----------------------------------------------------------------------------------------------

	DELETE FROM	[track].[ProcedureLogOrphans]	WHERE (1=0);
	DELETE FROM	[track].[ProcedureLogErrors]	WHERE (1=0);
	DELETE FROM	[track].[ProcedureLogEnd]		WHERE (1=0);
	DELETE FROM	[track].[ProcedureLogBegin]		WHERE (1=0);

	-----------------------------------------------------------------------------------------------
	IF (@TxnCount = 0) COMMIT TRANSACTION @TxnActive ELSE SAVE TRANSACTION @TxnActive;
	END TRY
	BEGIN CATCH

		IF (XACT_STATE() = -1) ROLLBACK	TRANSACTION	@TxnActive;
		IF (XACT_STATE() =  1) COMMIT	TRANSACTION	@TxnActive;

		THROW;

	END CATCH;

	RETURN @TxnId;

END;