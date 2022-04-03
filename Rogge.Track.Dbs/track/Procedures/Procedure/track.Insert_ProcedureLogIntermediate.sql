CREATE PROCEDURE [track].[Insert_ProcedureLogIntermediate]
(
	@ObjectId				INT,
	@ProcedureLogId			INT,
	@ProcedureLineId		INT,
	@ProcedureMessage		VARCHAR(256)
)
AS
BEGIN

	SET NOCOUNT ON;
	SET LOCK_TIMEOUT 100;
	SET DEADLOCK_PRIORITY HIGH;

	DECLARE @TxnCount		INT				= @@TRANCOUNT;
	DECLARE @TxnActive		VARCHAR(32)		= REPLACE(CONVERT(VARCHAR(36), NEWID(), 0), '-', '');
	DECLARE @ErrorCode		INT				= 0;

	BEGIN TRY
	IF (@TxnCount = 0) BEGIN TRANSACTION @TxnActive ELSE SAVE TRANSACTION @TxnActive;
	-----------------------------------------------------------------------------------------------

		PRINT CONVERT(NCHAR(23), SYSDATETIME(), 121) + NCHAR(9) + QUOTENAME(OBJECT_SCHEMA_NAME(@ObjectId)) + N'.' + QUOTENAME(OBJECT_NAME(@ObjectId)) + NCHAR(9) + CONVERT(NVARCHAR, @ProcedureLineId) + NCHAR(9) + @ProcedureMessage;

		INSERT INTO [track].[ProcedureLogIntermediate]
		(
			[ProcedureLogId],
			[ProcedureLineNumber],
			[ProcedureMessage]
		)
		SELECT
			[ProcedureLogId]	= @ProcedureLogId,
			[ProcedureLineId]	= @ProcedureLineId,
			[ProcedureMessage]	= @ProcedureMessage;

	-----------------------------------------------------------------------------------------------
	IF (@TxnCount = 0) COMMIT TRANSACTION @TxnActive ELSE SAVE TRANSACTION @TxnActive;
	END TRY
	BEGIN CATCH

		SET @ErrorCode = @@ERROR;

		IF (XACT_STATE() = -1) ROLLBACK	TRANSACTION	@TxnActive;
		IF (XACT_STATE() =  1) COMMIT	TRANSACTION	@TxnActive;

		THROW;
		
		RETURN @ErrorCode;

	END CATCH;

	RETURN @ErrorCode;

END;