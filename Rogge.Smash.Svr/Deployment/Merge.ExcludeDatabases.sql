MERGE [smash].[ExcludeDatabases] [t]
USING (
	SELECT
		[t].[database_id],
			[DatabaseName]	=	[t].[name]
	FROM
		sys.databases	[t]
	WHERE
		([t].[database_id] <= 4)
	UNION
	SELECT
		[t].[database_id],
			[DatabaseName]	=	[t].[name]
	FROM
		sys.databases	[t]
	WHERE
			([t].[name] LIKE '%.Smash.Dbs')
		OR	([t].[name] LIKE '%.Track.Dbs')
		OR	([t].[name] LIKE 'Rogge%')
	UNION
	SELECT
			[database_id]	= DB_ID([t].[DatabaseName]),
		[t].[DatabaseName]
	FROM (VALUES
		('DWConfiguration'),
		('DWDiagnostics'),
		('DWQueue'),
		('SSISDB'),
		('SSRS'),
		('SSRSTempDB')
		)[t]([DatabaseName])
) [s]
ON	([t].[database_id]	= [s].[database_id])
WHEN NOT MATCHED BY TARGET THEN
	INSERT ([database_id], [DatabaseName])
	VALUES ([database_id], [DatabaseName])
WHEN NOT MATCHED BY SOURCE THEN
	DELETE;
GO