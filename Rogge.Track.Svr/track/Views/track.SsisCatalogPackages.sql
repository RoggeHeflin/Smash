CREATE VIEW [track].[SsisCatalogPackages]
WITH VIEW_METADATA
AS
SELECT
		[instance_id]			= CHECKSUM(@@SERVERNAME),
	[e].[execution_id],

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

		[UserExecuted]			= [e].[executed_as_name],
		[UserOriginal]			= [e].[caller_name],
		[UserStopped]			= [e].[stopped_by_name],

		[RunTimeBit]			= CASE [e].[use32bitruntime]
									WHEN 0 THEN 64
									WHEN 1 THEN	32
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

		[PackageEnd]			= CONVERT(DATETIME2,	[e].[end_time]),
		[PackageEndDate]		= CONVERT(DATE,			[e].[end_time]),
		[PackageEndTime]		= CONVERT(TIME,			[e].[end_time]),
		[PackageEndZone]		= [e].[end_time],

		[Duration]				= STUFF(CONVERT(VARCHAR(20), CONVERT(DATETIME, [e].[end_time]) - CONVERT(DATETIME, [e].[start_time]), 114), 1, 2,
										DATEDIFF(HOUR, 0,	 CONVERT(DATETIME, [e].[end_time]) - CONVERT(DATETIME, [e].[start_time]))),

		[DurationDays]			= DATEDIFF(SECOND, [e].[start_time], [e].[end_time]) / 86400.0,
		[DurationMinutes]		= DATEDIFF(SECOND, [e].[start_time], [e].[end_time]) / 60.0,
		[DurationSeconds]		= DATEDIFF(SECOND, [e].[start_time], [e].[end_time]),

		[PhysicalMemoryTotal_kb]		= [e].[total_physical_memory_kb],
		[PhysicalMemoryAvailable_kb]	= [e].[available_physical_memory_kb],
		[PageFileTotal_kb]				= [e].[total_page_file_kb],
		[PageFileAvailable_kb]			= [e].[available_page_file_kb],
		[Cpu_Count]						= [e].[cpu_count],
		[Executed_Count]				= [e].[executed_count],

		[MessageFails]			= STRING_AGG(CASE WHEN ([m].[message_type] = 130) THEN [m].[message] ELSE NULL END, N'') WITHIN GROUP (ORDER BY [m].[operation_message_id] DESC),
		[MessageErrors]			= STRING_AGG(CASE WHEN ([m].[message_type] = 120) THEN [m].[message] ELSE NULL END, N'') WITHIN GROUP (ORDER BY [m].[operation_message_id] DESC),
		[MessageWarnings]		= STRING_AGG(CASE WHEN ([m].[message_type] = 110) THEN [m].[message] ELSE NULL END, N'') WITHIN GROUP (ORDER BY [m].[operation_message_id] DESC)

FROM
	[$(SSISDB)].[catalog].[executions]			[e]
LEFT OUTER JOIN
	[$(SSISDB)].[catalog].[operation_messages]	[m]
	ON	([e].[execution_id]				=	[m].[operation_id])
GROUP BY
	[e].[execution_id],
	[e].[server_name],
	[e].[machine_name],
	[e].[environment_folder_name],
	[e].[environment_name],
	[e].[folder_name],
	[e].[project_name],
	[e].[package_name],
	[e].[executed_as_name],
	[e].[caller_name],
	[e].[stopped_by_name],
	[e].[use32bitruntime],
	[e].[object_type],
	[e].[status],
	[e].[operation_type],
	[e].[start_time],
	[e].[end_time],
	[e].[total_physical_memory_kb],
	[e].[available_physical_memory_kb],
	[e].[total_page_file_kb],
	[e].[available_page_file_kb],
	[e].[cpu_count],
	[e].[executed_count];