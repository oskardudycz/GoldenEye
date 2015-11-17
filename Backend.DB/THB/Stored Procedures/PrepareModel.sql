-- =============================================
-- Author:		DK
-- Create date: 2012-07-10
-- Last modified on: 2013-06-24
-- Description:	Próbuje stworzyc model struktury z danymi potrzebnymi do wyliczen. 
-- zwraca Success = 0 jesli sie nie udalo lub Korzen nie ma zadnych relacji do podelementow.
-- =============================================
CREATE PROCEDURE [THB].[PrepareModel]
(
	@SessionId int,
	@StructureId int,
	--@AttributeC1Id int,
	@AttributeValues varchar(200) = NULL, -- lista dopuszczalnych wartosci Id cech bioracych udzial w przetwarzaniu
	@GetObjectAttributes bit = 1,
	@ObiektO1Id int = NULL,	-- id obiektu O1 od ktorego ma byc rozpoczete przetwarzanie
	@TypObiektuO1Id int = NULL, -- id typu obiektu od ktorego ma byc rozpoczete przetwarzanie
	@StartDate date,
	@EndDate date,
	@StatusS int = NULL,
	@StatusP int = NULL,
	@StatusW int = NULL,
	@Success bit OUTPUT,
	@ERRMSG nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET @Success = 1;

	DECLARE @Query nvarchar(max) = '',
		@NazwaTypuObiektu nvarchar(500),
		@DataModyfikacji datetime = GETDATE(),
		@TypObiektuId int,
		@ObiektId int,
		@NObiektId_L int,
		@NObiektId_R int,
		@RootObiektId int,
		@RootTypObiektuId int,
		@Counter int = 1,
		@RelacjaId int,
		@DateRange nvarchar(500) = '',
		@StatusesQuery nvarchar(200) = '',
		@StrukturaOK bit = 0,
		@TypStruktury_ObiektId int,
		@SaRelacjeDoPobrania bit = 1
	
	--usuwanie tabel tymczasowych, jesli istnieja
	IF OBJECT_ID('tempdb..#BazoweRelacjeStruktury') IS NOT NULL
		DROP TABLE #BazoweRelacjeStruktury;
	
	IF OBJECT_ID('tempdb..#RelacjeStruktury') IS NOT NULL
		DROP TABLE #RelacjeStruktury;
		
	IF OBJECT_ID('tempdb..#ObiektyStruktury') IS NOT NULL
		DROP TABLE #ObiektyStruktury;
		
	IF OBJECT_ID('tempdb..#ObiektyZRelacji') IS NOT NULL
		DROP TABLE #ObiektyZRelacji;
		
	IF OBJECT_ID('tempdb..#ObiektyZRelacji_Copy') IS NOT NULL
		DROP TABLE #ObiektyZRelacji_Copy;
	
	CREATE TABLE #ObiektyZRelacji(ObiektId int, TypObiektuId int);
	CREATE TABLE #ObiektyZRelacji_Copy(ObiektId int, TypObiektuId int);
	CREATE TABLE #BazoweRelacjeStruktury(RelacjaId int, TypObiektuL int, ObiektL int, TypObiektuR int, ObiektR int);
	CREATE TABLE #RelacjeStruktury(RelacjaId int, TypObiektuL int, ObiektL int, TypObiektuR int, ObiektR int);
	CREATE TABLE #ObiektyStruktury (TypObiektuId int, ObiektId int);
	
	BEGIN TRY	
		BEGIN TRAN T1
		
		--jesli nie okreslono obiektu od ktorego ma nastapic przetwarzanie, do pobranie tych danych na podstawie strktury
		IF @ObiektO1Id IS NULL OR @TypObiektuO1Id IS NULL
		BEGIN
			SELECT @ObiektO1Id = Obiekt_Id, @TypStruktury_ObiektId = TypStruktury_Obiekt_Id
			FROM Struktura_Obiekt
			WHERE Id = @StructureId;
			
			SELECT @TypObiektuO1Id = TypObiektuIdRoot
			FROM TypStruktury_Obiekt
			WHERE Id = @TypStruktury_ObiektId;		
		END
	
	--	SET @DateRange += ' AND (ValidFrom <= ''' + CONVERT(varchar, @StartDate, 112) + ' 23:59:59'' AND (ValidTo IS NULL OR ValidTo >= ''' + CONVERT(varchar, @EndDate, 112) + ' 00:00:00'' )) ';

		SET @DateRange += [THB].[PrepareDatesPhraseExtended] (NULL, @StartDate, 1);
		SET @StatusesQuery = [THB].[PrepareStatusesPhrase] (NULL, @StatusS, @StatusP, @StatusW);

		--IF @StatusW IS NOT NULL
		--	SET @StatusesQuery += ' AND StatusW = ' + CAST(@StatusW AS varchar);
			
		--IF @StatusS IS NOT NULL
		--	SET @StatusesQuery += ' AND StatusS = ' + CAST(@StatusS AS varchar);
			
		--IF @StatusP IS NOT NULL
		--	SET @StatusesQuery += ' AND StatusP = ' + CAST(@StatusP AS varchar);
		
		-- pobranie cech na dany moment aplikacji
		IF @GetObjectAttributes = 1
		BEGIN
			SET @Query = '
			INSERT INTO dbo.[Alg_Cechy] (SesjaId, CechaId, Typ, Opis, CreatedOn)
			SELECT ' + CAST(@SessionId AS varchar) + ', c.Cecha_ID, ct.NazwaSQL, c.Nazwa, ''' + CAST(@DataModyfikacji AS varchar) + '''
			FROM dbo.Cechy c
			JOIN dbo.Cecha_Typy ct ON (c.TypID = ct.Id)
			WHERE c.IdArch IS NULL AND c.IsValid = 1'
			
			--SET @Query += ' AND (c.ValidFrom <= ''' + CONVERT(varchar, @StartDate, 112) + ' 23:59:59'' AND (c.ValidTo IS NULL OR c.ValidTo >= ''' + CONVERT(varchar, @EndDate, 112) + ' 00:00:00'' )) ';
		
			SET @Query += [THB].[PrepareDatesPhraseExtended] ('c', @StartDate, 1);
		
			IF @AttributeValues IS NOT NULL AND LEN(@AttributeValues) > 0
				SET @Query += ' AND c.Cecha_ID IN (' + @AttributeValues + ')';
		
			--PRINT @Query;
			EXECUTE sp_executesql @Query
		END
		
		-- pobranie typow relacji na dany moment aplikacji
		SET @Query = '
		INSERT INTO dbo.Alg_TypyRelacji (SesjaId, TypRelacjiId, BazowyTypRelacjiid, Nazwa, CreatedOn)
		SELECT ' + CAST(@SessionId AS varchar) + ', tr.TypRelacji_ID, tr.BazowyTypRelacji_ID, tr.Nazwa, ''' + CAST(@DataModyfikacji AS varchar) + '''
		FROM dbo.[TypRelacji] tr
		WHERE tr.IdArch IS NULL AND tr.IsValid = 1 AND tr.IsDeleted = 0';
		
		SET @Query += @DateRange	
		--PRINT @Query;	
		EXECUTE sp_executesql @Query
		
		-- wyciagniecie danych korzenia - typObiektu ID i obiekt ID
		SELECT @RootObiektId = so.Obiekt_Id, @RootTypObiektuId = tso.TypObiektuIdRoot
		FROM dbo.Struktura_Obiekt so
		JOIN dbo.TypStruktury_Obiekt tso ON (tso.Id = so.TypStruktury_Obiekt_Id)
		WHERE so.Id = @StructureId
		
		--pobranie bazowych relacji - wszystkich dla podanej strukury  
		SET @Query = '
		INSERT INTO #BazoweRelacjeStruktury(RelacjaId, TypObiektuL, ObiektL, TypObiektuR, ObiektR)
		SELECT r.Id, r.TypObiektuID_L, r.ObiektID_L, r.TypObiektuID_R, r.ObiektID_R
		FROM dbo.Relacje r 
		JOIN dbo.Struktura s ON (r.Id = s.RelacjaId)
		WHERE s.StrukturaObiektId = ' + CAST(@StructureId AS varchar) + ' AND s.IsValid = 1 AND r.IsValid = 1' -- AND s.IsDeleted = 0 AND r.IsDeleted = 0';
	
		SET @Query += [THB].[PrepareDatesPhraseExtended] ('s', @StartDate, 1);
	
		--SET @Query += ' AND (s.ValidFrom <= ''' + CONVERT(varchar, @StartDate, 112) + ' 23:59:59'' AND (s.ValidTo IS NULL OR s.ValidTo >= ''' + CONVERT(varchar, @EndDate, 112) + ' 00:00:00'' ))
		--	AND (r.ValidFrom <= ''' + CONVERT(varchar, @StartDate, 112) + ' 23:59:59'' AND (r.ValidTo IS NULL OR r.ValidTo >= ''' + CONVERT(varchar, @EndDate, 112) + ' 00:00:00'' )) ';

		--IF @StatusW IS NOT NULL
		--	SET @StatusesQuery += ' AND s.StatusW = ' + CAST(@StatusW AS varchar) + ' AND r.StatusW = ' + CAST(@StatusW AS varchar);
			
		--IF @StatusS IS NOT NULL
		--	SET @StatusesQuery += ' AND s.StatusS = ' + CAST(@StatusS AS varchar) + ' AND r.StatusS = ' + CAST(@StatusS AS varchar);
			
		--IF @StatusP IS NOT NULL
		--	SET @StatusesQuery += ' AND s.StatusP = ' + CAST(@StatusP AS varchar) + ' AND r.StatusP = ' + CAST(@StatusP AS varchar);
		
		SET @Query += [THB].[PrepareStatusesPhrase] ('s', @StatusS, @StatusP, @StatusW);
		SET @Query += [THB].[PrepareStatusesPhrase] ('r', @StatusS, @StatusP, @StatusW);
		
		--PRINT @Query
		EXECUTE sp_executesql @Query		
			
		--pobranie relacji korzenia struktury
		SET @Query = '
			INSERT INTO #RelacjeStruktury(RelacjaId, TypObiektuL, ObiektL, TypObiektuR, ObiektR)
			SELECT RelacjaId, TypObiektuL, ObiektL, TypObiektuR, ObiektR
			FROM #BazoweRelacjeStruktury
			WHERE TypObiektuL = ' + CAST(@TypObiektuO1Id AS varchar) + ' AND ObiektL = ' + CAST(@ObiektO1Id AS varchar);
		
		--PRINT @Query
		EXECUTE sp_executesql @Query

--SELECT * FROM #BazoweRelacjeStruktury
		
		-- pobieranie relacji pozostalych, pobranie relacji dla podanego korzenia - obiektu O1	
		-- pobranie obiektow do ktorych bezposrednie podobiekty korzenia maja relacje
		INSERT INTO #ObiektyZRelacji(ObiektId, TypObiektuId)
		SELECT ObiektR, TypObiektuR FROM #RelacjeStruktury

--SELECT * FROM #ObiektyZRelacji

		IF (SELECT COUNT(1) FROM #ObiektyZRelacji) > 0
		BEGIN
			WHILE @SaRelacjeDoPobrania = 1
			BEGIN				
			
				IF Cursor_Status('local','cur_pre') > 0 
				BEGIN
					 CLOSE cur_pre
					 DEALLOCATE cur_pre
				END	
						
				DECLARE cur_pre CURSOR LOCAL FOR
				SELECT DISTINCT TypObiektuId, ObiektId FROM #ObiektyZRelacji
				OPEN cur_pre
				FETCH NEXT FROM cur_pre INTO @TypObiektuId,	@ObiektId
				WHILE @@FETCH_STATUS = 0
				BEGIN

--SELECT * FROM #RelacjeStruktury
				
					--pobranie relacji pokolei dla kazdego z obiektow
					SET @Query = '
					INSERT INTO #RelacjeStruktury(RelacjaId, TypObiektuL, ObiektL, TypObiektuR, ObiektR)
					SELECT RelacjaId, TypObiektuL, ObiektL, TypObiektuR, ObiektR
					FROM #BazoweRelacjeStruktury
					WHERE TypObiektuL = ' + CAST(@TypObiektuId AS varchar) + ' AND ObiektL = ' + CAST(@ObiektId AS varchar);
					
					--PRINT @Query
					EXECUTE sp_executesql @Query
					
					INSERT INTO #ObiektyZRelacji_Copy(ObiektId, TypObiektuId)
					SELECT ObiektR, TypObiektuR FROM #RelacjeStruktury WHERE ObiektL = @ObiektId AND TypObiektuL = @TypObiektuId
					--    [From] IN (SELECT ObiektId FROM #Transf_A2_Obiekty);

					----przekopiowanie danych z jednej tabeli roboczej do drugiej
					--DELETE FROM #ObiektyZRelacji; 		
					
					--INSERT INTO #ObiektyZRelacji(ObiektId, TypObiektuId)
					--SELECT ObiektId, TypObiektuId FROM #ObiektyZRelacji_Copy;
					
					--DELETE FROM #ObiektyZRelacji_Copy;			
						
					--ustawienie flagi zwiazanej z petla
					--IF (SELECT COUNT(1) FROM #ObiektyZRelacji) > 0
					--	SET @SaRelacjeDoPobrania = 1;
					--ELSE
					--	SET @SaRelacjeDoPobrania = 0;
					
					
					FETCH NEXT FROM cur_pre INTO @TypObiektuId,	@ObiektId
				END
				CLOSE cur_pre;
				DEALLOCATE cur_pre;
	
--SELECT * FROM #ObiektyZRelacji_Copy
				
				--przekopiowanie danych z jednej tabeli roboczej do drugiej
				DELETE FROM #ObiektyZRelacji; 		
				
				INSERT INTO #ObiektyZRelacji(ObiektId, TypObiektuId)
				SELECT ObiektId, TypObiektuId FROM #ObiektyZRelacji_Copy;
				
				DELETE FROM #ObiektyZRelacji_Copy;
				
				--ustawienie flagi zwiazanej z petla
				IF (SELECT COUNT(1) FROM #ObiektyZRelacji) > 0
					SET @SaRelacjeDoPobrania = 1;
				ELSE
					SET @SaRelacjeDoPobrania = 0;

			END
		END
-----		
	
	/*	SET @Query = '
		INSERT INTO #RelacjeStruktury(RelacjaId)
		SELECT s.RelacjaId 
		FROM dbo.Struktura s
		JOIN dbo.Relacje r ON (r.Id = s.RelacjaId)
		WHERE s.StrukturaObiektId = ' + CAST(@StructureId AS varchar) + ' AND s.IsValid = 1 AND s.IsDeleted = 0 AND r.IsValid = 1 AND r.IsDeleted = 0';
	
		SET @Query += ' AND (s.ValidFrom <= ''' + CONVERT(varchar, @StartDate, 112) + ' 23:59:59'' AND (s.ValidTo IS NULL OR s.ValidTo >= ''' + CONVERT(varchar, @EndDate, 112) + ' 00:00:00'' ))
			AND (r.ValidFrom <= ''' + CONVERT(varchar, @StartDate, 112) + ' 23:59:59'' AND (r.ValidTo IS NULL OR r.ValidTo >= ''' + CONVERT(varchar, @EndDate, 112) + ' 00:00:00'' )) ';

		IF @StatusW IS NOT NULL
			SET @StatusesQuery += ' AND s.StatusW = ' + CAST(@StatusW AS varchar) + ' AND r.StatusW = ' + CAST(@StatusW AS varchar);
			
		IF @StatusS IS NOT NULL
			SET @StatusesQuery += ' AND s.StatusS = ' + CAST(@StatusS AS varchar) + ' AND r.StatusS = ' + CAST(@StatusS AS varchar);
			
		IF @StatusP IS NOT NULL
			SET @StatusesQuery += ' AND s.StatusP = ' + CAST(@StatusP AS varchar) + ' AND r.StatusP = ' + CAST(@StatusP AS varchar);
		
		EXECUTE sp_executesql @Query */		
	
		
		INSERT INTO #ObiektyStruktury (TypObiektuId, ObiektId)
		SELECT DISTINCT TypObiektuID_L AS TypObiektuId, ObiektID_L AS ObiektId
		FROM dbo.Relacje
		WHERE Id IN (SELECT RelacjaId FROM #RelacjeStruktury)
		UNION
		SELECT DISTINCT TypObiektuID_R AS TypObiektuId, ObiektID_R AS ObiektId
		FROM dbo.Relacje
		WHERE Id IN (SELECT RelacjaId FROM #RelacjeStruktury)

--SELECT * FROM #ObiektyStruktury
	
		IF (SELECT COUNT(1) FROM #ObiektyStruktury) > 0
		BEGIN
			--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
			IF Cursor_Status('local','cur') > 0 
			BEGIN
				 CLOSE cur
				 DEALLOCATE cur
			END

			DECLARE cur CURSOR LOCAL FOR 
			SELECT DISTINCT TypObiektuId FROM #ObiektyStruktury
			OPEN cur
			FETCH NEXT FROM cur INTO @TypObiektuId
			WHILE @@FETCH_STATUS = 0
			BEGIN
		
				SET @Counter = 1;
			
				-- wstawienie danych obiektu korzenia
				SELECT @NazwaTypuObiektu = Nazwa
				FROM dbo.TypObiektu
				WHERE TypObiekt_ID = @TypObiektuId
				
				IF @NazwaTypuObiektu IS NOT NULL AND LEN(@NazwaTypuObiektu) > 0
				BEGIN

					IF Cursor_Status('local','cur2') > 0 
					BEGIN
						 CLOSE cur2
						 DEALLOCATE cur2
					END

					DECLARE cur2 CURSOR LOCAL FOR 
					SELECT DISTINCT ObiektId FROM #ObiektyStruktury WHERE TypObiektuId = @TypObiektuId
					OPEN cur2
					FETCH NEXT FROM cur2 INTO @ObiektId
					WHILE @@FETCH_STATUS = 0
					BEGIN
						
						--pobranie danych obiektu
						SET @query = '
						IF OBJECT_ID (N''[_' + @NazwaTypuObiektu + ']'', N''U'') IS NOT NULL
						BEGIN			
							INSERT INTO dbo.[Alg_Obiekty] (SesjaId, ObiektId, TypObiektuId, OpisGeneric, Opis, InstanceId, CreatedOn)
							(SELECT ' + CAST(@SessionId AS varchar) + ', Id, ' + CAST(@TypObiektuId AS varchar) + ', ''' + @NazwaTypuObiektu + '_' + CAST(@Counter AS varchar) + ''', ''' + @NazwaTypuObiektu + ''', 1, ''' + CONVERT(nvarchar(50), @DataModyfikacji, 109) + '''
							FROM dbo.[_' + @NazwaTypuObiektu + ']
							WHERE Id = ' + CAST(@ObiektId AS varchar) + '
							)'
						
						-- pobranie cech obiektu
						IF @GetObjectAttributes = 1
						BEGIN
							SET @query += '
												
							INSERT INTO dbo.[Alg_ObiektyCechy] (SesjaId, ObiektId, CechaId, VirtualTypeId, IsValidForAlgorithm, CalculatedByAlgorithm, AlgorithmRun, ValString, ColumnsSet, CreatedOn)
							(SELECT  ' + CAST(@SessionId AS varchar) + ', IDENT_CURRENT(''Alg_Obiekty''), (SELECT ac.Id FROM Alg_Cechy ac WHERE ac.CechaID = ch.CechaID AND ac.SesjaId = ' + CAST(@SessionId AS varchar) + '), 
								ISNULL(VirtualTypeId, 0), IsValidForAlgorithm, CalculatedByAlgorithm, AlgorithmRun, ValString, 
								THB.GetAttributeValueFromSparseXML(ColumnsSet) , ''' + CONVERT(nvarchar(50), @DataModyfikacji, 109) + ''' 
							FROM dbo.[_' + @NazwaTypuObiektu + '_Cechy_Hist] ch
							WHERE ch.ObiektId = ' + CAST(@ObiektId AS varchar) + ' AND ch.IdArch IS NULL AND ch.IsValid = 1' -- AND ch.IsDeleted = 0 ' -- AND ch.CechaID = ' + CAST(@AttributeC1Id AS varchar)
							 + @DateRange + [THB].[PrepareStatusesPhrase] ('ch', @StatusS, @StatusP, @StatusW);
						
							--jesli pobieranie tylko niektorych cech to dodanie warunku do frazy WHERE
							IF @AttributeValues IS NOT NULL AND LEN(@AttributeValues) > 0
								SET @Query += ' AND ch.CechaID IN (' + @AttributeValues + ')';	 
								 
							SET @Query += '
							)'
						END
						
						SET @Query += '
						END'
						
						--PRINT @Query;
						EXECUTE sp_executesql @Query
						
						SET @Counter = @Counter + 1;
						FETCH NEXT FROM cur2 INTO @ObiektId
					END
					CLOSE cur2;
					DEALLOCATE cur2;
				END
				
				FETCH NEXT FROM cur INTO @TypObiektuId
			END
			CLOSE cur;
			DEALLOCATE cur;

			IF (SELECT COUNT(1) FROM #RelacjeStruktury) > 0
			BEGIN
				-- przetworzenie relacji miedzy obiektami
				IF Cursor_Status('local','cur') > 0 
				BEGIN
					 CLOSE cur
					 DEALLOCATE cur
				END

				DECLARE cur CURSOR LOCAL FOR 
				SELECT DISTINCT RelacjaId FROM #RelacjeStruktury
				OPEN cur
				FETCH NEXT FROM cur INTO @RelacjaId
				WHILE @@FETCH_STATUS = 0
				BEGIN
					SELECT @NObiektId_L = ao.Id
					FROM Alg_Obiekty ao, Relacje r
					WHERE r.Id = @RelacjaId AND ao.ObiektId = r.ObiektID_L AND ao.TypObiektuId = r.TypObiektuID_L;
					
					SELECT @NObiektId_R = ao.Id
					FROM Alg_Obiekty ao, Relacje r
					WHERE r.Id = @RelacjaId AND ao.ObiektId = r.ObiektID_R AND ao.TypObiektuId = r.TypObiektuID_R;
					
					INSERT INTO dbo.Alg_ObiektyRelacje (SesjaId, ObiektId_L, ObiektId_R, TypRelacjiId, CreatedOn, RelacjaId)
					SELECT @SessionId, @NObiektId_L, @NObiektId_R, tr.Id, @DataModyfikacji, @RelacjaId
					FROM dbo.Relacje r
					JOIN dbo.Alg_TypyRelacji tr ON (r.TypRelacji_ID = tr.TypRelacjiId)
					WHERE r.Id = @RelacjaId AND tr.SesjaId = @SessionId
					
					FETCH NEXT FROM cur INTO @RelacjaId		
				END
				CLOSE cur;
				DEALLOCATE cur;
			END
			ELSE
				-- brak relacji dla podanej struktury
				SET @Success = 0;				
				
			--ustawienie flagi dla obiektu bedacego korzeniem struktury		
			UPDATE O
				SET KorzenStruktury = 1
			FROM Alg_Obiekty O WITH(NOLOCK) JOIN 
			(
				SELECT [Id]
				FROM Alg_Obiekty O1 WITH(NOLOCK)
				WHERE O1.SesjaId = @SessionId AND NOT EXISTS (SELECT [ObiektId_R] FROM Alg_ObiektyRelacje OR1 WHERE O1.[Id] = OR1.[ObiektId_R])
			) O3 ON (O.[Id] = O3.[Id])
			WHERE O.SesjaId = @SessionId;
			
			-- ustawienie flagi dla obiektow bedacych liscmi struktury
			UPDATE O
				SET LiscStruktury = 1
			FROM Alg_Obiekty O WITH(NOLOCK) JOIN 
			(
				SELECT [Id]
				FROM Alg_Obiekty O1 WITH(NOLOCK)
				WHERE O1.SesjaId = @SessionId AND NOT EXISTS (SELECT [ObiektId_L] FROM Alg_ObiektyRelacje OR1 WHERE O1.[Id] = OR1.[ObiektId_L])
			) O3 ON (O.[Id] = O3.[Id])
			WHERE O.SesjaId = @SessionId;
			
		END
		ELSE
		BEGIN
			-- brak obiektow dla podanej struktury			
			SET @ERRMSG = 'Podana struktura w podanym zakresie dat nie posiada żadnych relacji lub obiektów.'
			SET @Success = 0;
		END
	
		COMMIT TRAN T1
		
	END TRY
	BEGIN CATCH
		SET @Success = 0;
		SET @ERRMSG = ERROR_MESSAGE();
		
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN T1;
		END
		
	END CATCH
	
	--usuwanie tabel tymczasowych, jesli istnieja
	IF OBJECT_ID('tempdb..#BazoweRelacjeStruktury') IS NOT NULL
		DROP TABLE #BazoweRelacjeStruktury;
	
	IF OBJECT_ID('tempdb..#RelacjeStruktury') IS NOT NULL
		DROP TABLE #RelacjeStruktury;
		
	IF OBJECT_ID('tempdb..#ObiektyStruktury') IS NOT NULL
		DROP TABLE #ObiektyStruktury;
		
	IF OBJECT_ID('tempdb..#ObiektyZRelacji') IS NOT NULL
		DROP TABLE #ObiektyZRelacji;
		
	IF OBJECT_ID('tempdb..#ObiektyZRelacji_Copy') IS NOT NULL
		DROP TABLE #ObiektyZRelacji_Copy;
	
END
