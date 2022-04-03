CREATE TABLE [track].[SsisLogDetail]
(
	[SsisLogDetailId]				INT					NOT	NULL	IDENTITY(1, 1)	NOT FOR REPLICATION,

	[Event]							SYSNAME				NOT	NULL,
	[Computer]						NVARCHAR(128)		NOT	NULL,
	[Operator]						NVARCHAR(128)		NOT	NULL,
	[Source]						NVARCHAR(1024)		NOT	NULL,
	[SourceId]						UNIQUEIDENTIFIER	NOT	NULL,
	[ExecutionId]					UNIQUEIDENTIFIER	NOT	NULL,
	[EventBeg]						DATETIME2			NOT	NULL,
	[EventEnd]						DATETIME2			NOT	NULL,
	[DataCode]						INT					NOT	NULL,
	[DataBytes]						IMAGE				NOT	NULL,
	[Message]						NVARCHAR(2048)		NOT	NULL,

	[txInserted]					DATETIMEOFFSET(7)	NOT	NULL	CONSTRAINT	[DF_SsisLogDetail_txInserted]				DEFAULT(SYSDATETIMEOFFSET()),
	[txInsertedSid]					VARBINARY(85)		NOT	NULL	CONSTRAINT	[DF_SsisLogDetail_txInsertedSid]				DEFAULT(SUSER_SID()),
	[txInsertedUserOriginal]		NVARCHAR(128)		NOT	NULL	CONSTRAINT	[DF_SsisLogDetail_txInsertedUserOriginal]	DEFAULT(ORIGINAL_LOGIN()),
	[txInsertedUserExecute]			NVARCHAR(128)		NOT	NULL	CONSTRAINT	[DF_SsisLogDetail_txInsertedUserExecute]		DEFAULT(SUSER_SNAME()),
	[txInsertedHost]				NVARCHAR(128)		NOT	NULL	CONSTRAINT	[DF_SsisLogDetail_txInsertedHost]			DEFAULT(HOST_NAME()),
	[txInsertedApp]					NVARCHAR(128)		NOT	NULL	CONSTRAINT	[DF_SsisLogDetail_txInsertedApp]				DEFAULT(APP_NAME()),
	[txRowReplication]				UNIQUEIDENTIFIER	NOT	NULL	CONSTRAINT	[DF_SsisLogDetail_txRowReplication]			DEFAULT(NEWSEQUENTIALID())	ROWGUIDCOL,
	[txRowVersion]					ROWVERSION			NOT	NULL,

	CONSTRAINT	[PK_SsisLogDetail]		PRIMARY KEY CLUSTERED([SsisLogDetailId]	ASC)
);