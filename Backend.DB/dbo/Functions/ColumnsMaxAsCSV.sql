-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[ColumnsMaxAsCSV](@ObiektNazwa varchar(64))
RETURNS varchar(1024)
AS
BEGIN
	DECLARE @query varchar(1024)
	
	set @query =  N'SELECT DISTINCT +'',MAX(['' + CAST(CechaId as varchar(128) ) 
			+'']) [''
			 + CAST(CechaId as varchar(128) )
			 +'']''
			FROM '+@ObiektNazwa +
			' WHERE COALESCE (ValString, CAST(ColumnsSet AS VARCHAR(MAX))) IS NOT NULL
			for xml path('''')'
	
	Return @query 
END
