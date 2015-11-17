-- =============================================
-- Author:		DK
-- Description:	Pobiera Id branz do ktorych uzytkownik ma uprawnienia/dostep.
-- =============================================
CREATE FUNCTION [THB].[GetUserBranchesIds]
(
	@UserId int,
	@AppDate datetime = NULL
)
RETURNS nvarchar(MAX)
AS
BEGIN
	DECLARE @BranzeDlaUsera IdsTable,
		@BranchesIds nvarchar(MAX),
		@MinRoleRank int = 50
		
	IF @AppDate IS NULL
		SET @AppDate = GETDATE();

	-- sprawdzenie czy uzytkownik nalezy do roli Supervisor lub Administrator
		SELECT @MinRoleRank = MIN(r.[Rank])
		FROM [Role] r
		JOIN RolaGrupaUzytkownikow rgu ON (rgu.Rola = r.Id)
		JOIN GrupaUzytkownikowUzytkownik guu ON (guu.GrupaUzytkownikow = rgu.GrupaUzytkownikow)
		WHERE guu.Uzytkownik = @UserId

	-- jesli ranking roli jest wiekszy niz rola admina i supervisora
	IF @MinRoleRank IS NOT NULL AND @MinRoleRank > 1
	BEGIN
		SET @BranchesIds = '';
		
		-- pobranie Id branz do kotrych uzytkownik ma uprawnienia	
		INSERT INTO @BranzeDlaUsera(Id)
		SELECT DISTINCT Branza 
		FROM dbo.[RolaOperacja] ro
		JOIN RolaGrupaUzytkownikow rgu ON (rgu.Rola = ro.Rola)
		JOIN GrupaUzytkownikowUzytkownik guu ON (guu.GrupaUzytkownikow = rgu.GrupaUzytkownikow)
		WHERE guu.Uzytkownik = @UserId
		AND (guu.ValidFrom <= @AppDate AND (guu.ValidTo IS NULL OR guu.ValidTo >= @AppDate))
		AND (rgu.ValidFrom <= @AppDate AND (rgu.ValidTo IS NULL OR rgu.ValidTo >= @AppDate))
		
		SET @BranchesIds = THB.TableToList(@BranzeDlaUsera);
		
		IF @BranchesIds IS NULL
			SET @BranchesIds = '0'
	END

	RETURN @BranchesIds;
END