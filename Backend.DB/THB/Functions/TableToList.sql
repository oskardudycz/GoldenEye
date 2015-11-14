
CREATE FUNCTION [THB].[TableToList](@table IdsTable readonly)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE @returnValue varchar(MAX)
	
	SET @returnValue = (SELECT STUFF( (SELECT ',' + CAST(Id as varchar) FROM @table for xml path('')), 1, 1, ''));	
	
	--usuniecie ostatnie przecinka
	IF SUBSTRING(@returnValue, LEN(@returnValue), 1) = ','
	BEGIN
		SET @returnValue = SUBSTRING(@returnValue, 1, LEN(@returnValue) - 1);
	END
	
	RETURN @returnValue;
END

