CREATE PROCEDURE [smash].[OptimizeIndexes]
(
	@FragmentationThreshold		FLOAT = 0.05,
	@RebuildThreshold			FLOAT = 0.30
)
AS
BEGIN

SET NOCOUNT ON;
SET LOCK_TIMEOUT 100;
SET DEADLOCK_PRIORITY HIGH;

DECLARE @TxnCount		INT				= @@TRANCOUNT;
DECLARE @TxnActive		VARCHAR(32)		= REPLACE(CONVERT(VARCHAR(36), NEWID(), 0), '-', '');
DECLARE @ErrorCode		INT				= 0;

DECLARE @TrackingLogId	INT;
EXECUTE @TrackingLogId	= [track].[Insert_ProcedureLogBegin] @@PROCID;

IF (@TxnCount = 0) BEGIN TRANSACTION @TxnActive ELSE SAVE TRANSACTION @TxnActive;
BEGIN TRY
-----------------------------------------------------------------------------------------------

DECLARE @PrintLine		NVARCHAR(MAX);
DECLARE @SqlCommand		NVARCHAR(MAX);
DECLARE @IndexCount		INT;
DECLARE @FragPcnt		INT;

DECLARE ExecuteLoop CURSOR FORWARD_ONLY READ_ONLY STATIC TYPE_WARNING
FOR
SELECT
	[FragPcnt]		= [p].[avg_fragmentation_in_percent] * 100,
	[SqlCommand]	= N'ALTER INDEX ' + [i].[Index] + N' ON ' + [t].[ObjectNameQualified] + N' ' +
		CASE WHEN ([p].[avg_fragmentation_in_percent] <	@RebuildThreshold) THEN N'REORGANIZE'
		ELSE N'REBUILD WITH (ONLINE = ON)'
		END + N';'
FROM
	[smash].[DatabaseIndexes]				[i]
INNER JOIN
	[smash].[DatabaseIndexesFragmentation]	[p]
		ON	([i].[object_id]			=	[p].[object_id])
		AND	([i].[index_id]				=	[p].[index_id])
INNER JOIN
	[smash].[DatabaseTables]				[t]
		ON	([i].[object_id]			=	[t].[object_id])
WHERE
		([i].[Index] <> 'Heap')
	AND	([p].[avg_fragmentation_in_percent]	>=  @FragmentationThreshold)
ORDER BY
	[p].[avg_fragmentation_in_percent]	DESC;

OPEN ExecuteLoop;
SET @IndexCount = @@CURSOR_ROWS;

FETCH NEXT FROM ExecuteLoop
INTO @FragPcnt, @SqlCommand;

WHILE (@@FETCH_STATUS = 0)
BEGIN

	SET @PrintLine = CAST(@IndexCount AS VARCHAR(5)) + NCHAR(9) + N' Remaining / Fragmentation: ' + NCHAR(9) + CAST(@FragPcnt AS VARCHAR(3)) + N'%' + NCHAR(9) + COALESCE(@SqlCommand, N'');

	PRINT @PrintLine;

	BEGIN TRY

		EXECUTE sp_executesql @SqlCommand;

	END TRY
	BEGIN CATCH

		PRINT @PrintLine + N' ERROR!!';

	END CATCH;

	FETCH NEXT FROM ExecuteLoop
	INTO @FragPcnt, @SqlCommand;

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