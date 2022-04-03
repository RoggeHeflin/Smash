CREATE VIEW [smash].[SystemInstance]
WITH VIEW_METADATA
AS
SELECT
	[instance_id]				= CHECKSUM(@@SERVERNAME),
	[Instance]					= @@SERVERNAME,
	[InstanceHost]				= CAST(SERVERPROPERTY('MachineName') AS VARCHAR),
	[InstanceName]				= @@SERVICENAME,

	[HostPlatform]				= [h].[host_platform],
	[HostDistribution]			= [h].[host_distribution],
	[HostRelease]				= [h].[host_release],
	[HostServicePack]			= [h].[host_service_pack_level],
	[HostSku]					= [h].[host_sku],
	[HostLanguageVersion]		= [h].[os_language_version],
	[HostArchitecture]			= 'X64',
	--[HostArchitecture]			= [h].[host_architecture],	/*	Column is available in sys.dm_os_host_info	*/

	[HostContainterType]		= [s].[container_type_desc],
	[HostType]					= [s].[virtual_machine_type_desc],

	[HostLanguageName]			= [l].[name],
	[HostLanguageAlias]			= [l].[name],
	--[HostLanguageAlias]			= [l].[alias],				/*	Column is available in sys.syslanguages		*/

	[CpuSocketCount]			= [s].[socket_count],
	[CpuSocketCores]			= [s].[cores_per_socket],
	[CpuThreads]				= [s].[cpu_count],
	[CpuSocketCoreThreads]		= [s].[cpu_count] / [s].[cores_per_socket],
	[CpuHyperthreadRatio]		= [s].[hyperthread_ratio],

	[NumaNodeCount]				= [s].[numa_node_count],
	[NumaNodeDescription]		= [s].[softnuma_configuration_desc],

	[InstanceDescription]		= REPLACE(@@VERSION, N'(C)', '©'),
	[InstanceVersion]			= CONVERT(VARCHAR, SERVERPROPERTY('ProductVersion')),

	[InstanceEdition]			= CONVERT(VARCHAR, SERVERPROPERTY('Edition')),
	[InstanceProductLevel]		= CONVERT(VARCHAR, SERVERPROPERTY('ProductLevel')),
	[InstanceProductBuildType]	= CONVERT(VARCHAR, SERVERPROPERTY('ProductBuildType')),
	[InstanceLanguage]			= @@LANGUAGE,
	[InstanceProcessId]			= CONVERT(VARCHAR, SERVERPROPERTY('ProcessID')),
	
	[InstanceMemoryModel]		= [s].[sql_memory_model_desc],
	[InstanceCpuAffinity]		= [s].[affinity_type_desc],
	[InstanceStartTime]			= [s].[sqlserver_start_time],

	[WokerCountTotal]			= [s].[max_workers_count],
	[SchedulerCount]			= [s].[scheduler_count],
	[SchedulerCountTotal]		= [s].[scheduler_total_count],

	[MemoryState]				= [m].[system_memory_state_desc],

	[MemoryPhysicalGb]			= [s].[physical_memory_kb]				/ 1000000.0,
	[MemoryVirtualGb]			= [s].[virtual_memory_kb]				/ 1000000.0,
	[MemoryCommittedGb]			= [s].[committed_kb]					/ 1000000.0,
	[MemoryCommittedTargetGb]	= [s].[committed_target_kb]				/ 1000000.0,
	[MemoryStackSizeMb]			= [s].[stack_size_in_bytes]				/ 1000000.0,

	[MemoryPhysicalAvailableGb]	= [m].[available_physical_memory_kb]	/ 1000000.0,
	[MemoryPageFileTotalGb]		= [m].[total_page_file_kb]				/ 1000000.0,
	[MemoryPageFileAvailableGb]	= [m].[available_page_file_kb]			/ 1000000.0,

	[MemorySystemCacheMb]		= [m].[system_cache_kb]					/ 1000.0,
	[MemoryKernelPagedMb]		= [m].[kernel_paged_pool_kb]			/ 1000.0,
	[MemoryKernelNonpagedMb]	= [m].[kernel_nonpaged_pool_kb]			/ 1000.0

FROM
	sys.dm_os_host_info			[h]
INNER JOIN
	sys.fulltext_languages		[l]
		ON	([h].[os_language_version]	=	[l].[lcid])
--INNER JOIN
--	sys.syslanguages			[l]
--		ON	([h].[os_language_version]	=	[l].[lcid])
CROSS JOIN
	sys.dm_os_sys_info			[s]
CROSS JOIN
	sys.dm_os_sys_memory		[m];