-- =============================================
-- Author:		DK
-- Create date: 2012-05-14
-- Description:	Próbuje przepisac pomiary z licznikow na ujecia

-- =============================================
CREATE PROCEDURE [THB].[RewriteMeasurements_S]
(
	@SessionId int,
	@AttributeCollectedId int, -- Cecha zbierana
	@AttributeCollectingId int, -- Cecha zbierajaca
	@Success bit OUTPUT,
	@ResultValue xml OUTPUT,
	@ERRMSG nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET @Success = 1;

	DECLARE @Query nvarchar(max) = '',
		@ObiektId int,
		@DataModyfikacji datetime = GETDATE(),
		@CechaId int,
		@ValString nvarchar(255),
		@XmlSparse xml,
		@From int,
		@To int,
		@TmpZuzycie int,
		@XmlValue xml,
		@TypDanych varchar(30),
		@TypDanychKorzenia varchar(30),
		@WartoscDanych varchar(50)
	--	@SaLiscie bit = 1
	--	@RelacjaMierzyId int = 61,
	--	@CechaZuzycieId int = 302,
	--	@CechaOdczytLicznikaId int = 37		
	
	--usuwanie tabel tymczasowych, jesli istnieja
	IF OBJECT_ID('tempdb..#PomiaryLicznikow') IS NOT NULL
		DROP TABLE #PomiaryLicznikow;
	
	IF OBJECT_ID('tempdb..#Transf_1') IS NOT NULL
		DROP TABLE #Transf_1;

	IF OBJECT_ID('tempdb..#Transf_1_Copy') IS NOT NULL
		DROP TABLE #Transf_1_Copy;
		
	CREATE TABLE #Transf_1_Copy(Id int, [From] int, [To] int, [Parent] int, Leaf int);
	
	BEGIN TRY
	
		--pobranie pomiarow z obiektow liczacych na wezel wyzej (kran/ujecie)
		--SELECT aoc.CechaId, aoc.ValString, aoc.ColumnsSet, aor.ObiektId_L AS ObiektId
		--INTO #PomiaryLicznikow
		--FROM Alg_ObiektyCechy aoc
		--JOIN Alg_ObiektyRelacje aor ON (aoc.ObiektId = aor.ObiektId_R)
		--JOIN Alg_TypyRelacji atr ON (aor.TypRelacjiId = atr.Id)
		--WHERE aoc.SesjaId = @SessionId 
		----AND atr.TypRelacjiId = @RelacjaMierzyId
		--AND aoc.CechaId = @AttributeCollectedId --@CechaOdczytLicznikaId			
		
		--pobranie relacji dla obiektow (3) majacych ceche zliczana i zliczajaca)
		SELECT Id, ObiektId_L AS [From], ObiektId_R AS [To], NULL AS [Parent], NULL AS [Leaf]
		INTO #Transf_1
		FROM Alg_ObiektyRelacje WITH(NOLOCK)
		--WHERE TypRelacjiId = @RelacjaPowiazanie
		WHERE ObiektId_L IN (SELECT DISTINCT ObiektId FROM Alg_ObiektyCechy WHERE CechaId = @AttributeCollectingId) 
		AND ObiektId_R IN (SELECT DISTINCT ObiektId FROM Alg_ObiektyCechy WHERE CechaId = @AttributeCollectedId OR CechaId = @AttributeCollectingId)
		AND SesjaId = @SessionId

