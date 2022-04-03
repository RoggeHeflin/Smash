CREATE VIEW [smash].[DatabaseIndexesAllocation]
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
	[a].[allocation_unit_id],
	[a].[container_id],

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

		[IsRowCount]				= IIF(([i].[index_id] <= 1) AND ([a].[type] = 1), 'Yes', 'No'),

		[RowCount]					= [p].[rows],

		[DataCompression]			= CASE [p].[data_compression]
										WHEN 0	THEN 'None'
										WHEN 1	THEN 'Row'
										WHEN 2	THEN 'Page'
										WHEN 3	THEN 'Columnstore'
										WHEN 4	THEN 'Columnstore (Archive)'
										ELSE [p].[data_compression_desc]
										END,

		[AllocationType]			= CASE [a].[type]
										WHEN 0	THEN 'Dropped'
										WHEN 1	THEN 'In-row data'
										WHEN 2	THEN 'Large object (LOB)'
										WHEN 3	THEN 'Row-overflow'
										ELSE [a].[type_desc]
										END,

		[AllocationTotalPages]		= [a].[total_pages],
		[AllocationUsedPages]		= [a].[used_pages],
		[AllocationDataPages]		= [a].[data_pages],
		[AllocationFreePages]		= ([a].[total_pages] - [a].[used_pages]),

		[AllocationTotalMb]			= (8.0 * CONVERT(FLOAT, [a].[total_pages]))	/ 1024.0,
		[AllocationUsedMb]			= (8.0 * CONVERT(FLOAT, [a].[used_pages]))	/ 1024.0,
		[AllocationDataMb]			= (8.0 * CONVERT(FLOAT, [a].[data_pages]))	/ 1024.0,
		[AllocationFreeMb]			= (8.0 * CONVERT(FLOAT, [a].[total_pages] - [a].[used_pages]))	/ 1024.0

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
INNER JOIN
	sys.allocation_units				[a]
		ON	([i].[data_space_id]	=	[a].[data_space_id])
		AND	([p].[partition_id]		=	[a].[container_id]);