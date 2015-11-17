-- =============================================
-- Author:		DK
-- Created on: 2012-10-26
-- Description:	Sprawdza czy użytkownik należy do roli o wskazanym Rankingu (Rank).
-- =============================================
CREATE PROCEDURE [THB].[CheckUserInRole]
(
	@UserId int,
	@RoleRank int,
	@AppDate datetime,
	@CheckDate bit = 0, --czy ma sprawdzac przedzialy czasowe
	@UserInRole bit OUTPUT
)
AS
BEGIN
	DECLARE @Query nvarchar(MAX),
		@ActualDate bit,
		@RoleCounter int
	
	SET @RoleCounter = 0;
	SELECT @ActualDate = THB.IsActualDate(@AppDate);

	-- sprawdzenie czy uzytkownik nalezy do roli Supervisor lub Administrator
	SET @Query = '
		SELECT @RoleCounter = COUNT(r.[Rank])
		FROM [Role] r
		JOIN RolaGrupaUzytkownikow rgu ON (rgu.Rola = r.Id)
		JOIN GrupaUzytkownikowUzytkownik guu ON (guu.GrupaUzytkownikow = rgu.GrupaUzytkownikow)
		WHERE guu.Uzytkownik = ' + CAST(@UserId AS varchar) + ' AND r.[Rank] = ' + CAST(@RoleRank AS varchar)
		
	IF @CheckDate = 1
	BEGIN
		IF @AppDate IS NOT NULL
			SET @Query += ' AND (guu.ValidFrom <= ''' + CONVERT(varchar, @AppDate, 112) + ' 23:59:59'' AND (guu.ValidTo IS NULL OR guu.ValidTo >= ''' + CONVERT(varchar, @AppDate, 112) + ' 00:00:00'' )) 
				AND (rgu.ValidFrom <= ''' + CONVERT(varchar, @AppDate, 112) + ' 23:59:59'' AND (rgu.ValidTo IS NULL OR rgu.ValidTo >= ''' + CONVERT(varchar, @AppDate, 112) + ' 00:00:00'' ))' 

		IF @ActualDate = 1
			SET @Query += ' AND guu.IsDeleted = 0 AND rgu.IsDeleted = 0';
	END
	
	--PRINT @Query;
	EXECUTE sp_executesql @Query, N'@RoleCounter int OUTPUT', @RoleCounter = @RoleCounter OUTPUT
	
	IF @RoleCounter > 0
		SET @UserInRole = 1;
	ELSE
		SET @UserInRole = 0;

END