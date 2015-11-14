CREATE PROCEDURE [THB].[UpdateTriggerForTableUnitType]
(
	@UnitTypeId int,
	@OldName nvarchar(255),
	@NewName nvarchar(255)
)
AS 
BEGIN
	SET NOCOUNT ON;
	print'oki'

	DECLARE @CzyTabela bit = 0,
		@NazwaKolumny nvarchar(300),
		@TypDanych nvarchar(100),
		@ColumnsForCursor nvarchar(1000) = '',
		@VariablesForCursor nvarchar(1000) = '',
		@Query nvarchar(MAX),
		@VariableGoodName nvarchar(300) = ''
		
	IF OBJECT_ID('tempdb..#KolumnyTypuObiektuTrig') IS NOT NULL
		DROP TABLE #KolumnyTypuObiektuTrig
		
	CREATE TABLE #KolumnyTypuObiektuTrig(CechaId int, NazwaKolumny nvarchar(150), TypKolumny varchar(50));
	
	SELECT @CzyTabela = Tabela
	FROM dbo.TypObiektu
	WHERE TypObiekt_Id = @UnitTypeId
	
	--jesli typ obiektu nie jest tabelaryczny to nic nie robimy
	IF @CzyTabela = 0
		RETURN;
	
	--jesli triger istnieje to jego usuniecie
	IF EXISTS (SELECT name FROM sys.triggers WHERE name = 'WartoscZmiany_' + @NewName + '_UPDATE')
	BEGIN
		SET @Query = 'DROP TRIGGER dbo.[WartoscZmiany_' + @NewName + '_UPDATE];';
		--PRINT @Query;
		--EXEC @Query;
	END

	--INSERT INTO #KolumnyTypuObiektuTrig (NazwaKolumny, TypKolumny, CechaId)
	--SELECT DISTINCT c.Nazwa, ct.NazwaSql, c.Cecha_Id
	--FROM dbo.TypObiektu_Cechy toc
	--JOIN dbo.Cechy c ON (c.Cecha_Id = toc.Cecha_Id)
	--JOIN dbo.Cecha_Typy ct ON (c.TypId = ct.Id)
	--WHERE toc.TypObiektu_ID = @UnitTypeId AND toc.IsDeleted = 0;
	
	--pobranie nazw i typow kolumn/cech na podstawie PIERWSZEJ nazwy cechy
	INSERT INTO #KolumnyTypuObiektuTrig (NazwaKolumny, TypKolumny, CechaId)
	SELECT DISTINCT THB.[GetAllowedAttributeTypeName](c.Nazwa), ct.NazwaSql, ISNULL(allData.IdArch, allData.Cecha_ID)
	FROM
	(
		SELECT o.Cecha_ID, o.IdArch, ROW_NUMBER() OVER(PARTITION BY ISNULL(o.IdArch, o.Cecha_ID) ORDER BY o.Cecha_ID ASC) AS Rn
		FROM [dbo].[Cechy] o
		INNER JOIN
		(
			SELECT ISNULL(c2.IdArch, c2.Cecha_ID) AS RowID, MIN(c2.ObowiazujeOd) AS MinDate
			FROM [dbo].[Cechy] c2							 
			JOIN dbo.TypObiektu_Cechy toc ON (c2.Cecha_Id = toc.Cecha_Id OR c2.IdArch = toc.Cecha_Id)
			WHERE toc.TypObiektu_ID = @UnitTypeId AND toc.IsDeleted = 0
			GROUP BY ISNULL(c2.IdArch, c2.Cecha_ID)
		) latestWithMaxDate
		ON ISNULL(o.IdArch, o.Cecha_ID) = latestWithMaxDate.RowID AND o.ObowiazujeOd = latestWithMaxDate.MinDate
	) allData
	JOIN dbo.Cechy c ON (c.Cecha_Id = allData.Cecha_Id)
	JOIN dbo.Cecha_Typy ct ON (c.TypId = ct.Id) 
	WHERE allData.Rn = 1	AND c.IsValid=1 

