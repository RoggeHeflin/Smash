﻿CREATE FUNCTION [track].[StringOccuranceCount]
(
	@SearchTerm		NVARCHAR(MAX),
	@SearchString	NVARCHAR(MAX)
)
RETURNS INT
WITH SCHEMABINDING, RETURNS NULL ON NULL INPUT
AS
BEGIN

	RETURN (DATALENGTH(@SearchString) - DATALENGTH(REPLACE(@SearchString, @SearchTerm, N''))) / NULLIF(DATALENGTH(@SearchTerm), 0);

END;