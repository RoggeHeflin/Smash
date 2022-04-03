CREATE PROCEDURE [track].[Insert_BatchLogEnd]
(
	@BatchLogId			INT,
	@RowCount			INT,
	@UpdateBeg			DATETIMEOFFSET(7),
	@UpdateEnd			DATETIMEOFFSET(7),
	@SourceNotes		VARCHAR(MAX)
)
AS
BEGIN

	SET NOCOUNT ON;
	SET LOCK_TIMEOUT 100;
	SET DEADLOCK_PRIORITY HIGH;

	DECLARE @TxnCount		INT				= @@TRANCOUNT;
	DECLARE @TxnActive		VARCHAR(32)		= REPLACE(CONVERT(VARCHAR(36), NEWID(), 0), '-', '');
	DECLARE @ErrorCode		INT				= 0;

	IF (@TxnCount = 0) BEGIN TRANSACTION @TxnActive ELSE SAVE TRANSACTION @TxnActive;
	BEGIN TRY
	-----------------------------------------------------------------------------------------------

		INSERT INTO [track].[BatchLogEnd]
		(
			[BatchLogId],
			[RowCount],
			[UpdateBeg],
			[UpdateEnd],
			[SourceNotes]
		)
		SELECT
			[BatchLogId]		= @BatchLogId,
			[RowCount]			= @RowCount,
			[UpdateBeg]			= @UpdateBeg,
			[UpdateEnd]			= @UpdateEnd,
			[SourceNotes]		= @SourceNotes;

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