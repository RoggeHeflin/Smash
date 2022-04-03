WITH XMLNAMESPACES(DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
SELECT DISTINCT
[SOEAR]		= stmts.st.value('(@StatementOptmEarlyAbortReason)[1]','sysname')
FROM (
	SELECT
		[s].[sql_handle],
		[s].[plan_handle],
		[s].[statement_start_offset],
		[s].[statement_end_offset]
	FROM
		sys.dm_exec_query_stats		[s]
	) [s]
CROSS APPLY
	sys.dm_exec_sql_text([s].[sql_handle])		[t]
CROSS APPLY
	sys.dm_exec_query_plan([s].[plan_handle])	[p]
CROSS APPLY
	[p].[query_plan].nodes('/ShowPlanXML/BatchSequence/Batch/Statements/*') stmts(st)
	
	
	
WITH XMLNAMESPACES('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS [ns])
SELECT 
		[instance_id]				= CHECKSUM(@@SERVERNAME),
		[database_id]				= [p].[dbid],
	[x].[schema_id],
		[object_id]					= [t].[objectid],

		[Instance]					= @@SERVERNAME,
		[InstanceHost]				= CAST(SERVERPROPERTY('MachineName') AS VARCHAR),
		[InstanceName]				= @@SERVICENAME,

		[DatabaseType]				= [smash].[SystemDatabaseType](DB_ID()),
		[ObjectGroup]				= [smash].[ObjectGroup]([u].[type]),
		[ObjectType]				= [smash].[ObjectType]([u].[type]),

		[DatabaseName]				= DB_NAME([p].[dbid]),
		[SchemaName]				= COALESCE([x].[name], 'Ad Hoc'),
		[ProcedureName]				= COALESCE([u].[name], 'Ad Hoc'),

		[IsEncrypted]				= CASE [t].[encrypted]
										WHEN 0	THEN 'Plain Text'
										WHEN 1	THEN 'Encrypted'
										END,

		[Reason]					= CASE 1
										WHEN [p].[query_plan].exist('//ns:StmtSimple/@StatementOptmEarlyAbortReason[.="TimeOut"]')				THEN 'Time Out'
										WHEN [p].[query_plan].exist('//ns:StmtSimple/@StatementOptmEarlyAbortReason[.="MemoryLimitExceeded"]')	THEN 'Memory Limit Exceeded'
										WHEN [p].[query_plan].exist('//ns:StmtSimple/@StatementOptmEarlyAbortReason[.="GoodEnoughPlanFound"]')	THEN 'Good Enough Plan Found'
										END,

		[TimeoutStatement]			= CASE WHEN ([s].[statement_end_offset] > 0)
										THEN SUBSTRING([t].[text], [s].[statement_start_offset] / 2 + 1, ([s].[statement_end_offset] - [s].[statement_start_offset]) / 2)
										ELSE 'SQL Statement'
										END,

		[BatchStatement]			= [t].[text],

		[QueryPlan]					= [p].[query_plan]
FROM (
	SELECT TOP 50
		[s].[sql_handle],
		[s].[plan_handle],
		[s].[statement_start_offset],
		[s].[statement_end_offset]
	FROM
		sys.dm_exec_query_stats		[s]
	ORDER BY
		[s].[total_worker_time]	DESC
	) [s]
CROSS APPLY
	sys.dm_exec_sql_text([s].[sql_handle])		[t]
CROSS APPLY
	sys.dm_exec_query_plan([s].[plan_handle])	[p]
LEFT OUTER JOIN
	sys.procedures								[u]
		ON	([p].[objectid]					=	[u].[object_id])
LEFT OUTER JOIN
	sys.schemas									[x]
		ON	([u].[schema_id]				=	[x].[schema_id])
WHERE
		([t].[text] NOT LIKE '%WITH XMLNAMESPACES%')
	AND(	([p].[query_plan].exist('//ns:StmtSimple/@StatementOptmEarlyAbortReason[.="TimeOut"]')				= 1)
		OR	([p].[query_plan].exist('//ns:StmtSimple/@StatementOptmEarlyAbortReason[.="MemoryLimitExceeded"]')	= 1)
		--OR	([p].[query_plan].exist('//ns:StmtSimple/@StatementOptmEarlyAbortReason[.="GoodEnoughPlanFound"]')	= 1)
		);





