CREATE PROCEDURE [dbo].[sp_ssis_addlogentry]
(
	@event			SYSNAME,
	@computer		NVARCHAR(128),
	@operator		NVARCHAR(128),
	@source			NVARCHAR(1024),
	@sourceid		UNIQUEIDENTIFIER,
	@executionid	UNIQUEIDENTIFIER,
	@starttime		DATETIME2,
	@endtime		DATETIME2,
	@datacode		INT,
	@databytes		IMAGE,
	@message		NVARCHAR(2048)
)
AS
BEGIN

	SET NOCOUNT ON;
	SET LOCK_TIMEOUT 1000;
	SET DEADLOCK_PRIORITY HIGH;

	DECLARE @TxnCount		INT				= @@TRANCOUNT;
	DECLARE @TxnActive		VARCHAR(32)		= REPLACE(CONVERT(VARCHAR(36), NEWID(), 0), '-', '');
	DECLARE @ErrorCode		INT				= 0;

	IF (@TxnCount = 0) BEGIN TRANSACTION @TxnActive ELSE SAVE TRANSACTION @TxnActive;
	BEGIN TRY
	-----------------------------------------------------------------------------------------------

		INSERT INTO [track].[SsisLogDetail]
		(
			[Event],
			[Computer],
			[Operator],
			[Source],
			[SourceId],
			[ExecutionId],
			[EventBeg],
			[EventEnd],
			[DataCode],
			[DataBytes],
			[Message]
		)
		VALUES
		(
			@event,
			@computer,
			@operator,
			@source,
			@sourceid,
			@executionid,
			@starttime,
			@endtime,
			@datacode,
			@databytes,
			@message
		);

	-----------------------------------------------------------------------------------------------
	IF (@TxnCount = 0) COMMIT TRANSACTION @TxnActive ELSE SAVE TRANSACTION @TxnActive;
	END TRY
	BEGIN CATCH

		SET @ErrorCode = @@ERROR;

		IF (XACT_STATE() = -1) ROLLBACK	TRANSACTION	@TxnActive;
		IF (XACT_STATE() =  1) COMMIT	TRANSACTION	@TxnActive;

		THROW;

		RETURN @ErrorCode;

	END CATCH;

	RETURN @ErrorCode;

END;
GO

EXECUTE sp_addextendedproperty
	@name			= N'MS_Description',	@value = 'SSIS SQL Logging Procedure',
	@level0Type		= N'schema',			@level0name = 'dbo',
	@level1Type		= N'procedure',			@level1name = 'sp_ssis_addlogentry';
GO