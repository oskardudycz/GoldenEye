
CREATE FUNCTION [dbo].[ColumnsAsCSV](@ObiektNazwa varchar(64))
RETURNS varchar(1024)
AS
BEGIN
	DECLARE @query varchar(1024)
	
	set @query =  N'SELECT DISTINCT '',['' + CAST(CechaId as varchar(128) ) +'']'' '+
		' FROM '+@ObiektNazwa +
		' WHERE COALESCE (ValString, CAST(ColumnsSet AS VARCHAR(MAX))) IS NOT NULL
		  for xml path('''')'
	
	Return @query 
END
