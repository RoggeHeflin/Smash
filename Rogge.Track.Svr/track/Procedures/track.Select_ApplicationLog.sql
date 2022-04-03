CREATE PROCEDURE [track].[Select_ApplicationLog]
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

		DROP TABLE IF EXISTS #ReturnTable_ApplicationLog;

		CREATE TABLE #ReturnTable_ApplicationLog
		(
			[ReturnTableId]					INT					NOT	NULL	IDENTITY(1, 1)	NOT FOR REPLICATION,
			[ApplicationLogId]				INT					NOT	NULL,

			[DatabaseId]					SMALLINT			NOT	NULL,
			[DatabaseName]					NVARCHAR(128)		NOT	NULL,

			[ClassName]						VARCHAR(128)		NOT	NULL,
			[FunctionName]					VARCHAR(128)		NOT	NULL,

			[ApplicationVersion]			VARCHAR(128)		NOT	NULL,
			[ApplicationPlatform]			VARCHAR(128)		NOT	NULL,

			[ApplicationUserOriginal]		NVARCHAR(128)		NOT	NULL,
			[ApplicationUserExecute]		NVARCHAR(128)		NOT	NULL,
			[ApplicationHost]				NVARCHAR(128)		NOT	NULL,
			[ApplicationApp]				NVARCHAR(128)		NOT	NULL,

			[ApplicationBegin]				DATETIMEOFFSET(7)	NOT	NULL,
			[ApplicationEnd]				DATETIMEOFFSET(7)		NULL,
			[ApplicationError]				DATETIMEOFFSET(7)		NULL,
			[ApplicationTerminate]			DATETIMEOFFSET(7)		NULL,

			[Duration]						VARCHAR(20)				NULL,

			[DurationDays]					FLOAT					NULL,
			[DurationMinutes]				FLOAT					NULL,
			[DurationSeconds]				FLOAT					NULL,

			[ErrorMessage]					NVARCHAR(MAX)			NULL,

			CONSTRAINT	[PK_#ReturnTable_ApplicationLog]	PRIMARY KEY CLUSTERED([ReturnTableId]	ASC)
		);

		DECLARE	@SqlBase		NVARCHAR(MAX)	= N'
		IF (OBJECT_ID(''[$(DatabaseName)].[track].[ApplicationLog]'') IS NOT NULL)
		BEGIN

			INSERT INTO #ReturnTable_ApplicationLog	WITH(TABLOCK)
			(
				[ApplicationLogId],

				[DatabaseId],
				[DatabaseName],

				[ClassName],
				[FunctionName],

				[ApplicationVersion],
				[ApplicationPlatform],

				[ApplicationUserOriginal],
				[ApplicationUserExecute],
				[ApplicationHost],
				[ApplicationApp],

				[ApplicationBegin],
				[ApplicationEnd],
				[ApplicationError],
				[ApplicationTerminate],

				[Duration],

				[DurationDays],
				[DurationMinutes],
				[DurationSeconds],

				[ErrorMessage]
			)
			SELECT
				[t].[ApplicationLogId],

				[t].[DatabaseId],
				[t].[DatabaseName],

				[t].[ClassName],
				[t].[FunctionName],

				[t].[ApplicationVersion],
				[t].[ApplicationPlatform],

				[t].[ApplicationUserOriginal],
				[t].[ApplicationUserExecute],
				[t].[ApplicationHost],
				[t].[ApplicationApp],

				[t].[ApplicationBegin],
				[t].[ApplicationEnd],
				[t].[ApplicationError],
				[t].[ApplicationTerminate],

				[t].[Duration],

				[t].[DurationDays],
				[t].[DurationMinutes],
				[t].[DurationSeconds],

				[t].[ErrorMessage]
			FROM
				[$(DatabaseName)].[track].[ApplicationLog]	[t];

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
			[t].[ApplicationLogId],

			[t].[DatabaseId],
			[t].[DatabaseName],

			[t].[ClassName],
			[t].[FunctionName],

			[t].[ApplicationVersion],
			[t].[ApplicationPlatform],

			[t].[ApplicationUserOriginal],
			[t].[ApplicationUserExecute],
			[t].[ApplicationHost],
			[t].[ApplicationApp],

				[TimezoneOffsetHours]	= DATEPART(TZ, [t].[ApplicationBegin]) / 60.0,

				[ApplicationBegin]		= CONVERT(DATETIME2, [t].[ApplicationBegin]),
				[ApplicationEnd]		= CONVERT(DATETIME2, [t].[ApplicationEnd]),
				[ApplicationError]		= CONVERT(DATETIME2, [t].[ApplicationError]),
				[ApplicationTerminate]	= CONVERT(DATETIME2, [t].[ApplicationTerminate]),

			[t].[Duration],

			[t].[DurationDays],
			[t].[DurationMinutes],
			[t].[DurationSeconds],

			[t].[ErrorMessage]
		FROM
			#ReturnTable_ApplicationLog	[t];

		DROP TABLE IF EXISTS #ReturnTable_ApplicationLog;

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