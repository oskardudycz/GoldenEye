-- =============================================
-- Author:		DK
-- Description:	Pobiera Id typow obiektow dla branz do ktorych uzytkownik ma uprawnienia/dostep.
-- =============================================
CREATE FUNCTION [THB].[GetUnitTypesIdsForUserBranches]
(
	@UserId int
)
RETURNS nvarchar(MAX)
AS
BEGIN
	DECLARE @TypyObiektowDlaBranz IdsTable,
		@UnitTypesIds nvarchar(MAX) = '',
		@MinRoleRank int		
		
	-- sprawdzenie czy uzytkownik nalezy do roli Supervisor lub Administrator
	SELECT @MinRoleRank = MIN(r.[Rank])
	FROM [Role] r
	JOIN RolaGrupaUzytkownikow rgu ON (rgu.Rola = r.Id)
	JOIN GrupaUzytkownikowUzytkownik guu ON (guu.GrupaUzytkownikow = rgu.GrupaUzytkownikow)
	WHERE guu.Uzytkownik = @UserId

	-- jesli ranking roli jest wiekszy niz rola admina i supervisora
	IF @MinRoleRank IS NOT NULL AND @MinRoleRank > 1
	BEGIN
		-- pobranie Id branz do ktorych uzytkownik ma uprawnienia	
		INSERT INTO @TypyObiektowDlaBranz(Id)
		SELECT DISTINCT [TypObiektu_Id]
		FROM [dbo].[TypyObiektow_Branze] tob
		WHERE tob.Branza_Id IN
		(SELECT DISTINCT Branza	 
			FROM dbo.[RolaOperacja] ro
			JOIN RolaGrupaUzytkownikow rgu ON (rgu.Rola = ro.Rola)
			JOIN GrupaUzytkownikowUzytkownik guu ON (guu.GrupaUzytkownikow = rgu.GrupaUzytkownikow)
			WHERE guu.Uzytkownik = @UserId
		)
		
		SET @UnitTypesIds = THB.TableToList(@TypyObiektowDlaBranz);
		
		IF @UnitTypesIds IS NULL
			SET @UnitTypesIds = '0'
	END
	ELSE
		SET @UnitTypesIds = NULL;
		
	RETURN @UnitTypesIds;
END