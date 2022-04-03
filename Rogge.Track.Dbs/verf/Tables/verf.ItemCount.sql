CREATE TABLE [verf].[ItemCount]
(
	[ItemCountId]					INT					NOT	NULL	IDENTITY(1, 1)	NOT FOR REPLICATION,

	[ServerName]					NVARCHAR(128)		NOT	NULL	CONSTRAINT	[CL_ItemCount_ServerName]				CHECK([ServerName]	<> ''),
	[DatabaseName]					NVARCHAR(128)		NOT	NULL	CONSTRAINT	[CL_ItemCount_DatabaseName]				CHECK([DatabaseName]	<> ''),
	[SchemaName]					NVARCHAR(128)		NOT	NULL	CONSTRAINT	[CL_ItemCount_SchemaName]				CHECK([SchemaName]	<> ''),
	[TableName]						NVARCHAR(128)		NOT	NULL	CONSTRAINT	[CL_ItemCount_TableName]				CHECK([TableName]	<> ''),

	[DescriptionName]				NVARCHAR(128)		NOT	NULL	CONSTRAINT	[CL_ItemCount_DescriptionName]			CHECK([DescriptionName]	<> ''),

	[CheckDate]						DATETIME			NOT	NULL,
	[Items]							INT					NOT	NULL,

	[txInserted]					DATETIMEOFFSET(7)	NOT	NULL	CONSTRAINT	[DF_ItemCount_txInserted]				DEFAULT(SYSDATETIMEOFFSET()),
	[txInsertedSid]					VARBINARY(85)		NOT	NULL	CONSTRAINT	[DF_ItemCount_txInsertedSid]			DEFAULT(SUSER_SID()),
	[txInsertedUserOriginal]		NVARCHAR(128)		NOT	NULL	CONSTRAINT	[DF_ItemCount_txInsertedUserOriginal]	DEFAULT(ORIGINAL_LOGIN()),
	[txInsertedUserExecute]			NVARCHAR(128)		NOT	NULL	CONSTRAINT	[DF_ItemCount_txInsertedUserExecute]	DEFAULT(SUSER_SNAME()),
	[txInsertedHost]				NVARCHAR(128)		NOT	NULL	CONSTRAINT	[DF_ItemCount_txInsertedHost]			DEFAULT(HOST_NAME()),
	[txInsertedApp]					NVARCHAR(128)		NOT	NULL	CONSTRAINT	[DF_ItemCount_txInsertedApp]			DEFAULT(APP_NAME()),
	[txRowReplication]				UNIQUEIDENTIFIER	NOT	NULL	CONSTRAINT	[DF_ItemCount_txRowReplication]			DEFAULT(NEWSEQUENTIALID())	ROWGUIDCOL,
	[txRowVersion]					ROWVERSION			NOT	NULL,

	CONSTRAINT [PK_ItemCount]		PRIMARY KEY CLUSTERED([ItemCountId]	ASC),
	CONSTRAINT [UK_ItemCount]		UNIQUE NONCLUSTERED
	(
		[ServerName]	ASC,
		[DatabaseName]	ASC,
		[SchemaName]	ASC,
		[TableName]		ASC,
		[CheckDate]		ASC
	)
);