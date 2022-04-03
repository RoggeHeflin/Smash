CREATE VIEW [smash].[DatabaseProcedures]
WITH VIEW_METADATA
AS
SELECT
		[database_id]				= DB_ID(),
	[s].[schema_id],
	[p].[object_id],

		[ServerName]				= @@SERVERNAME,
		[DatabaseName]				= DB_NAME(),
		[SchemaName]				= [s].[name],
		[ObjectName]				= [p].[name],

		[ObjectType]				= [smash].[ObjectType]([p].[type]),

	[t].[cached_time],
	[t].[execution_count],
	[t].[last_execution_time],

		[total_worker_time]			= IIF([t].[execution_count] > 0, CONVERT(FLOAT, [t].[total_worker_time])	/ CONVERT(FLOAT, [t].[execution_count]), NULL),
	[t].[total_worker_time],
	[t].[last_worker_time],
	[t].[min_worker_time],
	[t].[max_worker_time],

		[avg_elapsed_time]			= IIF([t].[execution_count] > 0, CONVERT(FLOAT, [t].[total_elapsed_time])	/ CONVERT(FLOAT, [t].[execution_count]), NULL),
	[t].[total_elapsed_time],
	[t].[last_elapsed_time],
	[t].[min_elapsed_time],
	[t].[max_elapsed_time],

		[avg_physical_reads]		= IIF([t].[execution_count] > 0, CONVERT(FLOAT, [t].[total_physical_reads])	/ CONVERT(FLOAT, [t].[execution_count]), NULL),
	[t].[total_physical_reads],
	[t].[last_physical_reads],
	[t].[min_physical_reads],
	[t].[max_physical_reads],

		[avg_logical_reads]			= IIF([t].[execution_count] > 0, CONVERT(FLOAT, [t].[total_logical_reads])	/ CONVERT(FLOAT, [t].[execution_count]), NULL),
	[t].[total_logical_reads],
	[t].[last_logical_reads],
	[t].[min_logical_reads],
	[t].[max_logical_reads],

		[avg_logical_writes]		= IIF([t].[execution_count] > 0, CONVERT(FLOAT, [t].[total_logical_writes])	/ CONVERT(FLOAT, [t].[execution_count]), NULL),
	[t].[total_logical_writes],
	[t].[last_logical_writes],
	[t].[min_logical_writes],
	[t].[max_logical_writes]

FROM
	sys.schemas						[s]
INNER JOIN
	sys.procedures					[p]
		ON	([s].[schema_id]	=	[p].[schema_id])
LEFT OUTER JOIN
	sys.dm_exec_procedure_stats		[t]
		ON	([p].[object_id]	=	[t].[object_id])
WHERE
	([s].[name]	<>	'sys');


