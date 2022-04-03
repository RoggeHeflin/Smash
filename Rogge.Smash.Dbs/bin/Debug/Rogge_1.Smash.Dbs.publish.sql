﻿/*
Deployment script for DrillingInfo

This code was generated by a tool.
Changes to this file may cause incorrect behavior and will be lost if
the code is regenerated.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "DrillingInfo"
:setvar DefaultFilePrefix "DrillingInfo"
:setvar DefaultDataPath "D:\Data SQL Server\Data\"
:setvar DefaultLogPath "D:\Data SQL Server\Log\"

GO
:on error exit
GO
/*
Detect SQLCMD mode and disable script execution if SQLCMD mode is not supported.
To re-enable the script after enabling SQLCMD mode, execute the following:
SET NOEXEC OFF; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'SQLCMD mode must be enabled to successfully execute this script.';
        SET NOEXEC ON;
    END


GO
USE [$(DatabaseName)];


GO
PRINT N'Creating Schema [smash]...';


GO
CREATE SCHEMA [smash]
    AUTHORIZATION [dbo];


GO
PRINT N'Creating View [smash].[DatabaseIndexes]...';


GO
CREATE VIEW [smash].[DatabaseIndexes]
WITH VIEW_METADATA
AS
SELECT
		[database_id]				= DB_ID(),
	[s].[schema_id],
	[o].[object_id],
	[i].[index_id],
	
		[index_bcsid]				= BINARY_CHECKSUM([o].[object_id], [i].[index_id]),

		[ServerName]				= @@SERVERNAME,
		[DatabaseName]				= DB_NAME(),
		[SchemaName]				= [s].[name],
		[TableName]					= [o].[name],
		[IndexName]					= COALESCE([i].[name], 'Heap'),

	[i].[type],
		[IndexType]					= CASE [i].[type]
										WHEN 0	THEN 'Heap'
										WHEN 1	THEN 'Clustered (Rowstore)'
										WHEN 2	THEN 'Nonclustered (Rowstore)'
										WHEN 3	THEN 'XML'
										WHEN 4	THEN 'Spatial'
										WHEN 5	THEN 'Clustered (Columnstore)'
										WHEN 6	THEN 'Nonclustered (Columnstore)'
										WHEN 7	THEN 'Nonclustered (Hash)'
										END,

	[i].[is_unique],
	[i].[data_space_id],
	[i].[ignore_dup_key],

	[i].[is_primary_key],
	[i].[is_unique_constraint],

	[i].[fill_factor],
	[i].[is_padded],
	[i].[is_disabled],
	[i].[is_hypothetical],
	[i].[is_ignored_in_optimization],

	[i].[allow_row_locks],
	[i].[allow_page_locks],

	[i].[has_filter],
	[i].[filter_definition],
	[i].[compression_delay],
	[i].[suppress_dup_key_messages],
	[i].[auto_created]
	--[i].[optimize_for_sequential_key]

FROM
	sys.schemas						[s]
INNER JOIN
	sys.objects						[o]
		ON	([s].[schema_id]	=	[o].[schema_id])
		AND	([o].[type]			IN	('U', 'V'))
INNER JOIN
	sys.indexes						[i]
		ON	([o].[object_id]	=	[i].[object_id])
WHERE
	([s].[name]		<>	'sys');
GO
PRINT N'Creating Function [smash].[ObjectType]...';


GO
CREATE FUNCTION [smash].[ObjectType]
(
	@Type	VARCHAR(2)
)
RETURNS VARCHAR(40)
WITH SCHEMABINDING
AS
BEGIN

	DECLARE @Return	VARCHAR(40)

	SET @Return = CASE @Type
		WHEN 'AF'	THEN 'Function: Aggregate CLR'
		WHEN 'C'	THEN 'Constraint: Check'
		WHEN 'D'	THEN 'Constraint: Default'
		WHEN 'F'	THEN 'Constraint: Key: Foreign'

		WHEN 'FN'	THEN 'Function: SQL Scalar'
		WHEN 'FS'	THEN 'Function: CLR Assembly Scalar'
		WHEN 'FT'	THEN 'Function: CLR Assembly Table-valued'
		WHEN 'IF'	THEN 'Function: SQL Inline Table-valued'

		WHEN 'IT'	THEN 'Table: Internal'
		WHEN 'P'	THEN 'Stored Procedure: SQL'
		WHEN 'PC'	THEN 'Stored Procedure: CLR'

		WHEN 'PG'	THEN 'Plan Guide'
		WHEN 'PK'	THEN 'Constraint: Key: Primary'
		WHEN 'R'	THEN 'Rule (old-style, stand-alone)'
		WHEN 'RF'	THEN 'Replication-filter-procedure'
		WHEN 'S'	THEN 'Table: System Base'
		WHEN 'SN'	THEN 'Synonym'
		WHEN 'SO'	THEN 'Sequence Object'
		WHEN 'U'	THEN 'Table: User Defined'
		WHEN 'V'	THEN 'View'
		WHEN 'EC'	THEN 'Constraint: Edge'

		-- 'Applies to: SQL Server 2012 (11.x) and later.'
		WHEN 'SQ'	THEN 'Service Queue'
		WHEN 'TA'	THEN 'Trigger: Assembly (CLR) DML'
		WHEN 'TF'	THEN 'Function: SQL Table-valued'
		WHEN 'TR'	THEN 'Trigger: SQL DML'
		WHEN 'TT'	THEN 'Table Type'
		WHEN 'UQ'	THEN 'Constraint: Unique'
		WHEN 'X'	THEN 'Stored Procedure: Extended'

		-- 'Applies to: SQL Server 2016 (13.x) and later, Azure SQL Database, Azure Synapse Analytics (SQL Data Warehouse), Parallel Data Warehouse.'
		WHEN 'ET'	THEN 'Table: External'
		END

	RETURN @Return;

END;
GO
PRINT N'Creating Function [smash].[ObjectGroup]...';


GO
CREATE FUNCTION [smash].[ObjectGroup]
(
	@Type	VARCHAR(2)
)
RETURNS VARCHAR(40)
WITH SCHEMABINDING
AS
BEGIN

	DECLARE @Return	VARCHAR(40)

	SET @Return = CASE @Type
		WHEN 'AF'	THEN 'Function'
		WHEN 'C'	THEN 'Constraint'
		WHEN 'D'	THEN 'Constraint'
		WHEN 'F'	THEN 'Key: Foreign'

		WHEN 'FN'	THEN 'Function'
		WHEN 'FS'	THEN 'Function'
		WHEN 'FT'	THEN 'Function'
		WHEN 'IF'	THEN 'Function'

		WHEN 'IT'	THEN 'Table'
		WHEN 'P'	THEN 'Stored Procedure'
		WHEN 'PC'	THEN 'Stored Procedure'

		WHEN 'PG'	THEN 'Plan guide'
		WHEN 'PK'	THEN 'Key: Primary'
		WHEN 'R'	THEN 'Rule (old-style, stand-alone)'
		WHEN 'RF'	THEN 'Replication-filter-procedure'
		WHEN 'S'	THEN 'Table'
		WHEN 'SN'	THEN 'Synonym'
		WHEN 'SO'	THEN 'Sequence Object'
		WHEN 'U'	THEN 'Table'
		WHEN 'V'	THEN 'View'
		WHEN 'EC'	THEN 'Constraint'

		-- 'Applies to: SQL Server 2012 (11.x) and later.'
		WHEN 'SQ'	THEN 'Service Queue'
		WHEN 'TA'	THEN 'Trigger'
		WHEN 'TF'	THEN 'Function'
		WHEN 'TR'	THEN 'Trigger'
		WHEN 'TT'	THEN 'Table Type'
		WHEN 'UQ'	THEN 'Constraint'
		WHEN 'X'	THEN 'Stored Procedure'

		-- 'Applies to: SQL Server 2016 (13.x) and later, Azure SQL Database, Azure Synapse Analytics (SQL Data Warehouse), Parallel Data Warehouse.'
		WHEN 'ET'	THEN 'Table'
		END

	RETURN @Return;

END;
GO
PRINT N'Creating Function [smash].[DoesIndexExist]...';


GO
CREATE FUNCTION [smash].[DoesIndexExist]
(
	@Schema		NVARCHAR(128),
	@Table		NVARCHAR(128),
	@Index		NVARCHAR(128)
)
RETURNS INT
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN

	DECLARE	@Exists		INT;

	SELECT TOP (1)
		@Exists = 1
	FROM
		sys.schemas						[s]	WITH (NOLOCK)
	INNER JOIN
		sys.tables						[t]	WITH (NOLOCK)
			ON	([s].[schema_id]	=	[t].[schema_id])
	INNER JOIN
		sys.indexes						[i]	WITH (NOLOCK)
			ON	([t].[object_id]	=	[i].[object_id])
	WHERE
			([s].[name]	= @Schema)
		AND	([t].[name]	= @Table)
		AND	([i].[name]	= @Index);

	RETURN COALESCE(@Exists, 0);

END;
GO
PRINT N'Creating View [smash].[DatabaseIndexesPartitions]...';


GO
CREATE VIEW [smash].[DatabaseIndexesPartitions]
WITH VIEW_METADATA
AS
SELECT
		[database_id]				= DB_ID(),
	[s].[schema_id],
	[o].[object_id],
	[i].[index_id],
	[p].[partition_id],

		[index_bcsid]				= BINARY_CHECKSUM([o].[object_id], [i].[index_id]),
		[partition_bcsid]			= BINARY_CHECKSUM([o].[object_id], [i].[index_id], [p].[partition_id]),

		[ServerName]				= @@SERVERNAME,
		[DatabaseName]				= DB_NAME(),
		[SchemaName]				= [s].[name],
		[TableName]					= [o].[name],
		[IndexName]					= COALESCE([i].[name], 'Heap'),

		[ObjectGroup]				= [smash].[ObjectGroup]([o].[type]),
		[ObjectType]				= [smash].[ObjectType]([o].[type]),

		[IsRowCount]				= IIF(([i].[index_id] <= 1), 1, 0),

		[IndexType]					= CASE [i].[type]
										WHEN 0	THEN 'Heap'
										WHEN 1	THEN 'Clustered (Rowstore)'
										WHEN 2	THEN 'Nonclustered (Rowstore)'
										WHEN 3	THEN 'XML'
										WHEN 4	THEN 'Spatial'
										WHEN 5	THEN 'Clustered (Columnstore)'
										WHEN 6	THEN 'Nonclustered (Columnstore)'
										WHEN 7	THEN 'Nonclustered (Hash)'
										END,

	[i].[is_unique],
	[i].[data_space_id],
	[i].[ignore_dup_key],

	[i].[is_primary_key],
	[i].[is_unique_constraint],

	[i].[fill_factor],
	[i].[is_padded],
	[i].[is_disabled],
	[i].[is_hypothetical],
	[i].[is_ignored_in_optimization],

	[i].[allow_row_locks],
	[i].[allow_page_locks],

	[i].[has_filter],
	[i].[filter_definition],
	[i].[compression_delay],
	[i].[suppress_dup_key_messages],
	[i].[auto_created],
	--[i].[optimize_for_sequential_key]

	[p].[partition_number],
	[p].[rows],
	[p].[data_compression],
		[CompressionType]		= CASE [p].[data_compression]
									WHEN 0	THEN 'None'
									WHEN 1	THEN 'Row'
									WHEN 2	THEN 'Page'
									WHEN 3	THEN 'Columnstore'
									WHEN 4	THEN 'Columnstore (Archive)'
									END
FROM
	sys.schemas						[s]
INNER JOIN
	sys.objects						[o]
		ON	([s].[schema_id]	=	[o].[schema_id])
		AND	([o].[type]			IN	('U', 'V', 'IT', 'S'))
INNER JOIN
	sys.indexes						[i]
		ON	([o].[object_id]	=	[i].[object_id])
INNER JOIN
	sys.partitions					[p]
		ON	([i].[object_id]	=	[p].[object_id])
		AND	([i].[index_id]		=	[p].[index_id])
WHERE
	([s].[name]		<>	'sys');
GO
PRINT N'Creating View [smash].[DatabaseIndexesFragmentation]...';


GO
CREATE VIEW [smash].[DatabaseIndexesFragmentation]
WITH VIEW_METADATA
AS
SELECT
	[t].[database_id],
	[t].[schema_id],
	[t].[object_id],
	[t].[index_id],
	[t].[partition_id],

	[t].[index_bcsid],
	[t].[partition_bcsid],

	[t].[ServerName],
	[t].[DatabaseName],
	[t].[SchemaName],
	[t].[TableName],
	[t].[IndexName],

	[t].[ObjectGroup],
	[t].[ObjectType],

	[t].[IsRowCount],

	[t].[IndexType],

	[t].[is_unique],
	[t].[data_space_id],
	[t].[ignore_dup_key],

	[t].[is_primary_key],
	[t].[is_unique_constraint],

	[t].[fill_factor],
	[t].[is_padded],
	[t].[is_disabled],
	[t].[is_hypothetical],
	[t].[is_ignored_in_optimization],

	[t].[allow_row_locks],
	[t].[allow_page_locks],

	[t].[has_filter],
	[t].[filter_definition],
	[t].[compression_delay],
	[t].[suppress_dup_key_messages],
	[t].[auto_created],
	--[i].[optimize_for_sequential_key]

	[t].[partition_number],
	[t].[rows],
	[t].[data_compression],
	[t].[CompressionType],

	[f].[index_depth],
	[f].[index_level],

	[f].[fragment_count],
	[f].[record_count],
	[f].[page_count],
		[total_mb]						= (8.0 / 1024.0 * [f].[page_count]),

	[f].[avg_page_space_used_in_percent],

	[f].[avg_fragment_size_in_pages],
		[avg_fragment_size_in_kb]		= (8.0 * [f].[avg_fragment_size_in_pages]),
		[avg_fragment_size_in_mb]		= (8.0 / 1024.0 * [f].[avg_fragment_size_in_pages]),

		[avg_fragmentation_in_percent]	= ([f].[avg_fragmentation_in_percent] / 100.0),

	[f].[avg_record_size_in_bytes],
	[f].[min_record_size_in_bytes],
	[f].[max_record_size_in_bytes]

FROM
	[smash].[DatabaseIndexesPartitions]		[t]
CROSS APPLY
	sys.dm_db_index_physical_stats([t].[database_id], [t].[object_id], [t].[index_id], [t].[partition_number], 'DETAILED')	[f];
GO
PRINT N'Creating View [smash].[DatabaseIndexesAllocation]...';


GO
CREATE VIEW [smash].[DatabaseIndexesAllocation]
WITH VIEW_METADATA
AS
SELECT
		[database_id]				= DB_ID(),
	[s].[schema_id],
	[o].[object_id],
	[i].[index_id],
	[p].[partition_id],

		[index_bcsid]				= BINARY_CHECKSUM([o].[object_id], [i].[index_id]),
		[partition_bcsid]			= BINARY_CHECKSUM([o].[object_id], [i].[index_id], [p].[partition_id]),
		[allocation_bcsid]			= BINARY_CHECKSUM([o].[object_id], [i].[index_id], [p].[partition_id], [a].[type]),

		[ServerName]				= @@SERVERNAME,
		[DatabaseName]				= DB_NAME(),
		[SchemaName]				= [s].[name],
		[TableName]					= [o].[name],
		[IndexName]					= COALESCE([i].[name], 'Heap'),

		[ObjectGroup]				= [smash].[ObjectGroup]([o].[type]),
		[ObjectType]				= [smash].[ObjectType]([o].[type]),

		[IsRowCount]				= IIF(([i].[index_id] <= 1) AND ([a].[type] = 1), 1, 0),

		[IndexType]					= CASE [i].[type]
										WHEN 0	THEN 'Heap'
										WHEN 1	THEN 'Clustered (Rowstore)'
										WHEN 2	THEN 'Nonclustered (Rowstore)'
										WHEN 3	THEN 'XML'
										WHEN 4	THEN 'Spatial'
										WHEN 5	THEN 'Clustered (Columnstore)'
										WHEN 6	THEN 'Nonclustered (Columnstore)'
										WHEN 7	THEN 'Nonclustered (Hash)'
										END,

	[i].[is_unique],
	[i].[data_space_id],
	[i].[ignore_dup_key],

	[i].[is_primary_key],
	[i].[is_unique_constraint],

	[i].[fill_factor],
	[i].[is_padded],
	[i].[is_disabled],
	[i].[is_hypothetical],
	[i].[is_ignored_in_optimization],

	[i].[allow_row_locks],
	[i].[allow_page_locks],

	[i].[has_filter],
	[i].[filter_definition],
	[i].[compression_delay],
	[i].[suppress_dup_key_messages],
	[i].[auto_created],
	--[i].[optimize_for_sequential_key]

	[p].[partition_number],
	[p].[rows],
	[p].[data_compression],
		[CompressionType]		= CASE [p].[data_compression]
									WHEN 0	THEN 'None'
									WHEN 1	THEN 'Row'
									WHEN 2	THEN 'Page'
									WHEN 3	THEN 'Columnstore'
									WHEN 4	THEN 'Columnstore (Archive)'
									END,

		[AllocationType]		= CASE [a].[type]
									WHEN 0	THEN 'Dropped'
									WHEN 1	THEN 'In-row data'
									WHEN 2	THEN 'Large object (LOB)'
									WHEN 3	THEN 'Row-overflow'
									END,
	[a].[total_pages],
	[a].[used_pages],
	[a].[data_pages],
		[free_pages]			= ([a].[total_pages] - [a].[used_pages]),

		[total_mb]				= (8.0 / 1024.0 * [a].[total_pages]),
		[used_mb]				= (8.0 / 1024.0 * [a].[used_pages]),
		[data_mb]				= (8.0 / 1024.0 * [a].[data_pages]),
		[free_mb]				= (8.0 / 1024.0 * ([a].[total_pages] - [a].[used_pages]))

FROM
	sys.schemas						[s]
INNER JOIN
	sys.objects						[o]
		ON	([s].[schema_id]	=	[o].[schema_id])
		AND	([o].[type]			IN	('U', 'V', 'IT', 'S'))
INNER JOIN
	sys.indexes						[i]
		ON	([o].[object_id]	=	[i].[object_id])
INNER JOIN
	sys.partitions					[p]
		ON	([i].[object_id]	=	[p].[object_id])
		AND	([i].[index_id]		=	[p].[index_id])
INNER JOIN
	sys.allocation_units			[a]
		ON	([a].[type]	= 2)	AND ([a].[container_id] = [p].[partition_id])
		OR	([a].[type]	= 1)	AND ([a].[container_id] = [p].[hobt_id])
WHERE
	([s].[name]		<>	'sys');
GO
PRINT N'Update complete.';


GO