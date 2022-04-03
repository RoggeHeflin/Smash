CREATE PROCEDURE [track].[Select_BatchLog]
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

		DROP TABLE IF EXISTS #ReturnTable_BatchLog;

		CREATE TABLE #ReturnTable_BatchLog
		(
			[ReturnTableId]					INT					NOT	NULL	IDENTITY(1, 1)	NOT FOR REPLICATION,
			[BatchLogId]					INT					NOT	NULL,

			[DatabaseId]					SMALLINT			NOT	NULL,

			[DatabaseName]					NVARCHAR(128)		NOT	NULL,
			[SchemaName]					NVARCHAR(128)		NOT	NULL,
			[TableName]						NVARCHAR(128)		NOT	NULL,
			[SourceData]					NVARCHAR(128)		NOT	NULL,

			[ApplicationUserOriginal]		NVARCHAR(128)		NOT	NULL,
			[ApplicationUserExecute]		NVARCHAR(128)		NOT	NULL,
			[ApplicationHost]				NVARCHAR(128)		NOT	NULL,
			[ApplicationApp]				NVARCHAR(128)		NOT	NULL,

			[RowCount]						INT						NULL,
			[UpdateDateBeg]					DATETIMEOFFSET(7)		NULL,
			[UpdateDateEnd]					DATETIMEOFFSET(7)		NULL,
			[SourceNotes]					VARCHAR(MAX)			NULL,

			[Duration]						VARCHAR(20)				NULL,

			[DurationDays]					FLOAT					NULL,
			[DurationMinutes]				FLOAT					NULL,
			[DurationSeconds]				FLOAT					NULL,

			CONSTRAINT	[PK_#ReturnTable_BatchLog]	PRIMARY KEY CLUSTERED([ReturnTableId]	ASC)
		);

		DECLARE	@SqlBase		VARCHAR(MAX)	= N'
		IF (OBJECT_ID(''[$(DatabaseName)].[track].[BatchLog]'') IS NOT NULL)
		BEGIN

			INSERT INTO #ReturnTable_BatchLog	WITH(TABLOCK)
			(
				[BatchLogId],

				[DatabaseId],

				[DatabaseName],
				[SchemaName],
				[TableName],
				[SourceData],

				[ApplicationUserOriginal],
				[ApplicationUserExecute],
				[ApplicationHost],
				[ApplicationApp],

				[RowCount],
				[UpdateDateBeg],
				[UpdateDateEnd],
				[SourceNotes],

				[Duration],

				[DurationDays],
				[DurationMinutes],
				[DurationSeconds]
			)
			SELECT
				[t].[BatchLogId],

				[t].[DatabaseId],

				[t].[DatabaseName],
				[t].[SchemaName],
				[t].[TableName],
				[t].[SourceData],

				[t].[ApplicationUserOriginal],
				[t].[ApplicationUserExecute],
				[t].[ApplicationHost],
				[t].[ApplicationApp],

				[t].[RowCount],
				[t].[UpdateDateBeg],
				[t].[UpdateDateEnd],
				[t].[SourceNotes],

				[t].[Duration],

				[t].[DurationDays],
				[t].[DurationMinutes],
				[t].[DurationSeconds]
			FROM
				[$(DatabaseName)].[track].[BatchLog]	[t];

		END;';

		DECLARE @DbName			NVARCHAR(128)	= N'';
		DECLARE @SqlCommand		NVARCHAR(MAX);

		WHILE (@DbName IS NOT NULL)
		BEGIN

			SELECT
				@DbName = MIN([d].[name])
			FROM
				sys.databases	[d]
			WHERE
					([d].[database_id] > 4)
				AND	([d].[name] NOT IN (N'master', N'model', N'msdb', N'tempdb', N'DWConfiguration', N'DWDiagnostics', N'DWQueue', N'SSISDB', N'SSRS', N'SSRSTempDB'))
				AND	([d].[name]	> @DbName);

			SET @SqlCommand = REPLACE(@SqlBase, N'$(DatabaseName)', @DbName);

			PRINT CONVERT(NCHAR(23), SYSDATETIME(), 121) + NCHAR(9) + N'Querying database [' + @DbName + N']';

			EXECUTE sp_executesql @SqlCommand;

		END;

		SELECT
			[t].[ReturnTableId],
			[t].[BatchLogId],

			[t].[DatabaseId],
			[t].[DatabaseName],
			[t].[SchemaName],
			[t].[TableName],
			[t].[SourceData],

			[t].[ApplicationUserOriginal],
			[t].[ApplicationUserExecute],
			[t].[ApplicationHost],
			[t].[ApplicationApp],

			[t].[RowCount],

				[TimezoneOffsetHours]	= DATEPART(TZ, [t].[UpdateDateBeg]) / 60.0,

				[UpdateDateBeg]			= CONVERT(DATETIME2, [t].[UpdateDateBeg]),
				[UpdateDateEnd]			= CONVERT(DATETIME2, [t].[UpdateDateEnd]),

			[t].[SourceNotes],

			[t].[Duration],

			[t].[DurationDays],
			[t].[DurationMinutes],
			[t].[DurationSeconds]
		FROM
			#ReturnTable_BatchLog	[t];

		DROP TABLE IF EXISTS #ReturnTable_BatchLog;

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