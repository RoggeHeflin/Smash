CREATE PROCEDURE [smash].[Select_DatabaseIndexesPhysical]
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

		DROP TABLE IF EXISTS #ReturnTable_DatabaseIndexesPhysical;

		CREATE TABLE #ReturnTable_DatabaseIndexesPhysical
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

			[IndexTypePhysical]				VARCHAR(30)			NOT	NULL,
			[AllocationType]				VARCHAR(24)			NOT	NULL,

			[IndexDepth]					TINYINT				NOT	NULL,
			[IndexLevel]					TINYINT				NOT	NULL,

			[FragmentationPcnt]				FLOAT				NOT	NULL,

			[FragmentCount]					BIGINT					NULL,
			[FragmentSizePages]				FLOAT					NULL,
			[FragmentSizeMb]				FLOAT					NULL,

			[DataPages]						BIGINT				NOT	NULL,
			[DataMb]						FLOAT				NOT	NULL,
			[DataCompressedPages]			BIGINT					NULL,
			[DataCompressedMb]				FLOAT					NULL,

			[FragmentPageSpaceUsedPcnt]		FLOAT				NOT	NULL,

			[RecordCount]					BIGINT				NOT	NULL,
			[RecordCountGhost]				BIGINT				NOT	NULL,
			[RecordCountGhostVersion]		BIGINT				NOT	NULL,
			[RecordCountForwarded]			BIGINT					NULL,

			[RecordSizeMinByte]				INT					NOT	NULL,
			[RecordSizeMaxByte]				INT					NOT	NULL,
			[RecordSizeAvgByte]				FLOAT				NOT	NULL,

			[ColumnstoreDeleteBufferState]	VARCHAR(30)			NOT	NULL,

			[RecordCountVersion]			BIGINT				NOT	NULL,
			[RecordCountVersionInRow]		BIGINT				NOT	NULL,
			[RecordCountVersionDiff]		BIGINT				NOT	NULL,
			[RecordCountVersionInRowByte]	BIGINT				NOT	NULL,
			[RecordCountVersionOffRow]		BIGINT				NOT	NULL,
			[RecordCountVersionOffRowLong]	BIGINT				NOT	NULL,

			PRIMARY KEY CLUSTERED([ReturnTableId]	ASC)
		);

		DECLARE	@SqlBase		NVARCHAR(MAX)	= N'
		IF (OBJECT_ID(''[$(DatabaseName)].[smash].[DatabaseIndexesPhysical]'') IS NOT NULL)
		BEGIN

			INSERT INTO #ReturnTable_DatabaseIndexesPhysical	WITH(TABLOCK)
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

				[IndexTypePhysical],
				[AllocationType],

				[IndexDepth],
				[IndexLevel],

				[FragmentationPcnt],

				[FragmentCount],
				[FragmentSizePages],
				[FragmentSizeMb],

				[DataPages],
				[DataMb],
				[DataCompressedPages],
				[DataCompressedMb],

				[FragmentPageSpaceUsedPcnt],

				[RecordCount],
				[RecordCountGhost],
				[RecordCountGhostVersion],
				[RecordCountForwarded],

				[RecordSizeMinByte],
				[RecordSizeMaxByte],
				[RecordSizeAvgByte],

				[ColumnstoreDeleteBufferState],

				[RecordCountVersion],
				[RecordCountVersionInRow],
				[RecordCountVersionDiff],
				[RecordCountVersionInRowByte],
				[RecordCountVersionOffRow],
				[RecordCountVersionOffRowLong]
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

				[t].[IndexTypePhysical],
				[t].[AllocationType],

				[t].[IndexDepth],
				[t].[IndexLevel],

				[t].[FragmentationPcnt],

				[t].[FragmentCount],
				[t].[FragmentSizePages],
				[t].[FragmentSizeMb],

				[t].[DataPages],
				[t].[DataMb],
				[t].[DataCompressedPages],
				[t].[DataCompressedMb],

				[t].[FragmentPageSpaceUsedPcnt],

				[t].[RecordCount],
				[t].[RecordCountGhost],
				[t].[RecordCountGhostVersion],
				[t].[RecordCountForwarded],

				[t].[RecordSizeMinByte],
				[t].[RecordSizeMaxByte],
				[t].[RecordSizeAvgByte],

				[t].[ColumnstoreDeleteBufferState],

				[t].[RecordCountVersion],
				[t].[RecordCountVersionInRow],
				[t].[RecordCountVersionDiff],
				[t].[RecordCountVersionInRowByte],
				[t].[RecordCountVersionOffRow],
				[t].[RecordCountVersionOffRowLong]
			FROM
				[$(DatabaseName)].[smash].[DatabaseIndexesPhysical]	[t];

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

			[t].[IndexTypePhysical],
			[t].[AllocationType],

			[t].[IndexDepth],
			[t].[IndexLevel],

			[t].[FragmentationPcnt],

			[t].[FragmentCount],
			[t].[FragmentSizePages],
			[t].[FragmentSizeMb],

			[t].[DataPages],
			[t].[DataMb],
			[t].[DataCompressedPages],
			[t].[DataCompressedMb],

			[t].[FragmentPageSpaceUsedPcnt],

			[t].[RecordCount],
			[t].[RecordCountGhost],
			[t].[RecordCountGhostVersion],
			[t].[RecordCountForwarded],

			[t].[RecordSizeMinByte],
			[t].[RecordSizeMaxByte],
			[t].[RecordSizeAvgByte],

			[t].[ColumnstoreDeleteBufferState],

			[t].[RecordCountVersion],
			[t].[RecordCountVersionInRow],
			[t].[RecordCountVersionDiff],
			[t].[RecordCountVersionInRowByte],
			[t].[RecordCountVersionOffRow],
			[t].[RecordCountVersionOffRowLong]
		FROM
			#ReturnTable_DatabaseIndexesPhysical	[t];

		DROP TABLE IF EXISTS #ReturnTable_DatabaseIndexesPhysical;

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