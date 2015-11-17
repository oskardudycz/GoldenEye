-- =============================================
-- Author:		DK
-- Date: 10-05-2012
-- Description:	Sprawdza czy uzytkownik posiada prawa do wykonania danej operacji
-- =============================================
CREATE PROCEDURE [THB].[GetUserAttributeTypes]
(
	@Alias varchar(10) = NULL,
	@NazwaKolumnyZCecha varchar(50) = 'CechaId',
	@DataProgramu datetime = NULL,
	@UserId int,
	@BranchId int = NULL,
	@AtributeTypesWhere nvarchar(MAX) OUTPUT
)
AS
BEGIN
	DECLARE @Skip bit = 0,
		@CechyId IdsTable,
		@query nvarchar(MAX) = '',
		@allBranches bit = 0,
		@MinRoleRank int
	
	IF OBJECT_ID('tempdb..#BranzeGUAT') IS NOT NULL
		DROP TABLE #BranzeGUAT
		
	IF OBJECT_ID('tempdb..#Cechy') IS NOT NULL
		DROP TABLE #Cechy
		
	IF OBJECT_ID('tempdb..#CechyNieBranzowe') IS NOT NULL
		DROP TABLE #CechyNieBranzowe

	CREATE TABLE #BranzeGUAT(Id int);
	CREATE TABLE #Cechy(Id int);	
	
	-- sprawdzenie czy uzytkownik nalezy do roli Supervisor lub Administrator
	SELECT @MinRoleRank = MIN(r.[Rank])
	FROM [Role] r
	JOIN RolaGrupaUzytkownikow rgu ON (rgu.Rola = r.Id)
	JOIN GrupaUzytkownikowUzytkownik guu ON (guu.GrupaUzytkownikow = rgu.GrupaUzytkownikow)
	WHERE guu.Uzytkownik = @UserId
	
	SET @query = 'INSERT INTO #BranzeGUAT(Id)
			SELECT DISTINCT ro.Branza AS Id
			FROM GrupaUzytkownikowUzytkownik guu
			JOIN RolaGrupaUzytkownikow rgu ON (guu.GrupaUzytkownikow = rgu.GrupaUzytkownikow)
			JOIN RolaOperacja ro ON (rgu.Rola = ro.Rola)
			WHERE guu.Uzytkownik = ' + CAST(@UserId AS varchar);
	
	IF @DataProgramu IS NULL
		SET @query += ' AND guu.IsValid = 1 AND guu.IsDeleted = 0';
	ELSE
		SET @query += ' AND (guu.ValidFrom <= ''' + CONVERT(varchar, @DataProgramu, 112) + ' 23:59:59'' AND (guu.ValidTo IS NULL OR guu.ValidTo >= ''' + CONVERT(varchar, @DataProgramu, 112) + ' 00:00:00'' )) ';					
	
	EXEC(@query);

	--jesli nie podano konkretnej branzy
	IF @BranchId IS NULL OR @BranchId = 0
	BEGIN		
		SET @query = 'INSERT INTO #Cechy(Id)
			SELECT DISTINCT CechaId
			FROM Branze_Cechy bc
			WHERE BranzaId IN (SELECT Id FROM #BranzeGUAT)'
		
		SET @allBranches = 1;
			
		IF @DataProgramu IS NULL
			SET @query += ' AND bc.IdArch IS NULL AND bc.IsValid = 1 AND bc.IsDeleted = 0';
		ELSE
			SET @query += ' AND (bc.ValidFrom <= ''' + CONVERT(varchar, @DataProgramu, 112) + ' 23:59:59'' AND (bc.ValidTo IS NULL OR bc.ValidTo >= ''' + CONVERT(varchar, @DataProgramu, 112) + ' 00:00:00'' )) ';					
	
		EXEC(@query);
	END
	ELSE
	BEGIN
		--jesli nie ma dostepu do podanej branzy
		IF NOT EXISTS (SELECT Id FROM #BranzeGUAT WHERE Id = @BranchId)
		BEGIN
			IF @Alias IS NULL
				SET @AtributeTypesWhere = ' AND ' + @NazwaKolumnyZCecha + ' = -1'
			ELSE 
				SET @AtributeTypesWhere = ' AND ' + @Alias + '.' + @NazwaKolumnyZCecha + ' = -1';
				
			SET @Skip = 1;
		END
		ELSE
		BEGIN
			--pobranie Id cech dla podanej branzy
			SET @query = 'INSERT INTO #Cechy(Id)
					SELECT CechaId
					FROM Branze_Cechy
					WHERE BranzaId = ' + CAST(@BranchId AS varchar);
					
			--IF @DataProgramu IS NULL
				SET @query += ' AND IdArch IS NULL AND IsValid = 1 AND IsDeleted = 0';
			
			IF @DataProgramu IS NOT NULL
				SET @query += ' AND (ValidFrom <= ''' + CONVERT(varchar, @DataProgramu, 112) + ' 23:59:59'' AND (ValidTo IS NULL OR ValidTo >= ''' + CONVERT(varchar, @DataProgramu, 112) + ' 00:00:00'' )) ';					
		
			EXEC(@query);
		END
	END
	
	--wstawienie do zmiennej cech do ktorych user ma dostep
	INSERT INTO @CechyId(Id)
	SELECT DISTINCT Id FROM #Cechy
	
	-- jesli ranking roli jest wiekszy niz rola admina i supervisora
	IF @MinRoleRank IS NOT NULL AND @MinRoleRank > 1
	BEGIN
	--	SELECT c.Cecha_ID AS Id
	--	INTO #CechyNieBranzowe
	--	FROM Cechy c
	--	WHERE c.IdArch IS NULL AND IsValid = 1 AND IsDeleted = 0 AND c.Cecha_ID NOT IN (SELECT CechaId FROM Branze_Cechy WHERE IdArch IS NULL AND IsValid = 1 AND IsDeleted = 0);
		
	--	INSERT INTO @CechyId(Id)
	--	SELECT Id FROM #CechyNieBranzowe
	--END
	
	----IF @Skip = 0
	--BEGIN
		-- jesli sa jakies cechy do ktorych ma dostep
		IF (SELECT COUNT(1) FROM @CechyId) > 0
		BEGIN			
			IF @Alias IS NULL
				SET @AtributeTypesWhere = ' AND ' + @NazwaKolumnyZCecha + ' IN (' + THB.TableToList(@CechyId) + ')';
			ELSE 
				SET @AtributeTypesWhere = ' AND ' + @Alias + '.' + @NazwaKolumnyZCecha + ' IN (' + THB.TableToList(@CechyId) + ')';
		END
		ELSE --IF @allBranches = 0
		BEGIN
			IF @Alias IS NULL
				SET @AtributeTypesWhere = ' AND ' + @NazwaKolumnyZCecha + ' = -1'
			ELSE 
				SET @AtributeTypesWhere = ' AND ' + @Alias + '.' + @NazwaKolumnyZCecha + ' = -1';
		END
	END
	ELSE
		SET @AtributeTypesWhere = NULL;

	IF OBJECT_ID('tempdb..#BranzeGUAT') IS NOT NULL
		DROP TABLE #BranzeGUAT
		
	IF OBJECT_ID('tempdb..#Cechy') IS NOT NULL
		DROP TABLE #Cechy

END