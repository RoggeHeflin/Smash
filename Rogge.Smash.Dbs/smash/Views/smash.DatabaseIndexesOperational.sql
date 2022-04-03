CREATE VIEW [smash].[DatabaseIndexesOperational]
WITH VIEW_METADATA
AS
SELECT
		[instance_id]				= CHECKSUM(@@SERVERNAME),
		[database_id]				= DB_ID(),
	[s].[schema_id],
	[o].[object_id],
	[i].[index_id],

	[p].[partition_id],
	[p].[partition_number],
	[p].[hobt_id],

	---------------------------------------------------------------------------------
	---------------------------------------------------------------------------------

		[Instance]					= @@SERVERNAME,
		[InstanceHost]				= CAST(SERVERPROPERTY('MachineName') AS VARCHAR),
		[InstanceName]				= @@SERVICENAME,

		[DatabaseType]				= [smash].[SystemDatabaseType](DB_ID()),
		[ObjectGroup]				= [smash].[ObjectGroup]([o].[type]),
		[ObjectType]				= [smash].[ObjectType]([o].[type]),

		[DatabaseName]				= DB_NAME(),
		[SchemaName]				= [s].[name],
		[ObjectName]				= [o].[name],
		[IndexName]					= COALESCE([i].[name], N'Heap'),

		[IndexType]					= CASE [i].[type]
										WHEN 0	THEN 'Heap'
										WHEN 1	THEN 'Rowstore'
										WHEN 2	THEN 'Rowstore'
										WHEN 3	THEN 'XML'
										WHEN 4	THEN 'Spatial'
										WHEN 5	THEN 'Columnstore'
										WHEN 6	THEN 'Columnstore'
										WHEN 7	THEN 'Hash'
										END,

		[IndexTypeClustering]		= CASE [i].[type]
										WHEN 0	THEN 'Heap'
										WHEN 1	THEN 'Clustered'
										WHEN 2	THEN 'Nonclustered'
										WHEN 3	THEN 'XML'
										WHEN 4	THEN 'Spatial'
										WHEN 5	THEN 'Clustered'
										WHEN 6	THEN 'Nonclustered'
										WHEN 7	THEN 'Nonclustered'
										END,

		[IsPrimaryKey]				= CASE [i].[is_primary_key]
										WHEN 0	THEN 'No'
										WHEN 1	THEN 'Yes'
										END,

		[IsUnique]					= CASE [i].[is_unique]
										WHEN 0	THEN 'No'
										WHEN 1	THEN 'Yes'
										END,

		[IsUniqueConstraint]		= CASE [i].[is_unique_constraint]
										WHEN 0	THEN 'No'
										WHEN 1	THEN 'Yes'
										END,

		[IsSingleColumn]			= CASE WHEN ((SELECT COUNT(*) FROM sys.index_columns [x] WHERE ([x].[object_id] = [i].[object_id]) AND ([x].[index_id] = [i].[index_id])) = 1)
										THEN 'Yes'
										ELSE 'No'
										END,

		[ColumnsKey]				= STUFF((
										SELECT
											N', ' + [z].[name] + IIF(([y].[is_descending_key] = 0), N' ASC', N' DESC')
										FROM
											sys.index_columns					[y]
										INNER JOIN
											sys.columns							[z]
												ON	([y].[object_id]		=	[z].[object_id])
												AND	([y].[column_id]		=	[z].[column_id])
										WHERE
												([y].[is_included_column]	=	0)
											AND	([y].[object_id]			=	[i].[object_id])
											AND	([y].[index_id]				=	[i].[index_id])
										ORDER BY
											[y].[key_ordinal]	ASC
										FOR XML PATH(N'')), 1, 2, N''),

		[ColumnsKeyAll]				= STUFF((
										SELECT
											N', ' + [z].[name]
										FROM
											sys.index_columns					[y]
										INNER JOIN
											sys.columns							[z]
												ON	([y].[object_id]		=	[z].[object_id])
												AND	([y].[column_id]		=	[z].[column_id])
										WHERE
												([y].[is_included_column]	=	0)
											AND	([y].[object_id]			=	[i].[object_id])
											AND	([y].[index_id]				=	[i].[index_id])
										ORDER BY
											[z].[name]	ASC
										FOR XML PATH(N'')), 1, 2, N''),

		[ColumnsIncluded]			= STUFF((
										SELECT
											N', ' + [z].[name]
										FROM
											sys.index_columns					[y]
										INNER JOIN
											sys.columns							[z]
												ON	([y].[object_id]		=	[z].[object_id])
												AND	([y].[column_id]		=	[z].[column_id])
										WHERE
												([y].[is_included_column]	=	1)
											AND	([y].[object_id]			=	[i].[object_id])
											AND	([y].[index_id]				=	[i].[index_id])
										ORDER BY
											[y].[key_ordinal]	ASC
										FOR XML PATH(N'')), 1, 2, N''),

		[ColumnsAll]				= STUFF((
										SELECT
											N', ' + [z].[name]
										FROM
											sys.index_columns					[y]
										INNER JOIN
											sys.columns							[z]
												ON	([y].[object_id]		=	[z].[object_id])
												AND	([y].[column_id]		=	[z].[column_id])
										WHERE
												([y].[object_id]			=	[i].[object_id])
											AND	([y].[index_id]				=	[i].[index_id])
										ORDER BY
											[z].[name]	ASC
										FOR XML PATH(N'')), 1, 2, N''),

		[FileGroup]					= [d].[name],

		[FileGroupDescription]		= CASE [d].[type]
										WHEN 'FG'	THEN 'Filegroup'
										WHEN 'FD'	THEN 'Filestream'
										WHEN 'FX'	THEN 'Memory-optimized'
										WHEN 'PS'	THEN 'Partition scheme'
										END,

		[FileGroupIsDefault]		= CASE [d].[is_default]
										WHEN 0	THEN 'No'
										WHEN 1	THEN 'Yes'
										END,

		[FileGroupIsSystem]			= CASE [d].[is_system]
										WHEN 0	THEN 'No'
										WHEN 1	THEN 'Yes'
										END,

		[IgnoreDuplicateKey]		= CASE [i].[ignore_dup_key]
										WHEN 0	THEN 'No'
										WHEN 1	THEN 'Yes'
										END,

		[FillFactor]				= [i].[fill_factor],

		[IsPadded]					= CASE [i].[is_padded]
										WHEN 0	THEN 'No'
										WHEN 1	THEN 'Yes'
										END,

		[IsEnabled]					= CASE [i].[is_disabled]
										WHEN 0	THEN 'Yes'		--	Enabled
										WHEN 1	THEN 'No'		--	Disabled
										END,

		[IsDisabled]				= CASE [i].[is_disabled]
										WHEN 0	THEN 'No'		--	Enabled
										WHEN 1	THEN 'Yes'		--	Disabled
										END,

		[IsHypothetical]			= CASE [i].[is_hypothetical]
										WHEN 0	THEN 'No'
										WHEN 1	THEN 'Yes'
										END,

		[IsIgnoredInOptimization]	= CASE [i].[is_ignored_in_optimization]
										WHEN 0	THEN 'No'
										WHEN 1	THEN 'Yes'
										END,

		[AllowRowLocks]				= CASE [i].[allow_row_locks]
										WHEN 0	THEN 'No'
										WHEN 1	THEN 'Yes'
										END,

		[AllowPageLocks]			= CASE [i].[allow_page_locks]
										WHEN 0	THEN 'No'
										WHEN 1	THEN 'Yes'
										END,

		[IsFiltered]				= CASE [i].[has_filter]
										WHEN 0	THEN 'No'
										WHEN 1	THEN 'Yes'
										END,

		[FilterDefinition]			= [i].[filter_definition],

		[CompressionDelayMinutes]	= [i].[compression_delay],

		[SuppressDupKeyMessages]	= CASE [i].[suppress_dup_key_messages]
										WHEN 0	THEN 'No'		--	Show
										WHEN 1	THEN 'Yes'		--	Hide (Suppress)
										END,

		[IsAutoCreated]				= CASE [i].[auto_created]
										WHEN 0	THEN 'No'		--	User
										WHEN 1	THEN 'Yes'		--	Auto
										END,

		[OptimizeForSequentialKey]	= CONVERT(VARCHAR(3), NULL),
		--[OptimizeForSequentialKey]	= CASE [i].[optimize_for_sequential_key]
		--								WHEN 0	THEN 'No'		--	Disabled
		--								WHEN 1	THEN 'Yes'		--	Enabled
		--								END,
		
	---------------------------------------------------------------------------------
	---------------------------------------------------------------------------------

		[RowLockPercent]				= IIF([x].[row_lock_count] > 0, CONVERT(FLOAT, [x].[row_lock_wait_count]) / CONVERT(FLOAT, [x].[row_lock_count]), 0.0),
		[RowLockWaitAverageMs]			= IIF([x].[row_lock_wait_count] > 0, CONVERT(FLOAT, [x].[row_lock_wait_in_ms]) / CONVERT(FLOAT, [x].[row_lock_wait_count]), 0.0),

		[LeafInsertCount]				= [x].[leaf_insert_count],
		[LeafUpdateCount]				= [x].[leaf_update_count],
		[LeafDeleteCount]				= [x].[leaf_delete_count],
		[LeafGhostCount]				= [x].[leaf_ghost_count],
		[LeafAllocationCount]			= [x].[leaf_allocation_count],
		[LeafPageMergeCount]			= [x].[leaf_page_merge_count],

		[NonleafInsertCount]			= [x].[nonleaf_insert_count],
		[NonleafUpdateCount]			= [x].[nonleaf_update_count],
		[NonleafDeleteCount]			= [x].[nonleaf_delete_count],
		[NonleafAllocationCount]		= [x].[nonleaf_allocation_count],
		[NonleafPageMergeCount]			= [x].[nonleaf_page_merge_count],

		[PageCompressionAttemptCount]	= [x].[page_compression_attempt_count],
		[PageCompressionSuccessCount]	= [x].[page_compression_success_count],

		[PageIoLatchWaitCount]			= [x].[page_io_latch_wait_count],
		[PageIoLatchWaitMs]				= [x].[page_io_latch_wait_in_ms],
		[PageLatchWaitCount]			= [x].[page_latch_wait_count],
		[PageLatchWaitMs]				= [x].[page_latch_wait_in_ms],

		[RowLockCount]					= [x].[row_lock_count],
		[RowLockWaitCount]				= [x].[row_lock_wait_count],
		[RowLockWaitMs]					= [x].[row_lock_wait_in_ms],

		[PageLockCount]					= [x].[page_lock_count],
		[PageLockWaitCount]				= [x].[page_lock_wait_count],
		[PageLockWaitMs]				= [x].[page_lock_wait_in_ms],

		[RowOverflowFetchBytes]			= [x].[row_overflow_fetch_in_bytes],
		[RowOverflowFetchPages]			= [x].[row_overflow_fetch_in_pages],

		[TreePageIoLatchWaitCount]		= [x].[tree_page_io_latch_wait_count],
		[TreePageIoLatchWaitMs]			= [x].[tree_page_io_latch_wait_in_ms],
		[TreePageLatchWaitCount]		= [x].[tree_page_latch_wait_count],
		[TreePageLatchWaitMs]			= [x].[tree_page_latch_wait_in_ms],

		[LobFetchBytes]					= [x].[lob_fetch_in_bytes],
		[LobFetchPages]					= [x].[lob_fetch_in_pages],
		[LobOrphanCreateCount]			= [x].[lob_orphan_create_count],
		[LobOrphanInsertCount]			= [x].[lob_orphan_insert_count],

		[IndexLockPromotionAttemptCount]	= [x].[index_lock_promotion_attempt_count],
		[IndexLockPromotionCount]		= [x].[index_lock_promotion_count],

		[ColumnValuePullInRowCount]		= [x].[column_value_pull_in_row_count],
		[ColumnValuePushOffRowCount]	= [x].[column_value_push_off_row_count],

		[RangeScanCount]				= [x].[range_scan_count],
		[SingletonLookupCount]			= [x].[singleton_lookup_count],
		[ForwardedFetchCount]			= [x].[forwarded_fetch_count]

FROM
	sys.schemas							[s]
INNER JOIN
	sys.objects							[o]
		ON	([s].[schema_id]		=	[o].[schema_id])
		AND	([o].[is_ms_shipped]	=	0)
INNER JOIN
	sys.indexes							[i]
		ON	([o].[object_id]		=	[i].[object_id])
INNER JOIN
	sys.data_spaces 					[d]
		ON	([i].[data_space_id]	=	[d].[data_space_id])
INNER JOIN
	sys.partitions						[p]
		ON	([i].[object_id]		=	[p].[object_id])
		AND	([i].[index_id]			=	[p].[index_id])
CROSS APPLY
	sys.dm_db_index_operational_stats(DB_ID(), [o].[object_id], [i].[index_id], [p].[partition_number])	[x];