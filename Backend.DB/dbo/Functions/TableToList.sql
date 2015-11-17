CREATE FUNCTION [dbo].[TableToList](@table IdsTable readonly)
RETURNS varchar(500)
AS
BEGIN
	DECLARE @returnValue varchar(500)
	
	SET @returnValue = (SELECT STUFF( (SELECT ',' + CAST(Id as varchar) FROM @table for xml path('')), 1, 1, ''));	
	SET @returnValue = SUBSTRING(@returnValue, 0, LEN(@returnValue) - 1);
	
	Return @returnValue;
END