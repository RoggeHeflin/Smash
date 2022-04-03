CREATE VIEW [smash].[SystemVolumes]
WITH VIEW_METADATA
AS
SELECT
		[instance_id]			= CHECKSUM(@@SERVERNAME),
	[f].[database_id],
	[f].[file_id],

		[Instance]				= @@SERVERNAME,
		[InstanceHost]			= CAST(SERVERPROPERTY('MachineName') AS VARCHAR),
		[InstanceName]			= @@SERVICENAME,

		[DatabaseType]			= [smash].[SystemDatabaseType]([f].[database_id]),
		[DatabaseName]			= DB_NAME([f].[database_id]),
		[FileType]				= CASE [f].[type]
									WHEN	0	THEN 'Rows'
									WHEN	1	THEN 'Log'
									END,

		[FileName]				= [f].[name],
		[FileNamePhysical]		= [f].[physical_name],

		[FileState]				= CASE [f].[state]
									WHEN	0	THEN 'Online'
									WHEN	1	THEN 'Restoring'
									WHEN	2	THEN 'Recovering'
									WHEN	3	THEN 'Recovery Pending'
									WHEN	4	THEN 'Suspect'
									WHEN	5	THEN 'Internal'
									WHEN	6	THEN 'Offline'
									WHEN	7	THEN 'Defunct'
									WHEN	8	THEN 'Online'
									END,

		[FileSizePages]			= [f].[size],
		[FileSizeKb]			= CONVERT(FLOAT, [f].[size]) * 8.0 / 1000,
		[FileSizeMb]			= CONVERT(FLOAT, [f].[size]) * 8.0 / 1000000.0,
		[FileSizeGb]			= CONVERT(FLOAT, [f].[size]) * 8.0 / 1000000000.0,

		[FileSizeMax]			= [f].[max_size],

		[FileSizeGrowthKb]		= IIF(([f].[is_percent_growth] = 0), [f].[growth],			NULL),
		[FileSizeGrowthMb]		= IIF(([f].[is_percent_growth] = 0), [f].[growth] / 1000.0, NULL),
		[FileSizeGrowthPcnt]	= IIF(([f].[is_percent_growth] = 1), [f].[growth] / 100.0,	NULL),

		[VolumeMountPoint]		= [v].[volume_mount_point],
		[VolumeNameLogical]		= [v].[logical_volume_name],
		[VolumeFileType]		= [v].[file_system_type],

		[VolumeSizeTotalMb]		= CONVERT(FLOAT, [v].[total_bytes])							/ 1000000.0,	--	1048576.0,
		[VolumeSizeAvailableMb]	= CONVERT(FLOAT, [v].[available_bytes])						/ 1000000.0,
		[VolumeSizeUsedMb]		= CONVERT(FLOAT, [v].[total_bytes] - [v].[available_bytes])	/ 1000000.0,

		[VolumeSizeTotalGb]		= CONVERT(FLOAT, [v].[total_bytes])							/ 1000000000.0,	--	1073741824.0
		[VolumeSizeAvailableGb]	= CONVERT(FLOAT, [v].[available_bytes])						/ 1000000000.0,
		[VolumeSizeUsedGb]		= CONVERT(FLOAT, [v].[total_bytes] - [v].[available_bytes])	/ 1000000000.0,

		[VolumeAvailablePcnt]	=		CONVERT(FLOAT, [v].[available_bytes]) / CONVERT(FLOAT, [v].[total_bytes]),
		[VolumeUsedPcnt]		= 1.0 - CONVERT(FLOAT, [v].[available_bytes]) / CONVERT(FLOAT, [v].[total_bytes])
FROM
	sys.master_files		[f]
CROSS APPLY
	sys.dm_os_volume_stats([f].[database_id], [f].[file_id])	[v];