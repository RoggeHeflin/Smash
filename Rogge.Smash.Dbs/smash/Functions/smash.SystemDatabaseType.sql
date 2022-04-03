CREATE FUNCTION [smash].[SystemDatabaseType]
(
	@DatabaseId		INT
)
RETURNS NVARCHAR(8)
WITH SCHEMABINDING, RETURNS NULL ON NULL INPUT, INLINE = ON
AS
BEGIN

	DECLARE	@DatabaseType	VARCHAR(8)	= N'User';

	SET	@DatabaseType =
	CASE
		WHEN (@DatabaseId <= 4)			THEN N'System'
		WHEN (db_name(@DatabaseId) IN (
				N'DWConfiguration',
				N'DWDiagnostics',
				N'DWQueue',
				N'SSISDB',
				N'SSRS',
				N'SSRSTempDB'
				)
			)							THEN N'Support'
		WHEN (db_name(@DatabaseId) LIKE N'AdventureWorks%')
										THEN N'Training'
	ELSE
		@DatabaseType
	END;

	RETURN @DatabaseType;

END;