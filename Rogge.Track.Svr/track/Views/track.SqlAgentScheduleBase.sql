CREATE VIEW [track].[SqlAgentScheduleBase]
WITH VIEW_METADATA
AS
SELECT
		[instance_id]			= CHECKSUM(@@SERVERNAME),

		[Instance]				= @@SERVERNAME,
		[InstanceHost]			= CAST(SERVERPROPERTY('MachineName') AS VARCHAR),
		[InstanceName]			= @@SERVICENAME,

	[t].[ServerName],
	[t].[JobName],
	[t].[JobEnabled],
	[t].[Category],
	[t].[CategoryClass],
	[t].[CategoryType],
	[t].[OwnerName],
	[t].[ScheduleName],
	[t].[ScheduleEnabled],
	[t].[FrequencyInterval],
	[t].[Frequency],
	[t].[SubFrequencyInterval],
	[t].[SubFrequency],

		[ActiveBegin]			= CONVERT(DATETIME, [t].[ActiveBeginDate]) + CONVERT(DATETIME, [t].[ActiveBeginTime]),
	[t].[ActiveBeginDate],
	[t].[ActiveBeginTime],

		[ActiveEnd]				= CONVERT(DATETIME, [t].[ActiveEndDate]) + CONVERT(DATETIME, [t].[ActiveEndTime]),
	[t].[ActiveEndDate],
	[t].[ActiveEndTime],

		[ScheduleSpanSeconds]	= DATEDIFF(SECOND, [t].[ActiveBeginTime], [t].[ActiveEndTime]),

		[NextRun]				= CONVERT(DATETIME, [t].[NextRunDate]) + CONVERT(DATETIME, [t].[NextRunTime]),
	[t].[NextRunDate],
	[t].[NextRunTime],

	[t].[ScheduleUid],
		[IntervalLimit]			=	CASE [t].[SubFrequency]
										WHEN 'Seconds'					THEN 86000.0
										WHEN 'Minutes'					THEN  1400.0
										WHEN 'Hours'					THEN    24.0
										WHEN 'At the specified time'	THEN	NULL
										ELSE 1.0
										END / CONVERT(FLOAT, [t].[SubFrequencyInterval])
FROM (
	SELECT
		[ServerName]			= [v].[name],
		[JobName]				= [j].[name],
		[JobEnabled]			= CASE [j].[enabled]
									WHEN 1 THEN 'Enabled'
									WHEN 0 THEN 'Disabled'
									ELSE		'Unknown'
									END,
		[Category]				= [c].[name],
		[CategoryClass]			= CASE [c].[category_class]
									WHEN 1 THEN 'Job'
									WHEN 2 THEN 'Alert'
									WHEN 3 THEN 'Operator'
									ELSE		'Unknown'
									END,
		[CategoryType]			= CASE [c].[category_type]
									WHEN 1 THEN 'Local'
									WHEN 2 THEN 'Multiserver'
									WHEN 3 THEN 'None'
									ELSE		'Unknown'
									END,
		[OwnerName]				= [p].[name],
		[ScheduleName]			= [s].[name],
		[ScheduleEnabled]		= CASE [s].[enabled]
									WHEN 1 THEN 'Enabled'
									WHEN 0 THEN 'Disabled'
									ELSE		'Unknown'
									END,
	
		[FrequencyInterval]		= [s].[freq_interval],
		[Frequency]				= CASE [s].[freq_type]
									WHEN   1	THEN 'One time only'
									WHEN   4	THEN 'Daily'
									WHEN   8	THEN 'Weekly'
									WHEN  16	THEN 'Monthly'
									WHEN  32	THEN 'Monthly, relative to freq_interval'
									WHEN  64	THEN 'SQL Server Agent service starts'
									WHEN 128	THEN 'Idle'
									ELSE			 'Unknown'
									END,

		[SubFrequencyInterval]	= [s].[freq_subday_interval],
		[SubFrequency]			= CASE [s].[freq_subday_type]
									WHEN 1 THEN 'At the specified time'
									WHEN 2 THEN 'Seconds'
									WHEN 4 THEN 'Minutes'
									WHEN 8 THEN 'Hours'
									ELSE		'Unknown'
									END,
		[ActiveBeginDate]		= CONVERT(DATE, RIGHT(REPLICATE('0', 8) + CONVERT(CHAR(8), [s].[active_start_date]), 8), 112),
		[ActiveBeginTime]		= CONVERT(TIME, STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CONVERT(VARCHAR(6), [s].[active_start_time]),	6), 5, 0, ':'), 3, 0, ':'), 120),

		[ActiveEndDate]			= CASE WHEN ([s].[freq_subday_type] = 1)
									THEN NULL
									ELSE CONVERT(DATE, RIGHT(REPLICATE('0', 8) + CONVERT(CHAR(8), [s].[active_end_date]), 8), 112)
									END,
		[ActiveEndTime]			= CASE WHEN ([s].[freq_subday_type] = 1)
									THEN NULL
									ELSE CONVERT(TIME, STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CONVERT(VARCHAR(6), [s].[active_end_time]), 6), 5, 0, ':'), 3, 0, ':'), 120)
									END,

		[NextRunDate]			= CASE WHEN ([z].[next_run_date] > 0) THEN
									CONVERT(DATE, RIGHT(REPLICATE('0', 8) + CONVERT(CHAR(8), [z].[next_run_date]), 8), 112)
									END,
		[NextRunTime]			= CONVERT(TIME, STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CONVERT(VARCHAR(6), [z].[next_run_time]), 6), 5, 0, ':'), 3, 0, ':'), 120),

		[ScheduleUid]			= [s].[schedule_uid]
	FROM
		[msdb].[dbo].[sysjobs]						[j]
	LEFT OUTER JOIN
		[msdb].[sys].[servers]						[v]
			ON	([j].[originating_server_id]	=	[v].[server_id])
	LEFT OUTER JOIN
		[msdb].[dbo].[syscategories]				[c]
			ON	([j].[category_id]				=	[c].[category_id])
	LEFT OUTER JOIN
		[msdb].[sys].[database_principals]			[p]
			ON	([j].[owner_sid]				=	[p].[sid])
	LEFT OUTER JOIN
		[msdb].[dbo].[sysjobschedules]				[z]
			ON	([j].[job_id]					=	[z].[job_id])
	LEFT OUTER JOIN
		[msdb].[dbo].[sysschedules]					[s]
			ON	([z].[schedule_id]				=	[s].[schedule_id])
	) [t];