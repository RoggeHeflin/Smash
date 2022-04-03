CREATE PROCEDURE [track].[Insert_ApplicationLogBegin]
(
	@ApplicationName		NVARCHAR(128),
	@ClassName				VARCHAR(128),
	@FunctionName			VARCHAR(128),
	@ApplicationVersion		VARCHAR(128),
	@ApplicationPlatform	VARCHAR(128)
)
AS
BEGIN

	SET NOCOUNT ON;
	SET LOCK_TIMEOUT 100;
	SET DEADLOCK_PRIORITY HIGH;

	DECLARE @TxnCount		INT				= @@TRANCOUNT;
	DECLARE @TxnActive		VARCHAR(32)		= REPLACE(CONVERT(VARCHAR(36), NEWID(), 0), '-', '');
	DECLARE @TxnId			NUMERIC(18, 0)	= NULL;

	IF (@TxnCount = 0) BEGIN TRANSACTION @TxnActive ELSE SAVE TRANSACTION @TxnActive;
	BEGIN TRY
	-----------------------------------------------------------------------------------------------

		INSERT INTO [track].[ApplicationLogBegin]
		(
			[txInsertedApplication],
			[ClassName],
			[FunctionName],
			[ApplicationVersion],
			[ApplicationPlatform]
		)
		SELECT
			[txInsertedApplication]	= @ApplicationName,
			[ClassName]				= @ClassName,
			[FunctionName]			= @FunctionName,
			[ApplicationVersion]	= @ApplicationVersion,
			[ApplicationPlatform]	= @ApplicationPlatform;

		SET	@TxnId	= SCOPE_IDENTITY();

	---------------------------------------------------------------------------------------------
	IF (@TxnCount = 0) COMMIT TRANSACTION @TxnActive ELSE SAVE TRANSACTION @TxnActive;
	END TRY
	BEGIN CATCH

		IF (XACT_STATE() = -1) ROLLBACK	TRANSACTION	@TxnActive;
		IF (XACT_STATE() =  1) COMMIT	TRANSACTION	@TxnActive;

		THROW;

	END CATCH;

	SELECT [TxnId] = @TxnId;
	RETURN @TxnId;

END;