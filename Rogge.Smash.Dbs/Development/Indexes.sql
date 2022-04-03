SELECT
	[i].[schema_id],
	[i].[object_id],
	[i].[index_id],

	[i].[SchemaName],
	[i].[ObjectName],
	[i].[IndexName],

	[i].[ColumnsKey],
	[i].[ColumnsKeyAll],
	[i].[ColumnsIncluded]
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
			)
	);
