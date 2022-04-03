CREATE PROCEDURE [smash].[Select_SystemDatabaseFiles]
AS
BEGIN

	SET NOCOUNT ON;
	SET LOCK_TIMEOUT 100;
	SET DEADLOCK_PRIORITY HIGH;

	DECLARE @TxnCount		INT				= @@TRANCOUNT;
	DECLARE @TxnActive		VARCHAR(32)		= REPLACE(CONVERT(VARCHAR(36), NEWID(), 0), '-', '');
	DECLARE @ErrorCode		INT				= 0;

	IF (@TxnCount = 0) BEGIN TRANSACTION @TxnActive ELSE SAVE TRANSACTION @TxnActive;
	BEGIN TRY
	-----------------------------------------------------------------------------------------------

		DROP TABLE IF EXISTS #ReturnTable_FileSpaceUsage;

		CREATE TABLE #ReturnTable_FileSpaceUsage
		(
			[ReturnTableId]					INT					NOT	NULL	IDENTITY(1, 1) NOT FOR REPLICATION,

			[instance_id]					INT					NOT	NULL,
			[database_id]					SMALLINT			NOT	NULL,
			[file_id]						SMALLINT			NOT	NULL,
			[filegroup_id]					SMALLINT			NOT	NULL,

			[total_page_count]						BIGINT		NOT	NULL,
			[allocated_extent_page_count]			BIGINT		NOT	NULL,
			[unallocated_extent_page_count]			BIGINT		NOT	NULL,
			[version_store_reserved_page_count]		BIGINT			NULL,
			[user_object_reserved_page_count]		BIGINT			NULL,
			[internal_object_reserved_page_count]	BIGINT			NULL,
			[mixed_extent_page_count]				BIGINT		NOT	NULL,
			[modified_extent_page_count]			BIGINT		NOT	NULL,

			PRIMARY KEY CLUSTERED([ReturnTableId]	ASC)
		);

		DECLARE	@SqlBase		NVARCHAR(MAX)	= N'
		INSERT INTO #ReturnTable_FileSpaceUsage
		(
			[instance_id],
			[database_id],
			[file_id],
			[filegroup_id],

			[total_page_count],
			[allocated_extent_page_count],
			[unallocated_extent_page_count],
			[version_store_reserved_page_count],
			[user_object_reserved_page_count],
			[internal_object_reserved_page_count],
			[mixed_extent_page_count],
			[modified_extent_page_count]
		)
		SELECT
				[instance_id]		= CHECKSUM(@@SERVERNAME),
			[t].[database_id],
			[t].[file_id],
			[t].[filegroup_id],

			[t].[total_page_count],
			[t].[allocated_extent_page_count],
			[t].[unallocated_extent_page_count],
			[t].[version_store_reserved_page_count],
			[t].[user_object_reserved_page_count],
			[t].[internal_object_reserved_page_count],
			[t].[mixed_extent_page_count],
			[t].[modified_extent_page_count]
		FROM
			[$(DatabaseName)].sys.dm_db_file_space_usage	[t];';

		DECLARE @DbName			NVARCHAR(128)	= N'';
		DECLARE @SqlCommand		NVARCHAR(MAX);

		WHILE (@DbName IS NOT NULL)
		BEGIN

			SELECT
				@DbName = MIN([d].[name])
			FROM
				sys.databases	[d]
			WHERE
				([d].[name]	> @DbName);

			SET @SqlCommand = REPLACE(@SqlBase, N'$(DatabaseName)', @DbName);

			PRINT CONVERT(NCHAR(23), SYSDATETIME(), 121) + NCHAR(9) + N'Querying database [' + @DbName + N']';

			EXECUTE sp_executesql @SqlCommand;

		END;

		SELECT
				[instance_id]			= CHECKSUM(@@SERVERNAME),
			[f].[database_id],
			[f].[file_id],
			[u].[filegroup_id],

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
				[FileSizeKb]			= CONVERT(FLOAT, [f].[size]) * 8.0,
				[FileSizeMb]			= CONVERT(FLOAT, [f].[size]) * 8.0 / 1000.0,
				[FileSizeGb]			= CONVERT(FLOAT, [f].[size]) * 8.0 / 1000000.0,

				[FileSizeMax]			= [f].[max_size],

				[FileSizeGrowthKb]		= IIF(([f].[is_percent_growth] = 0), [f].[growth],			NULL),
				[FileSizeGrowthMb]		= IIF(([f].[is_percent_growth] = 0), [f].[growth] / 1000.0, NULL),
				[FileSizeGrowthPcnt]	= IIF(([f].[is_percent_growth] = 1), [f].[growth] / 100.0,	NULL),

				[FileSpaceTotalPages]					= [u].[total_page_count],
				[FileSpaceAllocatedPages]				= [u].[allocated_extent_page_count],
				[FileSpaceUnallocatedPages]				= [u].[unallocated_extent_page_count],
				[FileSpaceReservedVersionPages]			= [u].[version_store_reserved_page_count],
				[FileSpaceReservedUserObjectPages]		= [u].[user_object_reserved_page_count],
				[FileSpaceReservedInternalObjectPages]	= [u].[internal_object_reserved_page_count],

				[FileSpaceExtentMixedPages]				= [u].[mixed_extent_page_count],
				[FileSpaceExtentModifiedPages]			= [u].[modified_extent_page_count],

				[FileSpaceTotalMb]			=  CONVERT(FLOAT, [u].[total_page_count])				* 8.0 / 1000.0,
				[FileSpaceAllocatedMb]		=  CONVERT(FLOAT, [u].[allocated_extent_page_count])	* 8.0 / 1000.0,
				[FileSpaceUnallocatedMb]	=  CONVERT(FLOAT, [u].[unallocated_extent_page_count])	* 8.0 / 1000.0,

				[FileSpaceTotalGb]			=  CONVERT(FLOAT, [u].[total_page_count])				* 8.0 / 1000000.0,
				[FileSpaceAllocatedGb]		=  CONVERT(FLOAT, [u].[allocated_extent_page_count])	* 8.0 / 1000000.0,
				[FileSpaceUnallocatedGb]	=  CONVERT(FLOAT, [u].[unallocated_extent_page_count])	* 8.0 / 1000000.0,

				[VolumeMountPoint]		= [v].[volume_mount_point],
				[VolumeNameLogical]		= [v].[logical_volume_name],
				[VolumeFileType]		= [v].[file_system_type],

				[VolumeSizeTotalMb]		= CONVERT(FLOAT, [v].[total_bytes])							/ 1000000.0,
				[VolumeSizeAvailableMb]	= CONVERT(FLOAT, [v].[available_bytes])						/ 1000000.0,
				[VolumeSizeUsedMb]		= CONVERT(FLOAT, [v].[total_bytes] - [v].[available_bytes]) / 1000000.0,

				[VolumeSizeTotalGb]		= CONVERT(FLOAT, [v].[total_bytes])							/ 1000000000.0,
				[VolumeSizeAvailableGb]	= CONVERT(FLOAT, [v].[available_bytes])						/ 1000000000.0,
				[VolumeSizeUsedGb]		= CONVERT(FLOAT, [v].[total_bytes] - [v].[available_bytes]) / 1000000000.0,

				[VolumeAvailablePcnt]	=		CONVERT(FLOAT, [v].[available_bytes]) / CONVERT(FLOAT, [v].[total_bytes]),
				[VolumeUsedPcnt]		= 1.0 - CONVERT(FLOAT, [v].[available_bytes]) / CONVERT(FLOAT, [v].[total_bytes])
		FROM
			sys.master_files				[f]
		LEFT OUTER JOIN
			#ReturnTable_FileSpaceUsage		[u]
				ON	([f].[database_id]	=	[u].[database_id])
				AND	([f].[file_id]		=	[u].[file_id])
		CROSS APPLY
			sys.dm_os_volume_stats([f].[database_id], [f].[file_id])	[v];

		DROP TABLE IF EXISTS #ReturnTable_FileSpaceUsage;

	-----------------------------------------------------------------------------------------------
	IF (@TxnCount = 0) COMMIT TRANSACTION @TxnActive ELSE SAVE TRANSACTION @TxnActive;
	END TRY
	BEGIN CATCH

		SET @ErrorCode = @@ERROR;

		IF (XACT_STATE() = -1) ROLLBACK	TRANSACTION	@TxnActive;
		IF (XACT_STATE() =  1) COMMIT	TRANSACTION	@TxnActive;

		THROW;

		RETURN @ErrorCode;

	END CATCH;

	RETURN @ErrorCode;

END;