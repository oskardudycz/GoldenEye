
CREATE FUNCTION [dbo].[ObiektCechy](@ObiektNazwa varchar(64), @ObiektId int)
RETURNS varchar(512)
AS
BEGIN
	DECLARE @query varchar(512)
	SELECT
		@query =  'SELECT * FROM [THBZasobyDemo].[dbo].[_'+@ObiektNazwa+'_Cechy_Hist] WHERE ObiektId = '+CAST(@ObiektId as nvarchar)
	FROM TypObiektu_Relacje tr
	
	RETURN @query
END
