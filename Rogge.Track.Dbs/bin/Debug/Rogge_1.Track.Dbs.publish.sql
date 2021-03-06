/*
Deployment script for AdventureWorks2019

This code was generated by a tool.
Changes to this file may cause incorrect behavior and will be lost if
the code is regenerated.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "AdventureWorks2019"
:setvar DefaultFilePrefix "AdventureWorks2019"
:setvar DefaultDataPath "D:\Data SQL Server\Data\"
:setvar DefaultLogPath "D:\Data SQL Server\Log\"

GO
:on error exit
GO
/*
Detect SQLCMD mode and disable script execution if SQLCMD mode is not supported.
To re-enable the script after enabling SQLCMD mode, execute the following:
SET NOEXEC OFF; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'SQLCMD mode must be enabled to successfully execute this script.';
        SET NOEXEC ON;
    END


GO
USE [$(DatabaseName)];


GO
PRINT N'Creating View [track].[ProcedureLog]...';


GO
CREATE VIEW [track].[ProcedureLog]
WITH VIEW_METADATA
AS
SELECT
	[b].[ProcedureLogId],

		[database_id]				= DB_ID(),
	[b].[schema_id],
	[b].[object_id],

		[ServerName]				= @@SERVERNAME,
		[DatabaseName]				= DB_NAME(),
	[b].[SchemaName],
	[b].[ObjectName],
	[b].[QualifiedName],

	[b].[SPID],
	[b].[NestLevel],
	[b].[TransactionCount],

		[ProcedureUserOriginal]		= [b].[txInsertedUserOriginal],
		[ProcedureUserExecute]		= [b].[txInsertedUserExecute],
		[ProcedureHost]				= [b].[txInsertedHost],
		[ProcedureApplication]		= [b].[txInsertedApplication],

		[ProcedureStatus]			= CASE
										WHEN ([e].[txInserted]	IS NOT NULL)	THEN 'Succeeded'
										WHEN ([r].[txInserted]	IS NOT NULL)	THEN 'Failed'
										WHEN ([o].[txInserted]	IS NOT NULL)	THEN 'Ended Unexpectedly'
										ELSE 'Running'
										END,

		[ProcedureBeg]				= CONVERT(DATETIME2,	[b].[txInserted]),
		[ProcedureBegDate]			= CONVERT(DATE,			[b].[txInserted]),
		[ProcedureBegTime]			= CONVERT(TIME,			[b].[txInserted]),
		[ProcedureBegZone]			= [b].[txInserted],

		[ProcedureEnd]				= CONVERT(DATETIME2,	[e].[txInserted]),
		[ProcedureEndDate]			= CONVERT(DATE,			[e].[txInserted]),
		[ProcedureEndTime]			= CONVERT(TIME,			[e].[txInserted]),
		[ProcedureEndZone]			= [e].[txInserted],

		[ProcedureError]			= CONVERT(DATETIME2,	[r].[txInserted]),
		[ProcedureErrorDate]		= CONVERT(DATE,			[r].[txInserted]),
		[ProcedureErrorTime]		= CONVERT(TIME,			[r].[txInserted]),
		[ProcedureErrorZone]		= [r].[txInserted],

		[ProcedureOrphaned]			= CONVERT(DATETIME2,	[o].[txInserted]),
		[ProcedureOrphanedDate]		= CONVERT(DATE,			[o].[txInserted]),
		[ProcedureOrphanedTime]		= CONVERT(TIME,			[o].[txInserted]),
		[ProcedureOrphanedZone]		= [o].[txInserted],

		[Duration]					= STUFF(CONVERT(VARCHAR(20),	CONVERT(DATETIME, COALESCE([e].[txInserted], [r].[txInserted]))
											- CONVERT(DATETIME, [b].[txInserted]), 114), 1, 2,
											DATEDIFF(HOUR, 0,		CONVERT(DATETIME, COALESCE([e].[txInserted], [r].[txInserted]))
											- CONVERT(DATETIME, [b].[txInserted]))),

		[DurationDays]				= DATEDIFF(SECOND, [b].[txInserted], COALESCE([e].[txInserted], [r].[txInserted], IIF([o].[txInserted] IS NULL, SYSDATETIMEOFFSET(), NULL))) / 86400.0,
		[DurationMinutes]			= DATEDIFF(SECOND, [b].[txInserted], COALESCE([e].[txInserted], [r].[txInserted], IIF([o].[txInserted] IS NULL, SYSDATETIMEOFFSET(), NULL))) / 60.0,
		[DurationSeconds]			= DATEDIFF(SECOND, [b].[txInserted], COALESCE([e].[txInserted], [r].[txInserted], IIF([o].[txInserted] IS NULL, SYSDATETIMEOFFSET(), NULL))),

	[r].[ErrorNumber],
	[r].[ErrorSeverity],
	[r].[ErrorState],
	[r].[ErrorProcedure],
	[r].[ErrorLine],
	[r].[ErrorMessage],

		[IsWrapper]					= CONVERT(BIT, COALESCE([a].[IsWrapper], 0)),
		[IsDelete]					= CONVERT(BIT, COALESCE([a].[IsDelete], 0))

FROM
	[track].[ProcedureLogBegin]			[b]
LEFT OUTER JOIN
	[track].[ProcedureLogEnd]			[e]
		ON	([b].[ProcedureLogId]	=	[e].[ProcedureLogId])
LEFT OUTER JOIN
	[track].[ProcedureLogErrors]		[r]
		ON	([b].[ProcedureLogId]	=	[r].[ProcedureLogId])
LEFT OUTER JOIN
	[track].[ProcedureLogOrphans]		[o]
		ON	([b].[ProcedureLogId]	=	[o].[ProcedureLogId])
LEFT OUTER JOIN
	[track].[ProcedureAttributes](3)	[a]
		ON	([b].[object_id]		=	[a].[object_id]);
GO
PRINT N'Creating Procedure [dbo].[sp_ssis_addlogentry]...';


GO
CREATE PROCEDURE [dbo].[sp_ssis_addlogentry]
(
	@event			SYSNAME,
	@computer		NVARCHAR(128),
	@operator		NVARCHAR(128),
	@source			NVARCHAR(1024),
	@sourceid		UNIQUEIDENTIFIER,
	@executionid	UNIQUEIDENTIFIER,
	@starttime		DATETIME2,
	@endtime		DATETIME2,
	@datacode		INT,
	@databytes		IMAGE,
	@message		NVARCHAR(2048)
)
AS
BEGIN

	SET NOCOUNT ON;
	SET LOCK_TIMEOUT 1000;
	SET DEADLOCK_PRIORITY HIGH;

	DECLARE @TxnCount		INT				= @@TRANCOUNT;
	DECLARE @TxnActive		VARCHAR(32)		= REPLACE(CONVERT(VARCHAR(36), NEWID(), 0), '-', '');
	DECLARE @ErrorCode		INT				= 0;

	IF (@TxnCount = 0) BEGIN TRANSACTION @TxnActive ELSE SAVE TRANSACTION @TxnActive;
	BEGIN TRY
	-----------------------------------------------------------------------------------------------

		INSERT INTO [track].[SsisLogDetail]
		(
			[Event],
			[Computer],
			[Operator],
			[Source],
			[SourceId],
			[ExecutionId],
			[EventBeg],
			[EventEnd],
			[DataCode],
			[DataBytes],
			[Message]
		)
		VALUES
		(
			@event,
			@computer,
			@operator,
			@source,
			@sourceid,
			@executionid,
			@starttime,
			@endtime,
			@datacode,
			@databytes,
			@message
		);

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
GO
PRINT N'Creating Procedure [track].[Insert_ApplicationLogBegin]...';


GO
CREATE PROCEDURE [track].[Insert_ApplicationLogBegin]
(
	@ApplicationName		NVARCHAR(128),
	@ClassName				VARCHAR(128),
	@FunctionName			VARCHAR(128),
	@ApplicationVersion		VARCHAR(128),
	@ApplicationPlatform	VARCHAR(128)
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

		INSERT INTO [track].[ApplicationLogBegin]
		(
			[txInsertedApplication],
			[ClassName],
			[FunctionName],
			[ApplicationVersion],
			[ApplicationPlatform]
		)
		SELECT
			[txInsertedApplication]	= @ApplicationName,
			[ClassName]				= @ClassName,
			[FunctionName]			= @FunctionName,
			[ApplicationVersion]	= @ApplicationVersion,
			[ApplicationPlatform]	= @ApplicationPlatform;

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
GO
PRINT N'Creating Procedure [track].[Insert_ApplicationLogEnd]...';


GO
CREATE PROCEDURE [track].[Insert_ApplicationLogEnd]
(
	@ApplicationLogId		INT
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

		INSERT INTO [track].[ApplicationLogEnd]
		(
			[ApplicationLogId]
		)
		SELECT
			[ApplicationLogId] = @ApplicationLogId;

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
GO
PRINT N'Creating Procedure [track].[Insert_ApplicationLogError]...';


GO
CREATE PROCEDURE [track].[Insert_ApplicationLogError]
(
	@ApplicationLogId	INT,
	@ErrorMessage		VARCHAR(MAX)
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

		INSERT INTO [track].[ApplicationLogErrors]
		(
			[ApplicationLogId],
			[ErrorMessage]
		)
		SELECT
			[ApplicationLogId]	= @ApplicationLogId,
			[ErrorMessage]		= RTRIM(LTRIM(LEFT(@ErrorMessage, 4096)));

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
GO
PRINT N'Creating Procedure [track].[Insert_BatchLogBegin]...';


GO
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
GO
PRINT N'Creating Procedure [track].[Insert_BatchLogEnd]...';


GO
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
GO
PRINT N'Creating Procedure [track].[Insert_ProcedureLogBegin]...';


GO
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
GO
PRINT N'Creating Procedure [track].[Insert_ProcedureLogEnd]...';


GO
CREATE PROCEDURE [track].[Insert_ProcedureLogEnd]
(
	@ProcedureLogId		INT
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

		INSERT INTO [track].[ProcedureLogEnd]
		(
			[ProcedureLogId]
		)
		SELECT
			[ProcedureLogId] = @ProcedureLogId;

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
GO
PRINT N'Creating Procedure [track].[Insert_ProcedureLogError]...';


GO
CREATE PROCEDURE [track].[Insert_ProcedureLogError]
(
	@ProcedureLogId		INT
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

		INSERT INTO [track].[ProcedureLogErrors]
		(
			[ProcedureLogId],
			[ErrorNumber],
			[ErrorSeverity],
			[ErrorState],
			[ErrorProcedure],
			[ErrorLine],
			[ErrorMessage]
		)
		SELECT
			[ProcedureLogId]	= @ProcedureLogId,
			[ErrorNumber]		= ERROR_NUMBER(),
			[ErrorSeverity]		= ERROR_SEVERITY(),
			[ErrorState]		= ERROR_STATE(),
			[ErrorProcedure]	= COALESCE(ERROR_PROCEDURE(), 'Dynamic SQL'),
			[ErrorLine]			= ERROR_LINE(),
			[ErrorMessage]		= ERROR_MESSAGE();

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
GO
PRINT N'Creating Procedure [track].[Insert_ProcedureLogIntermediate]...';


GO
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
GO
PRINT N'Creating Procedure [track].[Insert_ProcedureLogOrphan]...';


GO
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
GO
PRINT N'Creating Procedure [verf].[InsertItemCount]...';


GO
CREATE PROCEDURE [verf].[InsertItemCount]
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
GO
PRINT N'Creating Procedure [track].[ExampleProcedure]...';


GO
CREATE PROCEDURE [track].[ExampleProcedure]
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

		DROP TABLE IF EXISTS #TempTable;

		SELECT DB_NAME();

		DECLARE @RandomWait	VARCHAR(8) = CONVERT(VARCHAR(8), DATEADD(SECOND, RAND() * 60 * 10, 0), 108);
		PRINT @RandomWait

		WAITFOR DELAY @RandomWait;

		WAITFOR DELAY '00:00:05';

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
GO
PRINT N'Creating Procedure [track].[Insert_ApplicationLogOrphan]...';


GO
CREATE PROCEDURE [track].[Insert_ApplicationLogOrphan]
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

		INSERT INTO [track].[ApplicationLogOrphans]
		(
			[ApplicationLogId]
		)
		SELECT
			[b].[ApplicationLogId]
		FROM
			[track].[ApplicationLogBegin]		[b]	WITH (NOLOCK)
		LEFT OUTER JOIN
			[track].[ApplicationLogEnd]			[e]	WITH (NOLOCK)
				ON	([b].[ApplicationLogId]	=	[e].[ApplicationLogId])
		LEFT OUTER JOIN
			[track].[ApplicationLogErrors]		[r]	WITH (NOLOCK)
				ON	([b].[ApplicationLogId]	=	[r].[ApplicationLogId])
		LEFT OUTER JOIN
			[track].[ApplicationLogOrphans]		[o]	WITH (NOLOCK)
				ON	([b].[ApplicationLogId]	=	[o].[ApplicationLogId])
		WHERE
				([e].[ApplicationLogId]	IS NULL)
			AND	([r].[ApplicationLogId]	IS NULL)
			AND	([o].[ApplicationLogId]	IS NULL)
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
GO
PRINT N'Creating Extended Property [dbo].[sp_ssis_addlogentry].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'SSIS SQL Logging Procedure', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'sp_ssis_addlogentry';


GO
PRINT N'Update complete.';


GO
