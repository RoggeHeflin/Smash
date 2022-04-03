/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

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
