CREATE VIEW [track].[SqlAgentSchedule]
WITH VIEW_METADATA
AS
WITH [cte]
(
	[idx],
	[ScheduleUid],
	[SubFrequency],
	[SubFrequencyInterval],
	[PreviousStartTime],
	[IntermediateStartTime],
	[ActiveEndTime],
	[IntervalLimit]
)
AS
(
	SELECT ALL
			[idx]						= 1,
		[a].[ScheduleUid],
		[a].[SubFrequency],
		[a].[SubFrequencyInterval],
			[PreviousStartTime]			= [a].[ActiveBeginTime],
			[IntermediateStartTime]		= [a].[ActiveBeginTime],
		[a].[ActiveEndTime],
		[a].[IntervalLimit]
	FROM
		[track].[SqlAgentScheduleBase]	[a]

	UNION ALL

	SELECT ALL
		[t].[idx],
		[t].[ScheduleUid],
		[t].[SubFrequency],
		[t].[SubFrequencyInterval],
		[t].[PreviousStartTime],
		[t].[IntermediateStartTime],
		[t].[ActiveEndTime],
		[t].[IntervalLimit]
	FROM (
		SELECT ALL
				[idx]						= [c].[idx] + 1,
			[c].[ScheduleUid],
			[c].[SubFrequency],
			[c].[SubFrequencyInterval],
				[PreviousStartTime]			= [c].[IntermediateStartTime],
				[IntermediateStartTime]		= CASE [c].[SubFrequency]
												WHEN 'Seconds'	THEN DATEADD(SECOND, [c].[SubFrequencyInterval], [c].[IntermediateStartTime])
												WHEN 'Minutes'	THEN DATEADD(MINUTE, [c].[SubFrequencyInterval], [c].[IntermediateStartTime])
												WHEN 'Hours'	THEN DATEADD(HOUR,	 [c].[SubFrequencyInterval], [c].[IntermediateStartTime])
												END,
			[c].[ActiveEndTime],
			[c].[IntervalLimit]
		FROM
			[cte]			[c]
		WHERE
				([c].[IntervalLimit]			<=	100)
			AND	([c].[SubFrequencyInterval]		>	0)
			AND	([c].[IntermediateStartTime]	<	[c].[ActiveEndTime])
			AND	([c].[idx]						<=	100)
		) [t]
	WHERE
		([t].[IntermediateStartTime] >= [t].[PreviousStartTime])
)
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

	[t].[ActiveBegin],
	[t].[ActiveBeginDate],
	[t].[ActiveBeginTime],

	[t].[ActiveEnd],
	[t].[ActiveEndDate],
	[t].[ActiveEndTime],

		[ScheduleSpanDays]			= [t].[ScheduleSpanSeconds] / 86400.0,
		[ScheduleSpanMinutes]		= [t].[ScheduleSpanSeconds] / 60.0,
	[t].[ScheduleSpanSeconds],

	[t].[NextRun],
	[t].[NextRunDate],
	[t].[NextRunTime],
	
	[c].[IntermediateStartTime]
FROM
	[track].[SqlAgentScheduleBase]	[t]
LEFT OUTER JOIN
	[cte]							[c]
		ON	([t].[ScheduleUid]	=	[c].[ScheduleUid]);