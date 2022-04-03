CREATE PROCEDURE [track].[Insert_ProcedureLogBegin]
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

		PRINT CONVERT(NCHAR(23), SYSDATETIME(), 121) + NCHAR(9) + QUOTENAME(OBJECT_SCHEMA_NAME(@proc_id)) + N'.' + QUOTENAME(OBJECT_NAME(@proc_id));

		INSERT INTO [track].[ProcedureLogBegin]
		(
			[schema_id],
			[object_id],
			[SchemaName],
			[ObjectName],
			[SPID],
			[NestLevel],
			[TransactionCount]
		)
		SELECT
			[schema_id]			= SCHEMA_ID(OBJECT_SCHEMA_NAME(@proc_id)),
			[object_id]			= @proc_id,
			[SchemaName]		= OBJECT_SCHEMA_NAME(@proc_id),
			[ObjectName]		= OBJECT_NAME(@proc_id),
			[SPID]				= @@SPID,
			[NestLevel]			= @@NESTLEVEL - 1,
			[TransactionCount]	= @@TRANCOUNT - 1;

		SET	@TxnId	= SCOPE_IDENTITY();

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