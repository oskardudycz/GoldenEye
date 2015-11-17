-- =============================================
-- Author:		DK
-- Created on: 2012-10-26
-- Description:	Pobiera Id minimalnego rankingu roli do jakiej nalezy uzytkownik.
-- =============================================
CREATE PROCEDURE [THB].[GetUserMinRoleRank]
(
	@UserId int,
	@AppDate datetime,
	@CheckDate bit = 0, --czy ma sprawdzac przedzialy czasowe
	@MinRoleRank int OUTPUT
)
AS
BEGIN
	DECLARE @Query nvarchar(MAX),
		@ActualDate bit
	
	SET @MinRoleRank = 0;
	SELECT @ActualDate = THB.IsActualDate(@AppDate);

	-- sprawdzenie czy uzytkownik nalezy do roli Supervisor lub Administrator
	SET @Query = '
		SELECT @MinRoleRank = MIN(r.[Rank])
		FROM [Role] r
		JOIN RolaGrupaUzytkownikow rgu ON (rgu.Rola = r.Id)
		JOIN GrupaUzytkownikowUzytkownik guu ON (guu.GrupaUzytkownikow = rgu.GrupaUzytkownikow)
		WHERE guu.Uzytkownik = ' + CAST(@UserId AS varchar)
		
	IF @CheckDate = 1
	BEGIN
		IF @AppDate IS NOT NULL
			SET @Query += ' AND (guu.ValidFrom <= ''' + CONVERT(varchar, @AppDate, 112) + ' 23:59:59'' AND (guu.ValidTo IS NULL OR guu.ValidTo >= ''' + CONVERT(varchar, @AppDate, 112) + ' 00:00:00'' )) 
				AND (rgu.ValidFrom <= ''' + CONVERT(varchar, @AppDate, 112) + ' 23:59:59'' AND (rgu.ValidTo IS NULL OR rgu.ValidTo >= ''' + CONVERT(varchar, @AppDate, 112) + ' 00:00:00'' ))' 

		IF @ActualDate = 1
			SET @Query += ' AND guu.IsDeleted = 0 AND rgu.IsDeleted = 0';
	END
	
	--PRINT @Query;
	EXECUTE sp_executesql @Query, N'@MinRoleRank int OUTPUT', @MinRoleRank = @MinRoleRank OUTPUT	

END