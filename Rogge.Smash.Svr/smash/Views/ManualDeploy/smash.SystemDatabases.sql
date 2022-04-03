CREATE VIEW [smash].[SystemDatabases]
WITH VIEW_METADATA
AS
SELECT
		[instance_id]				= CHECKSUM(@@SERVERNAME),
	[t].[database_id],
	[t].[source_database_id],

		[Instance]					= @@SERVERNAME,
		[InstanceHost]				= CAST(SERVERPROPERTY('MachineName') AS VARCHAR),
		[InstanceName]				= @@SERVICENAME,

		[DatabaseType]				= [smash].[SystemDatabaseType]([t].[database_id]),

		[DatabaseName]				= [t].[name],

		[SourceDatabase]			= DB_NAME([t].[source_database_id]),
		[DatabaseOwner]				= SUSER_SNAME([t].[owner_sid]),

		[DatabaseCreation]			= [t].[create_date],

		[CompatibilityLevel]		= CASE [t].[compatibility_level]
										WHEN  70	THEN '7.0'
										WHEN  80	THEN '2008 (8.x)'
										WHEN  90	THEN '2008 (9.x)'
										WHEN 100	THEN '2008 (10.x)'
										WHEN 110	THEN '2012 (11.x)'
										WHEN 120	THEN '2014 (12.x)'
										WHEN 130	THEN '2016 (13.x)'
										WHEN 140	THEN '2017 (14.x)'
										WHEN 150	THEN '2019 (15.x)'
										ELSE CONVERT(VARCHAR(3), [t].[compatibility_level])
										END,

		[CollationName]				= [t].[collation_name],

		[UserAcess]					= CASE [t].[user_access]
										WHEN 0	THEN 'Multi User'
										WHEN 1	THEN 'Single User'
										WHEN 2	THEN 'Restricted User'
										END,

		[ReadOnly]					= CASE [t].[is_read_only]
										WHEN 0	THEN 'Read Write'
										WHEN 1	THEN 'Read Only'
										END,

		[AutoClose]					= CASE [t].[is_auto_close_on]
										WHEN 0	THEN 'Off'
										WHEN 1	THEN 'On'
										END,

		[AutoShrink]				= CASE [t].[is_auto_shrink_on]
										WHEN 0	THEN 'Off'
										WHEN 1	THEN 'On'
										END,

		[DatabaseState]				= CASE [t].[state]
										WHEN  0	THEN 'Online'
										WHEN  1	THEN 'Restoring'
										WHEN  2	THEN 'Recovering'
										WHEN  3	THEN 'Recovery Pending'
										WHEN  4	THEN 'Suspect'
										WHEN  5	THEN 'Emergency'
										WHEN  6	THEN 'Offline'
										WHEN  7	THEN 'Copying'
										WHEN 10	THEN 'Offline (Secondary)'
										END,

		[IsInStandby]				= CASE [t].[is_in_standby]
										WHEN 0	THEN 'Off'
										WHEN 1	THEN 'On'
										END,

		[IsCleanlyShutdown]			= CASE [t].[is_cleanly_shutdown]
										WHEN 0	THEN 'No'
										WHEN 1	THEN 'Yes'
										END,

		[IsSupplementalLoggingEnabled]	= CASE [t].[is_supplemental_logging_enabled]
										WHEN 0	THEN 'Off'
										WHEN 1	THEN 'On'
										END,

		[SnapshotIsolationState]	= CASE [t].[snapshot_isolation_state]
										WHEN 0	THEN 'Off'
										WHEN 1	THEN 'On'
										WHEN 2	THEN 'Transition to Off'
										WHEN 3	THEN 'Transition to On'
										END,

		[IsReadCommittedSnapshot]	= CASE [t].[is_read_committed_snapshot_on]
										WHEN 0	THEN 'Off'
										WHEN 1	THEN 'On'
										END,

		[RecoveryModel]				= CASE [t].[recovery_model]
										WHEN 1	THEN 'Full'
										WHEN 2	THEN 'Bulk Logged'
										WHEN 3	THEN 'Simple'
										END,

		[PageVerify]				= CASE [t].[page_verify_option]
										WHEN 0	THEN 'None'
										WHEN 1	THEN 'Torn Page Detection'
										WHEN 2	THEN 'Checksum'
										END,

		[IsAutoCreateStatsOn]		= CASE [t].[is_auto_create_stats_on]
										WHEN 0	THEN 'Off'
										WHEN 1	THEN 'On'
										END,

		[IsAutoCreateStatsIncrementalOn]	= CASE [t].[is_auto_create_stats_incremental_on]
										WHEN 0	THEN 'Off'
										WHEN 1	THEN 'On'
										END,

		[IsAutoUpdateStatsOn]		= CASE [t].[is_auto_update_stats_on]
										WHEN 0	THEN 'Off'
										WHEN 1	THEN 'On'
										END,

		[IsAutoUpdateStatsAsyncOn]	= CASE [t].[is_auto_update_stats_async_on]
										WHEN 0	THEN 'Off'
										WHEN 1	THEN 'On'
										END,

		[IsAnsiNullDefaultOn]		= CASE [t].[is_ansi_null_default_on]
										WHEN 0	THEN 'Off'
										WHEN 1	THEN 'On'
										END,

		[IsAnsiNullsOn]				= CASE [t].[is_ansi_nulls_on]
										WHEN 0	THEN 'Off'
										WHEN 1	THEN 'On'
										END,

		[IsAnsiPaddingOn]			= CASE [t].[is_ansi_padding_on]
										WHEN 0	THEN 'Off'
										WHEN 1	THEN 'On'
										END,

		[IsAnsiWarningsOn]			= CASE [t].[is_ansi_warnings_on]
										WHEN 0	THEN 'Off'
										WHEN 1	THEN 'On'
										END,

		[IsArithabortOn]			= CASE [t].[is_arithabort_on]
										WHEN 0	THEN 'Off'
										WHEN 1	THEN 'On'
										END,

		[IsConcatNullYieldsNullOn]	= CASE [t].[is_concat_null_yields_null_on]
										WHEN 0	THEN 'Off'
										WHEN 1	THEN 'On'
										END,

		[IsNumericRoundabortOn]		= CASE [t].[is_numeric_roundabort_on]
										WHEN 0	THEN 'Off'
										WHEN 1	THEN 'On'
										END,

		[IsQuotedIdentifierOn]		= CASE [t].[is_quoted_identifier_on]
										WHEN 0	THEN 'Off'
										WHEN 1	THEN 'On'
										END,

		[IsRecursiveTriggersOn]		= CASE [t].[is_recursive_triggers_on]
										WHEN 0	THEN 'Off'
										WHEN 1	THEN 'On'
										END,

		[IsCursorCloseOnCommitOn]	= CASE [t].[is_cursor_close_on_commit_on]
										WHEN 0	THEN 'Off'
										WHEN 1	THEN 'On'
										END,

		[IsLocalCursorDefault]		= CASE [t].[is_local_cursor_default]
										WHEN 0	THEN 'Global'
										WHEN 1	THEN 'Local'
										END,

		[IsFulltextEnabled]			= CASE [t].[is_fulltext_enabled]
										WHEN 0	THEN 'Off'
										WHEN 1	THEN 'On'
										END,

		[IsTrustworthyOn]			= CASE [t].[is_trustworthy_on]
										WHEN 0	THEN 'Off'
										WHEN 1	THEN 'On'
										END,

		[IsDbChainingOn]			= CASE [t].[is_db_chaining_on]
										WHEN 0	THEN 'Off'
										WHEN 1	THEN 'On'
										END,

		[ParameterizationForced]	= CASE [t].[is_parameterization_forced]
										WHEN 0	THEN 'Simple'
										WHEN 1	THEN 'Forced'
										END,

		[IsMasterKeyEncryptedByServer]	= CASE [t].[is_master_key_encrypted_by_server]
										WHEN 0	THEN 'No'
										WHEN 1	THEN 'Yes'
										END,

		[IsQueryStoreOn]			= CASE [t].[is_query_store_on]
										WHEN 0	THEN 'Off'
										WHEN 1	THEN 'On'
										END,

		[IsPublished]				= CASE [t].[is_published]
										WHEN 0	THEN 'No'
										WHEN 1	THEN 'Yes'
										END,

		[IsMergePublished]			= CASE [t].[is_merge_published]
										WHEN 0	THEN 'No'
										WHEN 1	THEN 'Yes'
										END,

		[IsDistributor]				= CASE [t].[is_distributor]
										WHEN 0	THEN 'No'
										WHEN 1	THEN 'Yes'
										END,

		[IsSyncWithBackup]			= CASE [t].[is_sync_with_backup]
										WHEN 0	THEN 'No'
										WHEN 1	THEN 'Yes'
										END,

		[ServiceBroker]				= [t].[service_broker_guid],

		[IsBrokerEnabled]			= CASE [t].[is_broker_enabled]
										WHEN 0	THEN 'No'
										WHEN 1	THEN 'Yes'
										END,

		[LogReuseWait]				= CASE [t].[log_reuse_wait]
										WHEN  0	THEN 'Nothing'
										WHEN  1	THEN 'Checkpoint'
										WHEN  2	THEN 'Log Backup'
										WHEN  3	THEN 'Active Backup or Restore'
										WHEN  4	THEN 'Active Transaction'
										WHEN  5	THEN 'Mirroring'
										WHEN  6	THEN 'Replication'
										WHEN  7	THEN 'Snapshot Creation'
										WHEN  8	THEN 'Log Scan'
										WHEN  9	THEN 'Always On Replica'
										WHEN 10	THEN 'Internal Use (10)'
										WHEN 11	THEN 'Internal Use (11)'
										WHEN 12	THEN 'Internal Use (12)'
										WHEN 13	THEN 'Oldest Page'
										WHEN 14	THEN 'Other'
										WHEN 16	THEN 'XTP Checkpoint'
										WHEN 17	THEN 'sLog Scanning'
										END,

		[IsDateCorrelationOn]		= CASE [t].[is_date_correlation_on]
										WHEN 0	THEN 'Off'
										WHEN 1	THEN 'On'
										END,

		[IsCdcEnabled]				= CASE [t].[is_cdc_enabled]
										WHEN 0	THEN 'Off'
										WHEN 1	THEN 'On'
										END,

		[IsEncrypted]				= CASE [t].[is_encrypted]
										WHEN 0	THEN 'No'
										WHEN 1	THEN 'Yes'
										END,

		[IsHonorBrokerPriorityOn]	= CASE [t].[is_honor_broker_priority_on]
										WHEN 0	THEN 'Off'
										WHEN 1	THEN 'On'
										END,

		[ReplicaId]						= [t].[replica_id],
		[GroupDatabaseId]				= [t].[group_database_id],
		[ResourcePoolId]				= [t].[resource_pool_id],

		[DefaultLanguageLcid]			= [t].[default_language_lcid],
		[DefaultLanguageName]			= [t].[default_language_name],
		[DefaultFulltextLanguageLcid]	= [t].[default_fulltext_language_lcid],
		[DefaultFulltextLanguageName]	= [t].[default_fulltext_language_name],

		[IsNestedTriggersOn]		= CASE [t].[is_nested_triggers_on]
										WHEN 0	THEN 'Off'
										WHEN 1	THEN 'On'
										END,

		[IsTransformNoiseWordsOn]	= CASE [t].[is_transform_noise_words_on]
										WHEN 0	THEN 'Off'
										WHEN 1	THEN 'On'
										END,

		[TwoDigitYearCutoff]		= [t].[two_digit_year_cutoff],

		[Containment]				= CASE [t].[containment]
										WHEN 0	THEN 'None'
										WHEN 1	THEN 'Partial'
										END,

		[TargetRecoveryTimeSeconds]	= [t].[target_recovery_time_in_seconds],

		[DelayedDurability]			= CASE [t].[delayed_durability]
										WHEN  0	THEN 'Disabled'
										WHEN  1	THEN 'Allowed'
										WHEN  2	THEN 'Forced'
										END,

		[IsMemoryOptimizedElevateToSnapshotOn]	= CASE [t].[is_memory_optimized_elevate_to_snapshot_on]
										WHEN 0	THEN 'Off'
										WHEN 1	THEN 'On'
										END,

		[IsFederationMember]		= CASE [t].[is_federation_member]
										WHEN 0	THEN 'No'
										WHEN 1	THEN 'Yes'
										END,

		[IsRemoteDataArchiveEnabled]	= CASE [t].[is_remote_data_archive_enabled]
										WHEN 0	THEN 
											CASE WHEN ([t].[name] LIKE 'Rogge%') THEN 'On' ELSE 'Off' END
										WHEN 1	THEN 'On'
										END,

		[IsMixedPageAllocationOn]	= CASE [t].[is_mixed_page_allocation_on]
										WHEN 0	THEN 'Off'
										WHEN 1	THEN 'On'
										END,

		[IsTemporalHistoryRetentionEnabled]	= CASE [t].[is_temporal_history_retention_enabled]
										WHEN 0	THEN 'Off'
										WHEN 1	THEN 'On'
										END,

		[CatalogCollationType]		= CASE [t].[catalog_collation_type]
										WHEN 0	THEN 'Database Default'
										WHEN 1	THEN 'SQL_Latin_1_General_CP1_CI_AS'
										END,

		[PhysicalDatabaseName]		= [t].[physical_database_name],

		--[IsResultSetCachingOn]		= CASE [t].[is_result_set_caching_on]
		--								WHEN 0	THEN 'Off'
		--								WHEN 1	THEN 'On'
		--								END,

		--[IsAcceleratedDatabaseRecoveryOn]	= CASE [t].[is_accelerated_database_recovery_on]
		--								WHEN 0	THEN 'Off'
		--								WHEN 1	THEN 'On'
		--								END,

		--[IsTempdbSpillToRemoteStore]	= CASE [t].[is_tempdb_spill_to_remote_store]
		--								WHEN 0	THEN 'Off'
		--								WHEN 1	THEN 'On'
		--								END,

		--[IsStalePageDetectionOn]		= CASE[t].[is_stale_page_detection_on]
		--								WHEN 0	THEN 'Off'
		--								WHEN 1	THEN 'On'
		--								END,

		--[IsMemoryOptimizedEnabled]		= CASE [t].[is_memory_optimized_enabled]
		--								WHEN 0	THEN 'Off'
		--								WHEN 1	THEN 'On'
		--								END,

		[vizTileMapIndex]			= ROW_NUMBER() OVER(PARTITION BY [smash].[SystemDatabaseType]([t].[database_id]) ORDER BY DB_NAME([t].[database_id]) ASC),
		[vizTileMapRow]				= ROW_NUMBER() OVER(PARTITION BY [smash].[SystemDatabaseType]([t].[database_id]) ORDER BY DB_NAME([t].[database_id]) ASC),
		[vizTileMapCol]				= ROW_NUMBER() OVER(PARTITION BY [smash].[SystemDatabaseType]([t].[database_id]) ORDER BY DB_NAME([t].[database_id]) ASC)

FROM
	sys.databases	[t];