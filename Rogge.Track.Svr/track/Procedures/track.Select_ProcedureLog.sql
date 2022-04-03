CREATE PROCEDURE [track].[Select_ProcedureLog]
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

		DROP TABLE IF EXISTS #ReturnTable_ProcedureLog;

		CREATE TABLE #ReturnTable_ProcedureLog
		(
			[ReturnTableId]					INT					NOT	NULL	IDENTITY(1, 1) NOT FOR REPLICATION,

			[ProcedureLogId]				INT					NOT	NULL,

			[database_id]					SMALLINT			NOT	NULL,
			[schema_id]						INT					NOT	NULL,
			[object_id]						INT					NOT	NULL,

			[ServerName]					NVARCHAR(128)		NOT	NULL,
			[DatabaseName]					NVARCHAR(128)		NOT	NULL,
			[SchemaName]					NVARCHAR(128)		NOT	NULL,
			[ObjectName]					NVARCHAR(128)		NOT	NULL,
			[QualifiedName]					NVARCHAR(261)		NOT	NULL,

			[SPID]							SMALLINT			NOT	NULL,
			[NestLevel]						INT					NOT	NULL,
			[TransactionCount]				INT					NOT	NULL,

			[ProcedureUserOriginal]			NVARCHAR(128)		NOT	NULL,
			[ProcedureUserExecute]			NVARCHAR(128)		NOT	NULL,
			[ProcedureHost]					NVARCHAR(128)		NOT	NULL,
			[ProcedureApplication]			NVARCHAR(128)		NOT	NULL,

			[ProcedureStatus]				VARCHAR(24)			NOT	NULL,

			[ProcedureBegin]				DATETIME2			NOT	NULL,
			[ProcedureBeginDate]			DATE				NOT	NULL,
			[ProcedureBeginTime]			TIME				NOT	NULL,
			[ProcedureBeginZone]			DATETIMEOFFSET(7)	NOT	NULL,

			[ProcedureEnd]					DATETIME2				NULL,
			[ProcedureEndDate]				DATE					NULL,
			[ProcedureEndTime]				TIME					NULL,
			[ProcedureEndZone]				DATETIMEOFFSET(7)		NULL,

			[ProcedureError]				DATETIME2				NULL,
			[ProcedureErrorDate]			DATE					NULL,
			[ProcedureErrorTime]			TIME					NULL,
			[ProcedureErrorZone]			DATETIMEOFFSET(7)		NULL,

			[ProcedureOrphaned]				DATETIME2				NULL,
			[ProcedureOrphanedDate]			DATE					NULL,
			[ProcedureOrphanedTime]			TIME					NULL,
			[ProcedureOrphanedZone]			DATETIMEOFFSET(7)		NULL,

			[Duration]						VARCHAR(20)				NULL,

			[DurationDays]					FLOAT					NULL,
			[DurationMinutes]				FLOAT					NULL,
			[DurationSeconds]				FLOAT					NULL,

			[ErrorNumber]					INT						NULL,
			[ErrorSeverity]					INT						NULL,
			[ErrorState]					INT						NULL,
			[ErrorProcedure]				NVARCHAR(128)			NULL,
			[ErrorLine]						INT						NULL,
			[ErrorMessage]					NVARCHAR(MAX)			NULL,

			[IsWrapper]						BIT						NULL,
			[IsDelete]						BIT						NULL,

			PRIMARY KEY CLUSTERED([ReturnTableId]	ASC)
		);

		DECLARE	@SqlBase		NVARCHAR(MAX)	= N'
		IF (OBJECT_ID(''[$(DatabaseName)].[track].[ProcedureLog]'') IS NOT NULL)
		BEGIN

			INSERT INTO #ReturnTable_ProcedureLog	WITH(TABLOCK)
			(
				[ProcedureLogId],

				[database_id],
				[schema_id],
				[object_id],

				[ServerName],
				[DatabaseName],
				[SchemaName],
				[ObjectName],
				[QualifiedName],

				[SPID],
				[NestLevel],
				[TransactionCount],

				[ProcedureUserOriginal],
				[ProcedureUserExecute],
				[ProcedureHost],
				[ProcedureApplication],

				[ProcedureStatus],

				[ProcedureBegin],
				[ProcedureBeginDate],
				[ProcedureBeginTime],
				[ProcedureBeginZone],

				[ProcedureEnd],
				[ProcedureEndDate],
				[ProcedureEndTime],
				[ProcedureEndZone],

				[ProcedureError],
				[ProcedureErrorDate],
				[ProcedureErrorTime],
				[ProcedureErrorZone],

				[ProcedureOrphaned],
				[ProcedureOrphanedDate],
				[ProcedureOrphanedTime],
				[ProcedureOrphanedZone],

				[Duration],

				[DurationDays],
				[DurationMinutes],
				[DurationSeconds],

				[ErrorNumber],
				[ErrorSeverity],
				[ErrorState],
				[ErrorProcedure],
				[ErrorLine],
				[ErrorMessage],

				[IsWrapper],
				[IsDelete]
			)
			SELECT
				[t].[ProcedureLogId],

				[t].[database_id],
				[t].[schema_id],
				[t].[object_id],

				[t].[ServerName],
				[t].[DatabaseName],
				[t].[SchemaName],
				[t].[ObjectName],
				[t].[QualifiedName],

				[t].[SPID],
				[t].[NestLevel],
				[t].[TransactionCount],

				[t].[ProcedureUserOriginal],
				[t].[ProcedureUserExecute],
				[t].[ProcedureHost],
				[t].[ProcedureApplication],

				[t].[ProcedureStatus],

				[t].[ProcedureBegin],
				[t].[ProcedureBeginDate],
				[t].[ProcedureBeginTime],
				[t].[ProcedureBeginZone],

				[t].[ProcedureEnd],
				[t].[ProcedureEndDate],
				[t].[ProcedureEndTime],
				[t].[ProcedureEndZone],

				[t].[ProcedureError],
				[t].[ProcedureErrorDate],
				[t].[ProcedureErrorTime],
				[t].[ProcedureErrorZone],

				[t].[ProcedureOrphaned],
				[t].[ProcedureOrphanedDate],
				[t].[ProcedureOrphanedTime],
				[t].[ProcedureOrphanedZone],

				[t].[Duration],

				[t].[DurationDays],
				[t].[DurationMinutes],
				[t].[DurationSeconds],

				[t].[ErrorNumber],
				[t].[ErrorSeverity],
				[t].[ErrorState],
				[t].[ErrorProcedure],
				[t].[ErrorLine],
				[t].[ErrorMessage],

				[t].[IsWrapper],
				[t].[IsDelete]
			FROM
				[$(DatabaseName)].[track].[ProcedureLog]	[t];

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
			[t].[ProcedureLogId],

			[t].[database_id],
			[t].[schema_id],
			[t].[object_id],

			[t].[ServerName],
			[t].[DatabaseName],
			[t].[SchemaName],
			[t].[ObjectName],
			[t].[QualifiedName],

			[t].[SPID],
			[t].[NestLevel],
			[t].[TransactionCount],

			[t].[ProcedureUserOriginal],
			[t].[ProcedureUserExecute],
			[t].[ProcedureHost],
			[t].[ProcedureApplication],

			[t].[ProcedureStatus],

			[t].[ProcedureBegin],
			[t].[ProcedureBeginDate],
			[t].[ProcedureBeginTime],
			[t].[ProcedureBeginZone],

			[t].[ProcedureEnd],
			[t].[ProcedureEndDate],
			[t].[ProcedureEndTime],
			[t].[ProcedureEndZone],

			[t].[ProcedureError],
			[t].[ProcedureErrorDate],
			[t].[ProcedureErrorTime],
			[t].[ProcedureErrorZone],

			[t].[ProcedureOrphaned],
			[t].[ProcedureOrphanedDate],
			[t].[ProcedureOrphanedTime],
			[t].[ProcedureOrphanedZone],

			[t].[Duration],

			[t].[DurationDays],
			[t].[DurationMinutes],
			[t].[DurationSeconds],

			[t].[ErrorNumber],
			[t].[ErrorSeverity],
			[t].[ErrorState],
			[t].[ErrorProcedure],
			[t].[ErrorLine],
			[t].[ErrorMessage],

			[t].[IsWrapper],
			[t].[IsDelete]
		FROM
			#ReturnTable_ProcedureLog	[t] WITH (NOLOCK);

		DROP TABLE IF EXISTS #ReturnTable_ProcedureLog;

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