CREATE VIEW [smash].[SystemConfiguration]
WITH VIEW_METADATA
AS
SELECT
		[instance_id]				= CHECKSUM(@@SERVERNAME),
	[t].[configuration_id],

		[Instance]					= @@SERVERNAME,
		[InstanceHost]				= CAST(SERVERPROPERTY('MachineName') AS VARCHAR),
		[InstanceName]				= @@SERVICENAME,

		[ConfigurationName]			= [t].[name],
		[ConfigurationDescription]	= [t].[description],

		[CurrentValue]				= [t].[value],
		[InUseValue]				= [t].[value_in_use],

		[MinimumValue]				= [t].[minimum],
		[MaximumValue]				= [t].[maximum],

		[IsDynamic]					= CASE [t].[is_dynamic]
										WHEN 0	THEN 'Satic'
										WHEN 1	THEN 'Dynamic'
										END,

		[IsAdvanced]				= CASE [t].[is_advanced]
										WHEN 0	THEN 'Standard'
										WHEN 1	THEN 'Advanced'
										END
FROM
	sys.configurations	[t];