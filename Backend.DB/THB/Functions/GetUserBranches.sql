-- =============================================
-- Author:		DK
-- Description:	Pobiera Id branz do ktorych uzytkownik ma uprawnienia/dostep.
-- =============================================
CREATE FUNCTION [THB].[GetUserBranches]
(
	@UserId int
)
RETURNS @BranzeUsera TABLE
(
	Id int
)
AS
BEGIN

	DECLARE @MinRoleRank int = 50

	-- sprawdzenie czy uzytkownik nalezy do roli Supervisor lub Administrator
		SELECT @MinRoleRank = MIN(r.[Rank])
		FROM [Role] r
		JOIN RolaGrupaUzytkownikow rgu ON (rgu.Rola = r.Id)
		JOIN GrupaUzytkownikowUzytkownik guu ON (guu.GrupaUzytkownikow = rgu.GrupaUzytkownikow)
		WHERE guu.Uzytkownik = @UserId

	-- jesli ranking roli jest wiekszy niz rola admina i supervisora
	IF @MinRoleRank IS NOT NULL
	BEGIN
		IF @MinRoleRank > 1
		BEGIN
			
			-- pobranie Id branz do kotrych uzytkownik ma uprawnienia
			INSERT INTO @BranzeUsera(Id)	
			SELECT DISTINCT Branza 
			FROM dbo.[RolaOperacja] ro
			JOIN RolaGrupaUzytkownikow rgu ON (rgu.Rola = ro.Rola)
			JOIN GrupaUzytkownikowUzytkownik guu ON (guu.GrupaUzytkownikow = rgu.GrupaUzytkownikow)
			WHERE guu.Uzytkownik = @UserId
		END
		ELSE
		BEGIN
			--zwrocenie wszystkich branzy dla adminow
			INSERT INTO @BranzeUsera(Id)
			SELECT Id FROM dbo.Branze
			WHERE IdArch IS NULL AND IsValid = 1 AND IsDeleted = 0;
		END
	END
	
	RETURN

END