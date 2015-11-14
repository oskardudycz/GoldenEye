
CREATE FUNCTION [dbo].[ObiektObiektyPodrzedne](@TypObiektuId int, @ObiektId int)
RETURNS varchar(500)
AS
BEGIN
	DECLARE	@Nazwa varchar(64)
	SELECT 
		@Nazwa = 'SELECT * FROM [THBZasobyDemo].[dbo].[_'+T1.Nazwa+ '] WHERE ID = '+CAST(@ObiektId as nvarchar)
		
	FROM [THBZasobyDemo].[dbo].[TypObiektu_Relacje] TR
	JOIN [THBZasobyDemo].[dbo].[TypObiektu] T1 
	ON TR.TypObiektuID_L = T1.TypObiekt_ID
	
	RETURN @Nazwa
END
