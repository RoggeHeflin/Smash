CREATE PROCEDURE [smash].[Select_DatabaseIndexesOperational]
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

		DROP TABLE IF EXISTS #ReturnTable_DatabaseIndexesOperational;

		CREATE TABLE #ReturnTable_DatabaseIndexesOperational
		(
			[ReturnTableId]					INT					NOT	NULL	IDENTITY(1, 1) NOT FOR REPLICATION,

			[instance_id]					INT					NOT	NULL,
			[database_id]					SMALLINT			NOT	NULL,
			[schema_id]						INT					NOT	NULL,
			[object_id]						INT					NOT	NULL,
			[index_id]						INT					NOT	NULL,

			[partition_id]					BIGINT				NOT	NULL,
			[partition_number]				INT					NOT	NULL,
			[hobt_id]						BIGINT				NOT	NULL,

			[Instance]						NVARCHAR(128)		NOT	NULL,
			[InstanceHost]					NVARCHAR(128)		NOT	NULL,
			[InstanceName]					NVARCHAR(128)		NOT	NULL,

			[DatabaseType]					VARCHAR(8)			NOT	NULL,
			[ObjectGroup]					VARCHAR(40)				NULL,
			[ObjectType]					VARCHAR(40)				NULL,

			[DatabaseName]					NVARCHAR(128)		NOT	NULL,
			[SchemaName]					NVARCHAR(128)		NOT	NULL,
			[ObjectName]					NVARCHAR(128)		NOT	NULL,
			[IndexName]						NVARCHAR(128)		NOT	NULL,

			[IndexType]						VARCHAR(16)			NOT	NULL,
			[IndexTypeClustering]			VARCHAR(16)			NOT	NULL,

			[IsPrimaryKey]					VARCHAR(3)			NOT	NULL,
			[IsUnique]						VARCHAR(3)			NOT	NULL,
			[IsUniqueConstraint]			VARCHAR(3)			NOT	NULL,
			[IsSingleColumn]				VARCHAR(3)			NOT	NULL,

			[ColumnsKey]					NVARCHAR(MAX)			NULL,
			[ColumnsKeyAll]					NVARCHAR(MAX)			NULL,
			[ColumnsIncluded]				NVARCHAR(MAX)			NULL,
			[ColumnsAll]					NVARCHAR(MAX)			NULL,

			[FileGroup]						NVARCHAR(128)		NOT	NULL,
			[FileGroupDescription]			VARCHAR(24)			NOT	NULL,
			[FileGroupIsDefault]			VARCHAR(3)			NOT	NULL,
			[FileGroupIsSystem]				VARCHAR(3)			NOT	NULL,

			[IgnoreDuplicateKey]			VARCHAR(3)			NOT	NULL,

			[FillFactor]					TINYINT				NOT	NULL,

			[IsPadded]						VARCHAR(3)			NOT	NULL,
			[IsEnabled]						VARCHAR(3)			NOT	NULL,
			[IsDisabled]					VARCHAR(3)			NOT	NULL,
			[IsHypothetical]				VARCHAR(3)			NOT	NULL,
			[IsIgnoredInOptimization]		VARCHAR(3)			NOT	NULL,
			[AllowRowLocks]					VARCHAR(3)			NOT	NULL,
			[AllowPageLocks]				VARCHAR(3)			NOT	NULL,

			[IsFiltered]					VARCHAR(3)			NOT	NULL,
			[FilterDefinition]				NVARCHAR(MAX)			NULL,

			[CompressionDelayMinutes]		INT						NULL,

			[SuppressDupKeyMessages]		VARCHAR(3)			NOT	NULL,
			[IsAutoCreated]					VARCHAR(3)			NOT	NULL,
			[OptimizeForSequentialKey]		VARCHAR(3)				NULL,

			[RowLockPercent]				FLOAT				NOT	NULL,
			[RowLockWaitAverageMs]			FLOAT				NOT	NULL,

			[LeafInsertCount]				BIGINT				NOT	NULL,
			[LeafUpdateCount]				BIGINT				NOT	NULL,
			[LeafDeleteCount]				BIGINT				NOT	NULL,
			[LeafGhostCount]				BIGINT				NOT	NULL,
			[LeafAllocationCount]			BIGINT				NOT	NULL,
			[LeafPageMergeCount]			BIGINT				NOT	NULL,

			[NonleafInsertCount]			BIGINT				NOT	NULL,
			[NonleafUpdateCount]			BIGINT				NOT	NULL,
			[NonleafDeleteCount]			BIGINT				NOT	NULL,
			[NonleafAllocationCount]		BIGINT				NOT	NULL,
			[NonleafPageMergeCount]			BIGINT				NOT	NULL,

			[PageCompressionAttemptCount]	BIGINT				NOT	NULL,
			[PageCompressionSuccessCount]	BIGINT				NOT	NULL,

			[PageIoLatchWaitCount]			BIGINT				NOT	NULL,
			[PageIoLatchWaitMs]				BIGINT				NOT	NULL,
			[PageLatchWaitCount]			BIGINT				NOT	NULL,
			[PageLatchWaitMs]				BIGINT				NOT	NULL,

			[RowLockCount]					BIGINT				NOT	NULL,
			[RowLockWaitCount]				BIGINT				NOT	NULL,
			[RowLockWaitMs]					BIGINT				NOT	NULL,

			[PageLockCount]					BIGINT				NOT	NULL,
			[PageLockWaitCount]				BIGINT				NOT	NULL,
			[PageLockWaitMs]				BIGINT				NOT	NULL,

			[RowOverflowFetchBytes]			BIGINT				NOT	NULL,
			[RowOverflowFetchPages]			BIGINT				NOT	NULL,

			[TreePageIoLatchWaitCount]		BIGINT				NOT	NULL,
			[TreePageIoLatchWaitMs]			BIGINT				NOT	NULL,
			[TreePageLatchWaitCount]		BIGINT				NOT	NULL,
			[TreePageLatchWaitMs]			BIGINT				NOT	NULL,

			[LobFetchBytes]					BIGINT				NOT	NULL,
			[LobFetchPages]					BIGINT				NOT	NULL,
			[LobOrphanCreateCount]			BIGINT				NOT	NULL,
			[LobOrphanInsertCount]			BIGINT				NOT	NULL,

			[IndexLockPromotionAttemptCount]	BIGINT			NOT	NULL,
			[IndexLockPromotionCount]		BIGINT				NOT	NULL,

			[ColumnValuePullInRowCount]		BIGINT				NOT	NULL,
			[ColumnValuePushOffRowCount]	BIGINT				NOT	NULL,

			[RangeScanCount]				BIGINT				NOT	NULL,
			[SingletonLookupCount]			BIGINT				NOT	NULL,
			[ForwardedFetchCount]			BIGINT				NOT	NULL,

			PRIMARY KEY CLUSTERED([ReturnTableId]	ASC)
		);

		DECLARE	@SqlBase		NVARCHAR(MAX)	= N'
		IF (OBJECT_ID(''[$(DatabaseName)].[smash].[DatabaseIndexesOperational]'') IS NOT NULL)
		BEGIN

			INSERT INTO #ReturnTable_DatabaseIndexesOperational	WITH(TABLOCK)
			(
				[instance_id],
				[database_id],
				[schema_id],
				[object_id],
				[index_id],

				[partition_id],
				[partition_number],
				[hobt_id],

				[Instance],
				[InstanceHost],
				[InstanceName],

				[DatabaseType],
				[ObjectGroup],
				[ObjectType],

				[DatabaseName],
				[SchemaName],
				[ObjectName],
				[IndexName],

				[IndexType],
				[IndexTypeClustering],

				[IsPrimaryKey],
				[IsUnique],
				[IsUniqueConstraint],
				[IsSingleColumn],

				[ColumnsKey],
				[ColumnsKeyAll],
				[ColumnsIncluded],
				[ColumnsAll],

				[FileGroup],
				[FileGroupDescription],
				[FileGroupIsDefault],
				[FileGroupIsSystem],

				[IgnoreDuplicateKey],

				[FillFactor],

				[IsPadded],
				[IsEnabled],
				[IsDisabled],
				[IsHypothetical],
				[IsIgnoredInOptimization],
				[AllowRowLocks],
				[AllowPageLocks],

				[IsFiltered],
				[FilterDefinition],

				[CompressionDelayMinutes],

				[SuppressDupKeyMessages],
				[IsAutoCreated],
				[OptimizeForSequentialKey],

				[RowLockPercent],
				[RowLockWaitAverageMs],

				[LeafInsertCount],
				[LeafUpdateCount],
				[LeafDeleteCount],
				[LeafGhostCount],
				[LeafAllocationCount],
				[LeafPageMergeCount],

				[NonleafInsertCount],
				[NonleafUpdateCount],
				[NonleafDeleteCount],
				[NonleafAllocationCount],
				[NonleafPageMergeCount],

				[PageCompressionAttemptCount],
				[PageCompressionSuccessCount],

				[PageIoLatchWaitCount],
				[PageIoLatchWaitMs],
				[PageLatchWaitCount],
				[PageLatchWaitMs],

				[RowLockCount],
				[RowLockWaitCount],
				[RowLockWaitMs],

				[PageLockCount],
				[PageLockWaitCount],
				[PageLockWaitMs],

				[RowOverflowFetchBytes],
				[RowOverflowFetchPages],

				[TreePageIoLatchWaitCount],
				[TreePageIoLatchWaitMs],
				[TreePageLatchWaitCount],
				[TreePageLatchWaitMs],

				[LobFetchBytes],
				[LobFetchPages],
				[LobOrphanCreateCount],
				[LobOrphanInsertCount],

				[IndexLockPromotionAttemptCount],
				[IndexLockPromotionCount],

				[ColumnValuePullInRowCount],
				[ColumnValuePushOffRowCount],

				[RangeScanCount],
				[SingletonLookupCount],
				[ForwardedFetchCount]
			)
			SELECT
				[t].[instance_id],
				[t].[database_id],
				[t].[schema_id],
				[t].[object_id],
				[t].[index_id],

				[t].[partition_id],
				[t].[partition_number],
				[t].[hobt_id],

				[t].[Instance],
				[t].[InstanceHost],
				[t].[InstanceName],

				[t].[DatabaseType],
				[t].[ObjectGroup],
				[t].[ObjectType],

				[t].[DatabaseName],
				[t].[SchemaName],
				[t].[ObjectName],
				[t].[IndexName],

				[t].[IndexType],
				[t].[IndexTypeClustering],

				[t].[IsPrimaryKey],
				[t].[IsUnique],
				[t].[IsUniqueConstraint],
				[t].[IsSingleColumn],

				[t].[ColumnsKey],
				[t].[ColumnsKeyAll],
				[t].[ColumnsIncluded],
				[t].[ColumnsAll],

				[t].[FileGroup],
				[t].[FileGroupDescription],
				[t].[FileGroupIsDefault],
				[t].[FileGroupIsSystem],

				[t].[IgnoreDuplicateKey],

				[t].[FillFactor],

				[t].[IsPadded],
				[t].[IsEnabled],
				[t].[IsDisabled],
				[t].[IsHypothetical],
				[t].[IsIgnoredInOptimization],
				[t].[AllowRowLocks],
				[t].[AllowPageLocks],

				[t].[IsFiltered],
				[t].[FilterDefinition],

				[t].[CompressionDelayMinutes],

				[t].[SuppressDupKeyMessages],
				[t].[IsAutoCreated],
				[t].[OptimizeForSequentialKey],

				[t].[RowLockPercent],
				[t].[RowLockWaitAverageMs],

				[t].[LeafInsertCount],
				[t].[LeafUpdateCount],
				[t].[LeafDeleteCount],
				[t].[LeafGhostCount],
				[t].[LeafAllocationCount],
				[t].[LeafPageMergeCount],

				[t].[NonleafInsertCount],
				[t].[NonleafUpdateCount],
				[t].[NonleafDeleteCount],
				[t].[NonleafAllocationCount],
				[t].[NonleafPageMergeCount],

				[t].[PageCompressionAttemptCount],
				[t].[PageCompressionSuccessCount],

				[t].[PageIoLatchWaitCount],
				[t].[PageIoLatchWaitMs],
				[t].[PageLatchWaitCount],
				[t].[PageLatchWaitMs],

				[t].[RowLockCount],
				[t].[RowLockWaitCount],
				[t].[RowLockWaitMs],

				[t].[PageLockCount],
				[t].[PageLockWaitCount],
				[t].[PageLockWaitMs],

				[t].[RowOverflowFetchBytes],
				[t].[RowOverflowFetchPages],

				[t].[TreePageIoLatchWaitCount],
				[t].[TreePageIoLatchWaitMs],
				[t].[TreePageLatchWaitCount],
				[t].[TreePageLatchWaitMs],

				[t].[LobFetchBytes],
				[t].[LobFetchPages],
				[t].[LobOrphanCreateCount],
				[t].[LobOrphanInsertCount],

				[t].[IndexLockPromotionAttemptCount],
				[t].[IndexLockPromotionCount],

				[t].[ColumnValuePullInRowCount],
				[t].[ColumnValuePushOffRowCount],

				[t].[RangeScanCount],
				[t].[SingletonLookupCount],
				[t].[ForwardedFetchCount]
			FROM
				[$(DatabaseName)].[smash].[DatabaseIndexesOperational]	[t];

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
					([d].[name]	> @DbName)
				--AND	([d].[database_id] NOT IN (SELECT [x].[database_id] FROM [smash].[ExcludeDatabases] [x]));

			SET @SqlCommand = REPLACE(@SqlBase, N'$(DatabaseName)', @DbName);

			PRINT CONVERT(NCHAR(23), SYSDATETIME(), 121) + NCHAR(9) + N'Querying database [' + @DbName + N']';

			EXECUTE sp_executesql @SqlCommand;

		END;

		SELECT
			[t].[instance_id],
			[t].[database_id],
			[t].[schema_id],
			[t].[object_id],
			[t].[index_id],

			[t].[partition_id],
			[t].[partition_number],
			[t].[hobt_id],

			[t].[Instance],
			[t].[InstanceHost],
			[t].[InstanceName],

			[t].[DatabaseType],
			[t].[ObjectGroup],
			[t].[ObjectType],

			[t].[DatabaseName],
			[t].[SchemaName],
			[t].[ObjectName],
			[t].[IndexName],

			[t].[IndexType],
			[t].[IndexTypeClustering],

			[t].[IsPrimaryKey],
			[t].[IsUnique],
			[t].[IsUniqueConstraint],
			[t].[IsSingleColumn],

			[t].[ColumnsKey],
			[t].[ColumnsKeyAll],
			[t].[ColumnsIncluded],
			[t].[ColumnsAll],

			[t].[FileGroup],
			[t].[FileGroupDescription],
			[t].[FileGroupIsDefault],
			[t].[FileGroupIsSystem],

			[t].[IgnoreDuplicateKey],

			[t].[FillFactor],

			[t].[IsPadded],
			[t].[IsEnabled],
			[t].[IsDisabled],
			[t].[IsHypothetical],
			[t].[IsIgnoredInOptimization],
			[t].[AllowRowLocks],
			[t].[AllowPageLocks],

			[t].[IsFiltered],
			[t].[FilterDefinition],

			[t].[CompressionDelayMinutes],

			[t].[SuppressDupKeyMessages],
			[t].[IsAutoCreated],
			[t].[OptimizeForSequentialKey],

			[t].[RowLockPercent],
			[t].[RowLockWaitAverageMs],

			[t].[LeafInsertCount],
			[t].[LeafUpdateCount],
			[t].[LeafDeleteCount],
			[t].[LeafGhostCount],
			[t].[LeafAllocationCount],
			[t].[LeafPageMergeCount],

			[t].[NonleafInsertCount],
			[t].[NonleafUpdateCount],
			[t].[NonleafDeleteCount],
			[t].[NonleafAllocationCount],
			[t].[NonleafPageMergeCount],

			[t].[PageCompressionAttemptCount],
			[t].[PageCompressionSuccessCount],

			[t].[PageIoLatchWaitCount],
			[t].[PageIoLatchWaitMs],
			[t].[PageLatchWaitCount],
			[t].[PageLatchWaitMs],

			[t].[RowLockCount],
			[t].[RowLockWaitCount],
			[t].[RowLockWaitMs],

			[t].[PageLockCount],
			[t].[PageLockWaitCount],
			[t].[PageLockWaitMs],

			[t].[RowOverflowFetchBytes],
			[t].[RowOverflowFetchPages],

			[t].[TreePageIoLatchWaitCount],
			[t].[TreePageIoLatchWaitMs],
			[t].[TreePageLatchWaitCount],
			[t].[TreePageLatchWaitMs],

			[t].[LobFetchBytes],
			[t].[LobFetchPages],
			[t].[LobOrphanCreateCount],
			[t].[LobOrphanInsertCount],

			[t].[IndexLockPromotionAttemptCount],
			[t].[IndexLockPromotionCount],

			[t].[ColumnValuePullInRowCount],
			[t].[ColumnValuePushOffRowCount],

			[t].[RangeScanCount],
			[t].[SingletonLookupCount],
			[t].[ForwardedFetchCount]
		FROM
			#ReturnTable_DatabaseIndexesOperational	[t];

		DROP TABLE IF EXISTS #ReturnTable_DatabaseIndexesOperational;

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