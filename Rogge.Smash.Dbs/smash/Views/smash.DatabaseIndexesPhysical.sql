CREATE VIEW [smash].[DatabaseIndexesPhysical]
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

		[IndexTypePhysical]				= CASE [x].[index_type_desc]
											WHEN 'HEAP'								THEN 'Heap'
											WHEN 'CLUSTERED INDEX'					THEN 'Rowstore (Clustered)'
											WHEN 'NONCLUSTERED INDEX'				THEN 'Rowstore (Nonclustered)'
											WHEN 'XML INDEX'						THEN 'XML'
											WHEN 'PRIMARY XML INDEX'				THEN 'XML (Primary)'
											WHEN 'EXTENDED INDEX'					THEN 'Extended'
											WHEN 'COLUMNSTORE MAPPING INDEX'		THEN 'Columnstore (Mapping)'
											WHEN 'COLUMNSTORE DELETEBUFFER INDEX'	THEN 'Columnstore (Delete Buffer)'
											WHEN 'COLUMNSTORE DELETEBITMAP INDEX'	THEN 'Columnstore (Delete Bitmap)'
											ELSE [x].[index_type_desc]
											END,

		[AllocationType]				= CASE [x].[alloc_unit_type_desc]
											WHEN 'DROPPED'				THEN 'Dropped'
											WHEN 'IN_ROW_DATA'			THEN 'In-row data'
											WHEN 'LOB_DATA'				THEN 'Large object (LOB)'
											WHEN 'ROW_OVERFLOW_DATA'	THEN 'Row-overflow'
											ELSE [x].[alloc_unit_type_desc]
											END,

		[IndexDepth]					= [x].[index_depth],
		[IndexLevel]					= [x].[index_level],

		[FragmentationPcnt]				= [x].[avg_fragmentation_in_percent] / 100.0,

		[FragmentCount]					= [x].[fragment_count],
		[FragmentSizePages]				= [x].[avg_fragment_size_in_pages],
		[FragmentSizeMb]				= (8.0 / 1024.0 * [x].[avg_fragment_size_in_pages]),

		[DataPages]						= [x].[page_count],
		[DataMb]						= (8.0 * CONVERT(FLOAT, [x].[page_count])) / 1024.0,

		[DataCompressedPages]			= [x].[compressed_page_count],
		[DataCompressedMb]				= (8.0 * CONVERT(FLOAT, [x].[compressed_page_count])) / 1024.0,

		[FragmentPageSpaceUsedPcnt]		= [x].[avg_page_space_used_in_percent] / 100.0,

		[RecordCount]					= [x].[record_count],
		[RecordCountGhost]				= [x].[ghost_record_count],
		[RecordCountGhostVersion]		= [x].[version_ghost_record_count],
		[RecordCountForwarded]			= [x].[forwarded_record_count],

		[RecordSizeMinByte]				= [x].[min_record_size_in_bytes],
		[RecordSizeMaxByte]				= [x].[max_record_size_in_bytes],
		[RecordSizeAvgByte]				= [x].[avg_record_size_in_bytes],

		[ColumnstoreDeleteBufferState]	= CASE [x].[columnstore_delete_buffer_state]
											WHEN 0	THEN 'Not Applicable'
											WHEN 1	THEN 'Open'
											WHEN 2	THEN 'Draining'
											WHEN 3	THEN 'Flushing'
											WHEN 4	THEN 'Retiring'
											WHEN 5	THEN 'Ready'
											ELSE [x].[columnstore_delete_buffer_state_desc]
											END,

		[RecordCountVersion]			= [x].[version_record_count],
		[RecordCountVersionInRow]		= [x].[inrow_version_record_count],
		[RecordCountVersionDiff]		= [x].[inrow_diff_version_record_count],
		[RecordCountVersionInRowByte]	= [x].[total_inrow_version_payload_size_in_bytes],
		[RecordCountVersionOffRow]		= [x].[offrow_regular_version_record_count],
		[RecordCountVersionOffRowLong]	= [x].[offrow_long_term_version_record_count]

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
	sys.dm_db_index_physical_stats(DB_ID(), [o].[object_id], [i].[index_id], [p].[partition_number], 'DETAILED')	[x];