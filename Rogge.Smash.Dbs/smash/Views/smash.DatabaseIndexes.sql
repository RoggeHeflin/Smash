CREATE VIEW [smash].[DatabaseIndexes]
WITH VIEW_METADATA
AS
SELECT
		[instance_id]				= CHECKSUM(@@SERVERNAME),
		[database_id]				= DB_ID(),
	[s].[schema_id],
	[o].[object_id],
	[i].[index_id],

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

		[IsIndexDropCandidate]		= CASE WHEN ([u].[index_id] IS NOT NULL)
										THEN
											CASE WHEN
													([i].[is_primary_key]	= 0)
												AND	([i].[is_unique ]		= 0)
												AND	([u].[user_updates]		> 0)
												AND	([u].[user_seeks]		= 0)
												AND	([u].[user_scans]		= 0)
												AND	([u].[user_lookups]		= 0)
											THEN 'Yes'
											ELSE 'No'
											END
										ELSE NULL
										END,

		[IsIndexReadByUser]			= CASE WHEN ([u].[index_id] IS NOT NULL)
										THEN
											CASE WHEN
													([u].[user_seeks]		= 0)
												AND	([u].[user_scans]		= 0)
												AND	([u].[user_lookups]		= 0)
											THEN 'No'
											ELSE 'Yes'
											END
										ELSE NULL
										END,

		[IsIndexReadBySystem]		= CASE WHEN ([u].[index_id] IS NOT NULL)
										THEN
											CASE WHEN
													([u].[system_seeks]		= 0)
												AND	([u].[system_scans]		= 0)
												AND	([u].[system_lookups]	= 0)
											THEN 'No'
											ELSE 'Yes'
											END
										ELSE NULL
										END,

		[UserSeeks]					= [u].[user_seeks],
		[UserScans]					= [u].[user_scans],
		[UserLookups]				= [u].[user_lookups],
		[UserUpdates]				= [u].[user_updates],

		[LastUserSeek]				= [u].[last_user_seek],
		[LastUserScan]				= [u].[last_user_scan],
		[LastUserLookup]			= [u].[last_user_lookup],
		[LastUserUpdate]			= [u].[last_user_update],

		[LastUserRead]				= (SELECT MAX([x].[v]) FROM (VALUES ([u].[last_user_seek]), ([u].[last_user_scan]), ([u].[last_user_lookup])) [x]([v])),

		[SystemSeeks]				= [u].[system_seeks],
		[SystemScans]				= [u].[system_scans],
		[SystemLookups]				= [u].[system_lookups],
		[SystemUpdates]				= [u].[system_updates],

		[LastSystemSeek]			= [u].[last_system_seek],
		[LastSystemScan]			= [u].[last_system_scan],
		[LastSystemLookup]			= [u].[last_system_lookup],
		[LastSystemUpdate]			= [u].[last_system_update],

		[LastSystemRead]			= (SELECT MAX([x].[v]) FROM (VALUES ([u].[last_system_seek]), ([u].[last_system_scan]), ([u].[last_system_lookup])) [x]([v]))

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
LEFT OUTER JOIN
	sys.dm_db_index_usage_stats			[u]
		ON	([i].[object_id]		=	[u].[object_id])
		AND	([i].[index_id]			=	[u].[index_id])
		AND	([u].[database_id]		=	DB_ID());