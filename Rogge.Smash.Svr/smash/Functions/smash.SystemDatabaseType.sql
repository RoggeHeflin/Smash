CREATE FUNCTION [smash].[SystemDatabaseType]
(
	@DatabaseId		INT
)
RETURNS VARCHAR(8)
WITH SCHEMABINDING, RETURNS NULL ON NULL INPUT, INLINE = ON
AS
BEGIN

	DECLARE	@DatabaseType	VARCHAR(8)	= 'User';

	SET	@DatabaseType =
	CASE
		WHEN (@DatabaseId <= 4)			THEN 'System'

		WHEN (db_name(@DatabaseId) IN (
				N'DWConfiguration',
				N'DWDiagnostics',
				N'DWQueue',
				N'SSISDB',
				N'SSRS',
				N'SSRSTempDB'
				)
			)							THEN 'Support'

		WHEN (db_name(@DatabaseId) LIKE N'AdventureWorks%')
										THEN 'Training'
	ELSE
		@DatabaseType
	END;

	RETURN @DatabaseType;

END;