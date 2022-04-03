CREATE VIEW [track].[SqlAgentHistory]
WITH VIEW_METADATA
AS
SELECT
		[instance_id]			= CHECKSUM(@@SERVERNAME),

		[Instance]				= @@SERVERNAME,
		[InstanceHost]			= CAST(SERVERPROPERTY('MachineName') AS VARCHAR),
		[InstanceName]			= @@SERVICENAME,

	[t].[ServerName],
	[t].[JobName],
	[t].[StepMessage],
		[RunStatus]				= CASE [t].[run_status]
									WHEN 0	THEN 'Failed'
									WHEN 1	THEN 'Succeeded'
									WHEN 2	THEN 'Retry'
									WHEN 3	THEN 'Canceled'
									WHEN 4	THEN 'In Progress'
									ELSE		 'Unknown'
									END,
	[t].[RetryCount],

	[t].[JobBegin],
	[t].[JobBeginDate],
	[t].[JobBeginTime],

		[JobEnd]				= DATEADD(SECOND, [t].[DurationSeconds], [t].[JobBegin]),
		[JobEndDate]			= CONVERT(DATE, DATEADD(SECOND, [t].[DurationSeconds], [t].[JobBegin])),
		[JobEndTime]			= DATEADD(SECOND, [t].[DurationSeconds], [t].[JobBeginTime]),

		[DurationDays]			= [t].[DurationSeconds] / 86400.0,
		[DurationMinutes]		= [t].[DurationSeconds] / 60.0,
	[t].[DurationSeconds]
FROM (
	SELECT
		[t].[ServerName],
		[t].[JobName],
		[t].[StepMessage],
		[t].[run_status],
		[t].[RetryCount],

			[JobBegin]			= CONVERT(DATETIME, [t].[JobBeginDate]) + CONVERT(DATETIME, [t].[JobBeginTime]),
		[t].[JobBeginDate],
		[t].[JobBeginTime],

			[DurationSeconds]	= CONVERT(INT, LEFT([t].[Duration], 2))				* 86400 +	--	Days
									CONVERT(INT, SUBSTRING([t].[Duration], 4, 2))	* 3600 +	--	Hours
									CONVERT(INT, SUBSTRING([t].[Duration], 7, 2))	* 60 +		--	Minutes
									CONVERT(INT, RIGHT([t].[Duration], 2))						--	Seconds
	FROM (
		SELECT
			[h].[run_status],

				[ServerName]		= [v].[name],
				[JobName]			= [j].[name],
				[StepMessage]		= [h].[message],
				[RetryCount]		= [h].[retries_attempted],
				[JobBeginDate]		= CONVERT(DATE, CONVERT(CHAR(8), [h].[run_date]), 112),
				[JobBeginTime]		= CONVERT(TIME, STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CONVERT(VARCHAR(6), [h].[run_time]), 6), 5, 0, ':'), 3, 0, ':'), 120),
				[Duration]			= STUFF(STUFF(STUFF(RIGHT(REPLICATE('0', 8) + CONVERT(VARCHAR(8), [h].[run_duration]), 8), 3, 0, ':'), 6, 0, ':'), 9, 0, ':')
		FROM
			[msdb].[dbo].[sysjobs]						[j]
		INNER JOIN
			[msdb].[sys].[servers]						[v]
				ON	([j].[originating_server_id]	=	[v].[server_id])
		INNER JOIN
			[msdb].[dbo].[sysjobhistory]				[h]
				ON	([j].[job_id]					=	[h].[job_id])
		WHERE
			([h].[step_id] = 0)
		) [t]
	) [t];