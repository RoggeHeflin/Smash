CREATE PROCEDURE [smash].[UpdateStastics]
AS
BEGIN

SET NOCOUNT ON;
SET LOCK_TIMEOUT 100;
SET DEADLOCK_PRIORITY HIGH;

DECLARE @TxnCount		INT				= @@TRANCOUNT;
DECLARE @TxnActive		VARCHAR(32)		= REPLACE(CONVERT(VARCHAR(36), NEWID(), 0), '-', '');
DECLARE @ErrorCode		INT;

DECLARE @TrackingLogId	INT;
EXECUTE @TrackingLogId	= [track].[Insert_ProcedureLogBegin] @@PROCID;

IF (@TxnCount = 0) BEGIN TRANSACTION @TxnActive ELSE SAVE TRANSACTION @TxnActive;
BEGIN TRY
-----------------------------------------------------------------------------------------------

	DECLARE @PrintLine		NVARCHAR(MAX);
	DECLARE @SqlCommand		NVARCHAR(MAX);
	DECLARE @IndexCount		INT;

	DECLARE ExecuteLoop CURSOR FORWARD_ONLY READ_ONLY STATIC TYPE_WARNING
	FOR
	SELECT
		[SqlCommand]	= N'UPDATE STATISTICS ' + [t].[ObjectNameQualified] + N' WITH ' +
			CASE WHEN (SUM([i].[total_kb]) <= 100000.0)
			THEN N'FULLSCAN, '
			ELSE N''
			END + N'ALL;'
	FROM
		[smash].[DatabaseIndexesPartitions]	[i]
	INNER JOIN
		[smash].[DatabaseTables]			[t]
			ON	([i].[object_id]		=	[t].[object_id])
	WHERE
		([t].[ObjectGroup]	= 'Table')
	GROUP BY
		[t].[ObjectNameQualified]
	ORDER BY
		SUM([i].[total_kb]) DESC;

	OPEN ExecuteLoop;
	SET @IndexCount = @@CURSOR_ROWS;

	FETCH NEXT FROM ExecuteLoop
	INTO @SqlCommand;

	WHILE (@@FETCH_STATUS = 0)
	BEGIN

		SET @PrintLine = CAST(@IndexCount AS VARCHAR(5)) + NCHAR(9) + N' Remaining' + NCHAR(9) + COALESCE(@SqlCommand, N'');

		PRINT @PrintLine;

		BEGIN TRY

			EXECUTE sp_executesql @SqlCommand;

		END TRY
		BEGIN CATCH

			PRINT @PrintLine + N' ERROR!!';

		END CATCH;

		FETCH NEXT FROM ExecuteLoop
		INTO @SqlCommand;

		SET @IndexCount = @IndexCount - 1;

	END;

	CLOSE ExecuteLoop;
	DEALLOCATE ExecuteLoop;

-----------------------------------------------------------------------------------------------
IF (@TxnCount = 0) COMMIT TRANSACTION @TxnActive ELSE SAVE TRANSACTION @TxnActive;
END TRY
BEGIN CATCH

	SET @ErrorCode = @@ERROR;

	IF (XACT_STATE() = -1) ROLLBACK	TRANSACTION	@TxnActive;
	IF (XACT_STATE() =  1) COMMIT	TRANSACTION	@TxnActive;

	EXECUTE [track].[Insert_ProcedureLogError] @TrackingLogId;

	THROW;

	RETURN @ErrorCode;

END CATCH;

EXECUTE [track].[Insert_ProcedureLogEnd] @TrackingLogId;

RETURN @ErrorCode;

END;