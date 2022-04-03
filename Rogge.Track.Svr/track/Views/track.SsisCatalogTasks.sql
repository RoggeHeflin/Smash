CREATE VIEW [track].[SsisCatalogTasks]
WITH VIEW_METADATA
AS
SELECT
		[instance_id]			= CHECKSUM(@@SERVERNAME),
	[e].[execution_id],
	[m].[operation_message_id],

		[Instance]				= @@SERVERNAME,
		[InstanceHost]			= CAST(SERVERPROPERTY('MachineName') AS VARCHAR),
		[InstanceName]			= @@SERVICENAME,

		[ServerName]			= [e].[server_name],
		[MachineName]			= [e].[machine_name],
		[EnvironmentFolderName]	= [e].[environment_folder_name],
		[EnvironmentName]		= [e].[environment_name],

		[FolderName]			= [e].[folder_name],
		[ProjectName]			= [e].[project_name],
		[PackageName]			= REPLACE([e].[package_name], N'.dtsx', N''),
		[PackageNameFull]		= [e].[package_name],

	[m].[TaskName],

		[UserExecuted]			= [e].[executed_as_name],
		[UserOriginal]			= [e].[caller_name],
		[UserStopped]			= [e].[stopped_by_name],

		[RunTimeBit]			= CASE [e].[use32bitruntime]
									WHEN	0 THEN 64
									WHEN	1 THEN 32
									END,

		[ObjectType]			= CASE [e].[object_type]
									WHEN   20 THEN 'Project'
									WHEN   30 THEN 'Package'
									END,

		[PackageStatus]			= CASE [e].[status]
									WHEN	1 THEN 'Created'
									WHEN	2 THEN 'Running'
									WHEN	3 THEN 'Canceled'
									WHEN	4 THEN 'Failed'
									WHEN	5 THEN 'Pending'
									WHEN	6 THEN 'Ended Unexpectedly'
									WHEN	7 THEN 'Succeeded'
									WHEN	8 THEN 'Stopping'
									WHEN	9 THEN 'Completed'
									END,

		[OperationType]			= CASE [e].[operation_type]
									WHEN	1 THEN 'Integration Services Initialization'
									WHEN	2 THEN 'Retention Window'
									WHEN	3 THEN 'Max Project Version'
									WHEN  101 THEN 'Deploy Project'
									WHEN  106 THEN 'Restore Project'
									WHEN  200 THEN 'Create and Start Execution'
									WHEN  202 THEN 'Stop Operation'
									WHEN  300 THEN 'Validate Project'
									WHEN  301 THEN 'Validate Package'
									WHEN 1000 THEN 'Configure Catalog'
									END,

		[PackageBegin]			= CONVERT(DATETIME2,	[e].[start_time]),
		[PackageBeginDate]		= CONVERT(DATE,			[e].[start_time]),
		[PackageBeginTime]		= CONVERT(TIME,			[e].[start_time]),
		[PackageBeginZone]		= [e].[start_time],

		[TaskBegin]				= CONVERT(DATETIME2,	[m].[TaskBeg]),
		[TaskBeginDate]			= CONVERT(DATE,			[m].[TaskBeg]),
		[TaskBeginTime]			= CONVERT(TIME,			[m].[TaskBeg]),
		[TaskBeginZone]			= [m].[TaskBeg],

		[TaskEnd]				= CONVERT(DATETIME2,	[m].[TaskEnd]),
		[TaskEndDate]			= CONVERT(DATE,			[m].[TaskEnd]),
		[TaskEndTime]			= CONVERT(TIME,			[m].[TaskEnd]),
		[TaskEndZone]			= [m].[TaskEnd],

		[TaskStatus]			= CASE
									WHEN ([m].[TaskEnd] IS NULL)		THEN 'Running'
									WHEN ([m].[TaskFailsCount]	> 0)	THEN 'Failed'
									WHEN ([m].[TaskErrorsCount]	> 0)	THEN 'Failed'
									ELSE 'Succeeded'
									END,

		[Duration]				= STUFF(CONVERT(VARCHAR(20), CONVERT(DATETIME, [m].[TaskEnd]) - CONVERT(DATETIME, [m].[TaskBeg]), 114), 1, 2,
										DATEDIFF(HOUR, 0,	 CONVERT(DATETIME, [m].[TaskEnd]) - CONVERT(DATETIME, [m].[TaskBeg]))),

		[DurationDays]			= DATEDIFF(SECOND,
									[m].[TaskBeg],
									CASE WHEN ([e].[status] IN (1, 2, 5, 8))
										THEN COALESCE([m].[TaskEnd], SYSDATETIMEOFFSET())
										ELSE [m].[TaskEnd]
										END
									) / 86400.0,
		[DurationMinutes]		= DATEDIFF(SECOND,
									[m].[TaskBeg],
									CASE WHEN ([e].[status] IN (1, 2, 5, 8))
										THEN COALESCE([m].[TaskEnd], SYSDATETIMEOFFSET())
										ELSE [m].[TaskEnd]
										END
									) / 60.0,
		[DurationSeconds]		= DATEDIFF(SECOND,
									[m].[TaskBeg],
									CASE WHEN ([e].[status] IN (1, 2, 5, 8))
										THEN COALESCE([m].[TaskEnd], SYSDATETIMEOFFSET())
										ELSE [m].[TaskEnd]
										END
									),

	[m].[TaskFailsCount],
	[m].[TaskErrorsCount],
	[m].[TaskWarningsCount],
	[m].[TaskInformationCount],
	[m].[TaskCount],

	[m].[MessageFails],
	[m].[MessageErrors],
	[m].[MessageWarnings]
