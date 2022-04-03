CREATE VIEW [smash].[DatabaseIndexesDuplicate]
WITH VIEW_METADATA
AS
SELECT
	[i].[instance_id],
	[i].[database_id],
	[i].[schema_id],
	[i].[object_id],
	[i].[index_id],

	[i].[Instance],
	[i].[InstanceHost],
	[i].[InstanceName],

	[i].[DatabaseType],
	[i].[ObjectGroup],
	[i].[ObjectType],

	[i].[DatabaseName],
	[i].[SchemaName],
	[i].[ObjectName],
	[i].[IndexName],

	[i].[IndexType],
	[i].[IndexTypeClustering],

	[i].[ColumnsKey],
	[i].[ColumnsKeyAll],
	[i].[ColumnsIncluded],
	[i].[ColumnsAll]
FROM
	[smash].[DatabaseIndexes]		[i]
WHERE EXISTS (
	SELECT TOP 1 1
	FROM
		[smash].[DatabaseIndexes]	[t]
	WHERE
			([t].[schema_id]		=	[i].[schema_id])
		AND	([t].[object_id]		=	[i].[object_id])
		AND	([t].[index_id]			<>	[i].[index_id])

		AND	(
				(	([t].[ColumnsKey]							=	[i].[ColumnsKey])
					AND	(COALESCE([t].[ColumnsIncluded], N'')	=	COALESCE([i].[ColumnsIncluded], N''))
				)
			OR	(	([t].[ColumnsKey] LIKE LEFT([i].[ColumnsKey], LEN([t].[ColumnsKey])))
				OR	([i].[ColumnsKey] LIKE LEFT([t].[ColumnsKey], LEN([i].[ColumnsKey])))
				)
			OR	(	([t].[ColumnsKeyAll] LIKE LEFT([i].[ColumnsKeyAll], LEN([t].[ColumnsKeyAll])))
				OR	([i].[ColumnsKeyAll] LIKE LEFT([t].[ColumnsKeyAll], LEN([i].[ColumnsKeyAll])))
				)
			OR	(	([t].[ColumnsAll] LIKE LEFT([i].[ColumnsAll], LEN([t].[ColumnsAll])))
				OR	([i].[ColumnsAll] LIKE LEFT([t].[ColumnsAll], LEN([i].[ColumnsAll])))
				)
			)
	);