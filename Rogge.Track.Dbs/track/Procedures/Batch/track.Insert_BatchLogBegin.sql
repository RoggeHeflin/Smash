CREATE PROCEDURE [track].[Insert_BatchLogBegin]
(
	@SchemaName		NVARCHAR(128),
	@TableName		NVARCHAR(128),
	@SourceData		NVARCHAR(128)
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

		INSERT INTO [track].[BatchLogBegin]
		(
			[SchemaName],
			[TableName],
			[SourceData]
		)
		SELECT
			[SchemaName]	= @SchemaName,
			[TableName]		= @TableName,
			[SourceData]	= @SourceData;

		SET	@TxnId	= SCOPE_IDENTITY();

	---------------------------------------------------------------------------------------------
	IF (@TxnCount = 0) COMMIT TRANSACTION @TxnActive ELSE SAVE TRANSACTION @TxnActive;
	END TRY
	BEGIN CATCH

		IF (XACT_STATE() = -1) ROLLBACK	TRANSACTION	@TxnActive;
		IF (XACT_STATE() =  1) COMMIT	TRANSACTION	@TxnActive;

		THROW;

	END CATCH;

	SELECT [TxnId] = @TxnId;
	RETURN @TxnId;

END;