FROM (
	SELECT
		[m].[operation_id],
			[operation_message_id]	= MIN([m].[operation_message_id]),

			[TaskName]				= LEFT([m].[message], CHARINDEX(N':', [m].[message]) - 1),

			[TaskBeg]				= MIN(CASE WHEN ([m].[message_type] = 30) THEN [m].[message_time] END),
			[TaskEnd]				= MAX(CASE WHEN ([m].[message_type] = 40) THEN [m].[message_time] END),

			[TaskFailsCount]		= COUNT(CASE WHEN ([m].[message_type] = 130) THEN 1 ELSE NULL END),
			[TaskErrorsCount]		= COUNT(CASE WHEN ([m].[message_type] = 120) THEN 1 ELSE NULL END),
			[TaskWarningsCount]		= COUNT(CASE WHEN ([m].[message_type] = 110) THEN 1 ELSE NULL END),
			[TaskInformationCount]	= COUNT(CASE WHEN ([m].[message_type] =  70) THEN 1 ELSE NULL END),
			[TaskCount]				= COUNT(*),

			[MessageFails]			= STRING_AGG(CASE WHEN ([m].[message_type] = 130) THEN [m].[message] ELSE NULL END, N'') WITHIN GROUP (ORDER BY [m].[operation_message_id] DESC),
			[MessageErrors]			= STRING_AGG(CASE WHEN ([m].[message_type] = 120) THEN [m].[message] ELSE NULL END, N'') WITHIN GROUP (ORDER BY [m].[operation_message_id] DESC),
			[MessageWarnings]		= STRING_AGG(CASE WHEN ([m].[message_type] = 110) THEN [m].[message] ELSE NULL END, N'') WITHIN GROUP (ORDER BY [m].[operation_message_id] DESC)
	FROM
		[$(SSISDB)].[catalog].[operation_messages]	[m]
	WHERE
			([m].[message_source_type]		<>	30)
		AND	([m].[message]					LIKE N'%:%')
		AND	(CHARINDEX(N':', [m].[message]) >	1)
	GROUP BY
		[m].[operation_id],
		LEFT([m].[message], CHARINDEX(N':', [m].[message]) - 1)
	HAVING
		(MIN(CASE WHEN ([m].[message_type] = 30) THEN [m].[message_time] END) IS NOT NULL)
	) [m]
INNER JOIN
	[$(SSISDB)].[catalog].[executions]			[e]
		ON	([m].[operation_id]				=	[e].[execution_id]);