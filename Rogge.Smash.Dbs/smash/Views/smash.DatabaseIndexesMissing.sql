CREATE VIEW [smash].[DatabaseIndexesMissing]
WITH VIEW_METADATA
AS
SELECT
		[instance_id]				= CHECKSUM(@@SERVERNAME),
		[database_id]				= DB_ID(),
	[c].[schema_id],
	[o].[object_id],

		[Instance]					= @@SERVERNAME,
		[InstanceHost]				= CAST(SERVERPROPERTY('MachineName') AS VARCHAR),
		[InstanceName]				= @@SERVICENAME,

		[DatabaseName]				= DB_NAME(),
		[SchemaName]				= [c].[name],
		[ObjectName]				= [o].[name],

		[ColumnsEquality]			= [d].[equality_columns],
		[ColumnsInequality]			= [d].[inequality_columns],
		[ColumnsIncluded]			= [d].[included_columns],

		[UniqueCompiles]			= [s].[unique_compiles],

		[UserSeeks]					= [s].[user_seeks],
		[UserScans]					= [s].[user_scans],

		[LastUserSeek]				= [s].[last_user_seek],
		[LastUserScan]				= [s].[last_user_scan],
		[LastUserRead]				= (SELECT MAX([x].[v]) FROM (VALUES ([s].[last_user_seek]), ([s].[last_user_scan])) [x]([v])),

		[AvgTotalUserCost]			= [s].[avg_total_user_cost],
		[AvgUserImpact]				= [s].[avg_user_impact],

		[UserAdvantage]				= ([s].[user_seeks] + [s].[user_scans]) * [s].[avg_total_user_cost] * [s].[avg_user_impact] / 100.0,

		[SystemSeeks]				= [s].[system_seeks],
		[SystemScans]				= [s].[system_scans],

		[LastSystemSeek]			= [s].[last_system_seek],
		[LastSystemScan]			= [s].[last_system_scan],
		[LastSystemRead]			= (SELECT MAX([x].[v]) FROM (VALUES ([s].[last_system_seek]), ([s].[last_system_scan])) [x]([v])),

		[AvgTotalSystemCost]		= [s].[avg_total_system_cost],
		[AvgSystemImpact]			= [s].[avg_system_impact],

		[SystemAdvantage]			= ([s].[system_seeks] + [s].[system_scans]) * [s].[avg_total_system_cost] * [s].[avg_system_impact] / 100.0

FROM
	sys.dm_db_missing_index_details			[d]
INNER JOIN
	sys.dm_db_missing_index_groups			[g]
		ON	([d].[index_handle]			=	[g].[index_handle])
INNER JOIN
	sys.dm_db_missing_index_group_stats		[s]
		ON	([g].[index_group_handle]	=	[s].[group_handle])
INNER JOIN
	sys.objects								[o]
		ON	([d].[object_id]			=	[o].[object_id])
		AND	([o].[is_ms_shipped]		=	0)
INNER JOIN
	sys.schemas								[c]
		ON	([o].[schema_id]			=	[c].[schema_id])
WHERE
	([d].[database_id]	=	DB_ID());