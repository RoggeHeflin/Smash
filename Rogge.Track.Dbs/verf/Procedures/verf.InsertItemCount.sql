﻿CREATE PROCEDURE [verf].[InsertItemCount]
(
	@CheckDate		DATETIME	= NULL
)
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

		SET	@CheckDate	= COALESCE(@CheckDate, SYSDATETIME());

		INSERT INTO [verf].[ItemCount]
		(
			[ServerName],
			[DatabaseName],
			[SchemaName],
			[TableName],
			[DescriptionName],
			[CheckDate],
			[Items]
		)
		SELECT
			[ServerName]		= @@SERVERNAME,
			[DatabaseName]		= DB_NAME(),
			[SchemaName]		= 'stg',
			[TableName]			= 'sample',
			[DescriptionName]	= 'sample table insert',
			[CheckDate]			= @CheckDate,
			[Items]				= 1;

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