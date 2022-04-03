CREATE VIEW [smash].[SystemInstanceCpu]
WITH VIEW_METADATA
AS
WITH
	[L5]	AS(SELECT [n] = 1 UNION ALL SELECT 1),					--	    2
	[L4]	AS(SELECT [n] = 1 FROM [L5] [a] CROSS JOIN [L5] [b]),	--	    4
	[L3]	AS(SELECT [n] = 1 FROM [L4] [a] CROSS JOIN [L4] [b]),	--	   16
	[L2]	AS(SELECT [n] = 1 FROM [L3] [a] CROSS JOIN [L3] [b]),	--	  256
	[L1]	AS(SELECT [n] = 1 FROM [L2] [a] CROSS JOIN [L2] [b]),	--	65536
	[v]		AS(SELECT [Items] = ROW_NUMBER() OVER(ORDER BY (SELECT(NULL))) - 1 FROM [L1])
SELECT
		[instance_id]	= CHECKSUM(@@SERVERNAME),
	[t].[ObjectIndex],

		[Instance]		= @@SERVERNAME,
		[InstanceHost]	= CAST(SERVERPROPERTY('MachineName') AS VARCHAR),
		[InstanceName]	= @@SERVICENAME,

	[t].[ObjectType],
		[ItemPcnt]		= 1.0 / COUNT(*) OVER(PARTITION BY [t].[ObjectType]),
		[ItemColor]		= [t].[ObjectIndex] % [t].[cores_per_socket]
FROM (
	SELECT DISTINCT
		[u].[cores_per_socket],
		[u].[ObjectType],
		[u].[ObjectIndex]
	FROM (
		SELECT TOP(65536)
			[s].[cores_per_socket],
				[Sockets]		= [v].[Items] / [s].[cpu_count],
				[Cores]			= [v].[Items] / ([s].[cpu_count] / [s].[cores_per_socket]),
				[Threads]		= [v].[Items]
		FROM
			[v]
		CROSS JOIN (
			SELECT
				[s].[socket_count],
				[s].[cores_per_socket],
				[s].[cpu_count]
			FROM
				sys.dm_os_sys_info	[s]
			) [s]
		WHERE
			([v].[Items] < [s].[cpu_count])
		) [t]
	UNPIVOT (
		[ObjectIndex] FOR [ObjectType] IN (
			[Sockets],
			[Cores],
			[Threads]
			)
		) [u]
	) [t];