select * from #KolumnyTypuObiektuTrig
		
	SET @Query = '
		ALTER TRIGGER [dbo].[WartoscZmiany_' + @NewName + '_UPDATE]
		   ON  [dbo].[_' + @NewName + '] 
		   AFTER UPDATE
		AS 
		BEGIN
			SET NOCOUNT ON;

			DECLARE @ID int, @Nazwa nvarchar(64), @WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int,@Wersja int
			,@ZmianaOd datetime, @ZmianaDo datetime, @ObowiazujeOd datetime, @ObowiazujeDo datetime, @WaznyOdNEW datetime, @UtworzonyPrzezNEW int, @CzyWaznyNEW bit
			,@NazwaNEW nvarchar(64), @DataModyfikacjiApp datetime, @RealCreatedOn datetime, @RealLastModifiedOn datetime, @hist int
			,@IsStatus bit, @StatusS int, @StatusW int, @StatusP int, @StatusSFromBy int, @StatusPFromBy int, @StatusWFromBy int 
			,@StatusSFrom datetime, @StatusPFrom datetime, @StatusWFrom datetime, @CreateNewRowForHistory bit, @CreatedOn datetime'
			
			--dodawanie kolejnych zmiennych zwiazanych z kolumnami
			DECLARE curs CURSOR FOR
				SELECT dbo.Trim(NazwaKolumny), TypKolumny
				FROM #KolumnyTypuObiektuTrig
			OPEN curs 
			FETCH NEXT FROM curs INTO @NazwaKolumny, @TypDanych
			WHILE @@fetch_status = 0
			BEGIN
			
				IF @NazwaKolumny <> 'Id'
				BEGIN
					
					SET @VariableGoodName = REPLACE(@NazwaKolumny, '.', '');
					SET @VariableGoodName = REPLACE(@VariableGoodName, ' ', '_');
					SET @VariableGoodName = REPLACE(@VariableGoodName, '-', '_');
					SET @VariableGoodName = REPLACE(@VariableGoodName, '(', '_');
					SET @VariableGoodName = REPLACE(@VariableGoodName, ')', '_');
					SET @VariableGoodName = REPLACE(@VariableGoodName, '[', '_');
					SET @VariableGoodName = REPLACE(@VariableGoodName, ']', '_');
					SET @VariableGoodName = REPLACE(@VariableGoodName, ':', '_');
					SET @VariableGoodName = REPLACE(@VariableGoodName, '?', '_');
					SET @VariableGoodName = REPLACE(@VariableGoodName, ',', '_');
					SET @VariableGoodName = REPLACE(@VariableGoodName, ';', '_');
					SET @VariableGoodName = REPLACE(@VariableGoodName, '"', '_');
					SET @VariableGoodName = REPLACE(@VariableGoodName, '"', '_');
				
					SET @Query += ', @' + @VariableGoodName + ' ' + @TypDanych;					
					SET @ColumnsForCursor += ', [' + @NazwaKolumny + ']';
					SET @VariablesForCursor += ', @' + @VariableGoodName;
					
					print 'var: |' + @NazwaKolumny + '|   -   |' + @VariableGoodName + '|'
				END							
				
				FETCH NEXT FROM curs INTO @NazwaKolumny, @TypDanych
			END
			CLOSE curs;
			DEALLOCATE curs;
							
	SET @Query += '
			SET @CreateNewRowForHistory = 0;
	
			DECLARE cur_TypObiektuInst_UPDATE CURSOR FOR
				SELECT Id, Nazwa, ValidFrom, CreatedBy, IdArchLink, ObowiazujeOd, ObowiazujeDo, CreatedOn, 
					IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom' + @ColumnsForCursor + '
				FROM deleted
			OPEN cur_TypObiektuInst_UPDATE 
			FETCH NEXT FROM cur_TypObiektuInst_UPDATE INTO @ID, @Nazwa, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo, @CreatedOn,
				@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSFromBy, @StatusPFromBy, @StatusWFromBy, @StatusSFrom, @StatusPFrom, @StatusWFrom' + @VariablesForCursor + '
			WHILE @@fetch_status = 0
			BEGIN
	
				SELECT @WaznyodNEW = ValidFrom, @CzyWaznyNEW = IsValid, @UtworzonyPrzezNEW = LastModifiedBy, @NazwaNEW = Nazwa,
					@DataModyfikacjiApp = LastModifiedOn, @RealCreatedOn = RealCreatedOn, @RealLastModifiedOn = RealLastModifiedOn
				FROM inserted WHERE ID = @ID
			
				IF @CzyWaznyNEW = 1
				BEGIN
				
					IF @CreateNewRowForHistory = 1
					BEGIN
						INSERT INTO [dbo].[_' + @NewName + ']
						   ([IdArch], IdArchLink, Nazwa, [IsValid], [ValidFrom], [ValidTo], [CreatedOn], [CreatedBy], [LastModifiedOn], [LastModifiedBy], 
							ObowiazujeOD, ObowiazujeDo, IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, 
							StatusWFrom, StatusSTo, StatusPTo, StatusWTo, StatusSToBy, StatusPToBy, StatusWToBy' + @ColumnsForCursor + ')'
		   
			   SET @Query += ' 
						SELECT @ID,ISNULL(@IdArchLink,@ID), @Nazwa, 0, @WaznyOd, @DataModyfikacjiApp, @WaznyOd, @UtworzonyPrzez, @DataModyfikacjiApp, @UtworzonyPrzezNEW, 
							@ObowiazujeOD, @ObowiazujeDo, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSFromBy, @StatusPFromBy, @StatusWFromBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, 
							CASE
								WHEN @StatusSFrom IS NOT NULL THEN @DataModyfikacjiApp ELSE NULL
							END,
							CASE
								WHEN @StatusPFrom IS NOT NULL THEN @DataModyfikacjiApp ELSE NULL
							END,
							CASE
								WHEN @StatusWFrom IS NOT NULL THEN @DataModyfikacjiApp ELSE NULL
							END,
							CASE
								WHEN @StatusSFrom IS NOT NULL THEN @UtworzonyPrzezNEW ELSE NULL
							END,
							CASE
								WHEN @StatusPFrom IS NOT NULL THEN @UtworzonyPrzezNEW ELSE NULL
							END,
							CASE
								WHEN @StatusWFrom IS NOT NULL THEN @UtworzonyPrzezNEW ELSE NULL
							END' + @VariablesForCursor + '				

						SELECT @hist = @@IDENTITY

						UPDATE [dbo].[_' + @NewName + ']
						SET ValidFrom = @DataModyfikacjiApp
						,[CreatedBy] = @UtworzonyPrzezNEW
						,LastModifiedOn = NULL
						,LastModifiedBy = NULL
						,CreatedOn = ISNULL(@DataModyfikacjiApp, @WaznyodNEW)
						,RealCreatedOn = ISNULL(@RealLastModifiedOn, @RealCreatedOn)
						,RealDeletedFrom = NULL
						,RealLastModifiedOn = NULL
						,IdArchLink = @hist
						,IdArch = NULL
						WHERE ID = @ID
					END
					ELSE
					BEGIN
						UPDATE [dbo].[_' + @NewName + '] SET
							CreatedOn = @CreatedOn
							,CreatedBy = @UtworzonyPrzez
							,ObowiazujeOd = @ObowiazujeOD
						WHERE ID = @ID
					END
				END
			
				FETCH NEXT FROM cur_TypObiektuInst_UPDATE INTO @ID, @Nazwa, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo, @CreatedOn,
					@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSFromBy, @StatusPFromBy, @StatusWFromBy, @StatusSFrom, @StatusPFrom, @StatusWFrom' + @VariablesForCursor + '
			END
			
			CLOSE cur_TypObiektuInst_UPDATE
			DEALLOCATE cur_TypObiektuInst_UPDATE	
		END	'
			print 'tttteeeee'	
		PRINT @Query
		EXECUTE sp_executesql @Query
		
	IF OBJECT_ID('tempdb..#KolumnyTypuObiektuTrig') IS NOT NULL
		DROP TABLE #KolumnyTypuObiektuTrig
END

	
				