--SELECT * FROM #Transf_1	
--SELECT * FROM Alg_ObiektyCechy WHERE SesjaId = @SessionId

		IF (SELECT COUNT(1) FROM #Transf_1) > 0
		BEGIN
			-- 1 ustawienie flagi dla obiektu bedacego rodzicem (ktory nie ma nadwezla)
			UPDATE T
				SET Parent = 1
			FROM #Transf_1 T  WITH(NOLOCK) JOIN 
			(
				SELECT [From]
				FROM #Transf_1 T1 WITH(NOLOCK)
				WHERE NOT EXISTS (SELECT [From] FROM #Transf_1 T2 WHERE T1.[From] = T2.[To])
			) T3 ON T.[From] = T3.[From];
			
			-- ustawienie flagi 1 dla obiektow prawych (TO), ktore sa liscmi w danej chwili
			UPDATE T
				SET Leaf = 1
			FROM #Transf_1 T  WITH(NOLOCK) JOIN 
			(
				SELECT [To]
				FROM #Transf_1 T1 WITH(NOLOCK)
				WHERE NOT EXISTS (SELECT [From] FROM #Transf_1 T2 WHERE T1.[To] = T2.[From] AND Leaf IS NULL)
			) T3 ON T.[To] = T3.[To];
			
--SELECT * FROM #Transf_1	
			
			-- przesylanie danych z lisci w gore
			WHILE (SELECT COUNT(1) FROM #Transf_1 WHERE Leaf = 1 AND Parent IS NULL) > 0
			BEGIN
				-- obrot petli
				
				--przygotowanie danychw  tabeli pomocniczej
				DELETE FROM #Transf_1_Copy;
				
				INSERT INTO #Transf_1_Copy(Id, [From], [To], [Parent], Leaf)
				SELECT Id, [From], [To], [Parent], Leaf
				FROM #Transf_1

print 'obtot petli'
				
				DECLARE cur5 CURSOR LOCAL FOR
				SELECT [From], [To] FROM #Transf_1_Copy WHERE Leaf = 1 AND Parent IS NULL
				OPEN cur5
				FETCH NEXT FROM cur5 INTO @from, @to
				WHILE @@FETCH_STATUS = 0
				BEGIN
print 'cursor'
					-- sprawdzenie czy istneije juz wpis dla cechy dla podanego obiektu
					IF EXISTS (SELECT CechaId FROM Alg_ObiektyCechy WHERE SesjaId = @SessionId AND ObiektId = @from AND CechaId = @AttributeCollectingId) -- @CechaZuzycieId ) --cechaId
					BEGIN
						SET @XmlValue = (SELECT ColumnsSet FROM Alg_ObiektyCechy WHERE SesjaId = @SessionId AND ObiektId = @to AND (CechaId = @AttributeCollectedId OR CechaId = @AttributeCollectingId))
						--SET @TmpZuzycie = (SELECT ValInt FROM Alg_ObiektyCechy WHERE SesjaId = @SessionId AND ObiektId = @to AND (CechaId = @AttributeCollectedId OR CechaId = @AttributeCollectingId))
						
						IF @XmlValue IS NOT NULL
						BEGIN
							
							SELECT	@TypDanych = C.value('local-name(.)', 'varchar(30)')
									,@WartoscDanych = C.value('text()[1]', 'nvarchar(200)')
									FROM @XmlValue.nodes('/*') AS t(c)
							
							SET @Query = '
							UPDATE Alg_ObiektyCechy SET ' +
							@TypDanych + ' = ISNULL(' + @TypDanych + ', 0) + ISNULL(' + @WartoscDanych + ', 0)
							WHERE SesjaId = ' + CAST(@SessionId AS varchar) + ' AND ObiektId = ' + CAST(@From AS varchar) + 
							' AND CechaId = ' + CAST(@AttributeCollectingId AS varchar)
							
							--PRINT @Query
							EXECUTE sp_executesql @Query
						END
					END
					
					--ustawienie flagi dla aktualnych lisci jako przetworzone
					UPDATE #Transf_1 SET
					Leaf = 0
					WHERE [From] = @From AND [To] = @To AND Leaf = 1 -- AND Parent IS NULL;
	
					-- ustawienie flagi dla nowych lisci do przetworzenia dla tych wezlow ktore nie maja juz relacji
					UPDATE t1 SET
					Leaf = 1
					FROM #Transf_1 t1  WITH(NOLOCK)
					WHERE [To] = @From AND Leaf IS NULL AND NOT EXISTS (SELECT [From] FROM #Transf_1 t2 WHERE ([From] = @From OR [To] = @From) AND (Leaf IS NULL OR Leaf = 1) AND t1.Id <> t2.Id)
					
					--UPDATE #Transf_1 t1 SET
					--Leaf = 1
					--WHERE [To] = @From AND Leaf IS NULL AND NOT EXISTS (SELECT [From] FROM #Transf_1 t2 WHERE [From] = @From AND Leaf IS NULL AND t1.Id <> t2.Id)
--AND Parent IS NULL
--SELECT * FROM Alg_ObiektyCechy WHERE SesjaId = @SessionId

--SELECT * FROM #Transf_1	
			
					FETCH NEXT FROM cur5 INTO @From, @To;
				END
				CLOSE cur5;
				DEALLOCATE cur5;
				
--SELECT * FROM #Transf_1
			END
			
			-- pobranie danych relacji korzenia i przepisanie pomiaru z wezla polaczonego z korzeniem na korzen
			SELECT @From = [From], @To = [To]
			FROM #Transf_1 WHERE Parent = 1;

			SET @Query = '
			UPDATE Alg_ObiektyCechy SET ' +
			@TypDanych + ' = ISNULL(' + @TypDanych + ', 0) + (SELECT ISNULL(' + @TypDanych + ', 0) FROM Alg_ObiektyCechy WHERE SesjaId = ' 
			+ CAST(@SessionId AS varchar) + ' AND ObiektId = ' + CAST(@To AS varchar) + ' AND CechaId = ' + CAST(@AttributeCollectingId AS varchar) + ')
			WHERE SesjaId = ' + CAST(@SessionId AS varchar) + ' AND ObiektId = ' + CAST(@From AS varchar) + ' AND CechaId = ' + CAST(@AttributeCollectingId AS varchar)
			
			--PRINT @Query
			EXECUTE sp_executesql @Query
			
			--pobranie wyniku obliczen i zwrocenie go
			SET @ResultValue = (SELECT ColumnsSet FROM Alg_ObiektyCechy WHERE SesjaId = @SessionId AND ObiektId = @From AND CechaId = @AttributeCollectingId); 
			
		END
		ELSE
			SET @ERRMSG = 'Nie istnieje żadna 3 spełniająca kryterium przesyłu danych po drzewie od liścia do korzenia.';
		
	END TRY
	BEGIN CATCH
		SET @Success = 0;
		print 'rollback'
		SELECT ERROR_MESSAGE();
	END CATCH
	
	IF OBJECT_ID('tempdb..#PomiaryLicznikow') IS NOT NULL
		DROP TABLE #PomiaryLicznikow;

END
