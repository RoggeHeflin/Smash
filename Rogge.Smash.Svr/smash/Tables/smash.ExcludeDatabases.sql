CREATE TABLE [smash].[ExcludeDatabases]
(
	[database_id]			SMALLINT			NOT	NULL,
	[DatabaseName]			NVARCHAR(128)		NOT	NULL,	CONSTRAINT [CK_ExcludeDatabases_DatabaseNameLen]	CHECK([DatabaseName] <> ''),
	CONSTRAINT [PK_ExcludeDatabases]	PRIMARY KEY CLUSTERED([database_id]	ASC),
	CONSTRAINT [UK_ExcludeDatabases]	UNIQUE NONCLUSTERED([DatabaseName]	ASC)
);