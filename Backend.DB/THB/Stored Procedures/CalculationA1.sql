-- =============================================
-- Author:		DK
-- Create date: 2012-06-22
-- Description:	Realizuje algorytm sumujący A1.
-- =============================================
CREATE PROCEDURE [THB].[CalculationA1]
(
	@SessionId int,
	@UserId int,
	@AttributeC1Id int, -- Cecha C1, ktora powinna posiadac 2 typy
	
	-- okreslenie obektu O1 bedacego korzeniem struktury dalej przetwarzanej w algorytmie
	@O1ObiektId int = NULL,
	@O1TypObiektuId int = NULL,
	
	@Success bit OUTPUT,
	@ResultValue xml OUTPUT,
	@ERRMSG nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET @Success = 1;

	DECLARE @Query nvarchar(max) = '',
		@DataModyfikacji datetime = GETDATE(),
		@CechaId int,
		@ValString nvarchar(255),
		@XmlSparse xml,
		@From int,
		@To int,
		@DodajJednostkowe bit = 0,
		@Id int,		
		@XmlJednostkowa xml,
		@XmlAgregujaca xml,
		@WartoscDanychJednostkowa varchar(30),
		@WartoscDanychAgregujaca varchar(30),
		@TypDanychJednostkowa varchar(20),
		@TypDanychAgregujaca varchar(20),		
		@AlgorytmA1Id int = 1, -- Id algorytmu A1 - rozdzielajacego
		@LastRunId int = 0,
		@ObiektId int,
		@IdObiektKorzen int,
		@SaRelacjeDoPobrania bit = 1,		
		
		--identyfikatory po ktorych rozrozniane sa cechy zwykla od agregujacej i wagowej
		@VirtualZwyklaCecha int = 0,
		@VirtualAgregujacaCecha int = 1	
	
	--usuwanie tabel tymczasowych, jesli istnieja	
	IF OBJECT_ID('tempdb..#ObiektyZCechami') IS NOT NULL
		DROP TABLE #ObiektyZCechami;
	
	IF OBJECT_ID('tempdb..#Transf_1') IS NOT NULL
		DROP TABLE #Transf_1;

	IF OBJECT_ID('tempdb..#Transf_1_Copy') IS NOT NULL
		DROP TABLE #Transf_1_Copy;
		
	IF OBJECT_ID('tempdb..#Transf_1_Obiekty') IS NOT NULL
		DROP TABLE #Transf_1_Obiekty;
		
	IF OBJECT_ID('tempdb..#Transf_1_Obiekty_Copy') IS NOT NULL
		DROP TABLE #Transf_1_Obiekty_Copy;
	
	CREATE TABLE #Transf_1(Id int, [From] int, [To] int, [Parent] int, Leaf int);
	CREATE TABLE #Transf_1_Copy(Id int, [From] int, [To] int, [Parent] int, Leaf int);
	CREATE TABLE #ObiektyZCechami (Id int);
	CREATE TABLE #Transf_1_Obiekty(ObiektId int);
	CREATE TABLE #Transf_1_Obiekty_Copy(ObiektId int);
	
	BEGIN TRY	
		
		SET @ERRMSG = NULL;
		
		-- ustalenie nowego Id dla LastRun
		SET @LastRunId = (SELECT (SELECT ISNULL(MAX(LastRunId), 0) FROM Algorytmy_Uruchomienia WHERE AlgorytmId = @AlgorytmA1Id) + 1);
		
		--pobranie ID cechy z tabel tymczasowych
		SET @CechaId = (SELECT Id FROM Alg_Cechy WHERE SesjaId = @SessionId AND CechaId = @AttributeC1Id);
		
		-- sprawdzenie czy kazdy obiekt struktury ma cechy agregujace, jesli nie to ich stworzenie
		IF Cursor_Status('local','curWer') > 0 
		BEGIN
			 CLOSE curWer
			 DEALLOCATE curWer
		END

		DECLARE curWer CURSOR LOCAL FOR 
		SELECT Id FROM Alg_Obiekty WHERE SesjaId = @SessionId
		OPEN curWer
		FETCH NEXT FROM curWer INTO @ObiektId
		WHILE @@FETCH_STATUS = 0
		BEGIN

			IF NOT EXISTS (SELECT Id FROM Alg_ObiektyCechy WHERE ObiektId = @ObiektId AND SesjaId = @SessionId AND CechaId = @CechaId AND VirtualTypeId = @VirtualAgregujacaCecha)
			 AND EXISTS(SELECT Id FROM Alg_ObiektyCechy WHERE ObiektId = @ObiektId AND SesjaId = @SessionId AND CechaId = @CechaId AND VirtualTypeId = @VirtualZwyklaCecha)
			BEGIN						
				INSERT INTO Alg_ObiektyCechy(SesjaId, ObiektId, CechaId, VirtualTypeId, IsValidForAlgorithm, CreatedOn, CalculatedByAlgorithm, AlgorithmRun)
				VALUES(@SessionId, @ObiektId, @CechaId, @VirtualAgregujacaCecha, 1, @DataModyfikacji, @AlgorytmA1Id, @LastRunId);
			END
			
			FETCH NEXT FROM curWer INTO @ObiektId
		END
		CLOSE curWer
		DEALLOCATE curWer
	
		-- pobranie Id obiektow posiadajacych obie cechy jednoczesnie (zalozenie algorytmu)
		INSERT INTO #ObiektyZCechami(Id)
		SELECT Z.ObiektId  
		 FROM
		 (
			 SELECT ObiektId FROM Alg_ObiektyCechy
			 WHERE  CechaId = @CechaId AND VirtualTypeId = @VirtualZwyklaCecha -- @AttributeUnitId
			 UNION ALL
			 SELECT ObiektId FROM Alg_ObiektyCechy
			 WHERE CechaId = @CechaId AND VirtualTypeId = @VirtualAgregujacaCecha --@AttributeAggregateId
		 ) AS Z
		 GROUP BY Z.ObiektId
		 HAVING COUNT(Z.ObiektId) = 2
		 
		 
		 --pobranie relacji "w dol" od wskazanego wezla
		 
			-- jesli nie podano obiektu O1 lub podanym obiektem O1 jest korzen struktury to pobranie wszystkich relacji struktury
		IF @O1ObiektId IS NULL OR @O1TypObiektuId IS NULL OR (SELECT KorzenStruktury FROM Alg_Obiekty WHERE SesjaId = @SessionId AND ObiektId = @O1ObiektId AND TypObiektuId = @O1TypObiektuId) = 1
		BEGIN
			
--PRINT 'Relacje Korzenia';
			
			--pobranie relacji dla obiektow (3) majacych cechy jednostkowe i agregujace
			INSERT INTO #Transf_1([Id], [From], [To], [Parent], [Leaf])
			SELECT Id, ObiektId_L, ObiektId_R, NULL, NULL
			FROM Alg_ObiektyRelacje WITH(NOLOCK)
			WHERE ObiektId_L IN (SELECT Id FROM #ObiektyZCechami) -- AND TypRelacjiId = @RelacjaPowiazanie
			AND ObiektId_R IN (SELECT Id FROM #ObiektyZCechami)
			AND SesjaId = @SessionId
		END
		ELSE
		BEGIN
		 	
--PRINT 'Relacje Wezla';		 	
		 	
		 	-- pobranie ID korzenia
			SET @IdObiektKorzen = (SELECT Id FROM Alg_Obiekty WHERE SesjaId = @SessionId AND TypObiektuId = @O1TypObiektuId AND ObiektId = @O1ObiektId);
		
			-- pobranie relacji dla podanego korzenia - obiektu O1
			INSERT INTO #Transf_1([Id], [From], [To], [Parent], [Leaf])
			SELECT Id, ObiektId_L, ObiektId_R, NULL, NULL
			FROM Alg_ObiektyRelacje WITH(NOLOCK)
			WHERE ObiektId_L IN (SELECT Id FROM #ObiektyZCechami) 
			AND ObiektId_R IN (SELECT Id FROM #ObiektyZCechami)
			AND SesjaId = @SessionId AND ObiektId_L = @IdObiektKorzen;

			INSERT INTO #Transf_1_Obiekty(ObiektId)
			SELECT [To] FROM #Transf_1
		
			WHILE @SaRelacjeDoPobrania = 1
			BEGIN
				--pobranie relacji od obiektow bedacych ostatnio dziecmi
				INSERT INTO #Transf_1([Id], [From], [To], [Parent], [Leaf])
				SELECT Id, ObiektId_L, ObiektId_R, NULL, NULL
				FROM Alg_ObiektyRelacje WITH(NOLOCK)
				WHERE ObiektId_L IN (SELECT Id FROM #ObiektyZCechami)  
				AND ObiektId_R IN (SELECT Id FROM #ObiektyZCechami) 
				AND SesjaId = @SessionId AND ObiektId_L IN (SELECT ObiektId FROM #Transf_1_Obiekty);
				
				INSERT INTO #Transf_1_Obiekty_Copy(ObiektId)
				SELECT [To] FROM #Transf_1 WHERE [From] IN (SELECT ObiektId FROM #Transf_1_Obiekty);
	
				--przekopiowanie danych z jednej tabeli roboczej do drugiej
				DELETE FROM #Transf_1_Obiekty;			
					
				INSERT INTO #Transf_1_Obiekty(ObiektId)
				SELECT ObiektId FROM #Transf_1_Obiekty_Copy;
				
				DELETE FROM #Transf_1_Obiekty_Copy;
				
				--ustawienie flagi zwiazanej z petla
				IF (SELECT COUNT(1) FROM #Transf_1_Obiekty) > 0
					SET @SaRelacjeDoPobrania = 1;
				ELSE
					SET @SaRelacjeDoPobrania = 0;
			END
		END		

--SELECT * FROM #ObiektyZCechami;
--SELECT * FROM #Transf_1	
--SELECT * FROM Alg_ObiektyCechy WHERE SesjaId = @SessionId

		-- jesli sa jakies relacje w strukturze
		IF (SELECT COUNT(1) FROM #Transf_1) > 0
		BEGIN
		
		--	BEGIN TRAN TRAN_A1

			--zerowanie wartosci dla cech agregujacych dla obiektow ktore beda dalej przetwarzane
			SET @XmlAgregujaca = (SELECT TOP 1 ColumnsSet FROM Alg_ObiektyCechy WHERE SesjaId = @SessionId AND CechaId = @CechaId AND VirtualTypeId = @VirtualAgregujacaCecha); --@AttributeAggregateId);
			
			SELECT @TypDanychAgregujaca = C.value('local-name(.)', 'varchar(30)')
			FROM @XmlAgregujaca.nodes('/*') AS t(c)

			IF @TypDanychAgregujaca IS NOT NULL
			BEGIN
				UPDATE Alg_ObiektyCechy SET
				ValInt = NULL,
				ValBit = NULL,
				ValFLoat = NULL,
				ValDecimal = NULL,
				ValDate = NULL,
				ValDateTime = NULL,
				CalculatedByAlgorithm = @AlgorytmA1Id, 
				AlgorithmRun = @LastRunId
				WHERE CechaId = @CechaId AND VirtualTypeId = @VirtualAgregujacaCecha AND ObiektId IN (SELECT Id FROM #ObiektyZCechami) AND SesjaId = @SessionId;					
				
				SET @Query = 'UPDATE Alg_ObiektyCechy SET
				' + @TypDanychAgregujaca + ' = 0
				WHERE CechaId = ' + CAST(@CechaId AS varchar) + ' AND VirtualTypeId = ' + CAST(@VirtualAgregujacaCecha AS varchar) + ' AND ObiektId IN (SELECT Id FROM #ObiektyZCechami) AND SesjaId = ' + CAST(@SessionId AS varchar);
				
				--PRINT @Query;
				EXEC(@Query);
			END

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
--select * from alg_obiektyCechy

			-- dla lisci na starcie przepisanie wartosci cechy jednostkowej na agregujaca
			UPDATE T SET
				ColumnsSet = (SELECT TOP 1 ColumnsSet FROM Alg_ObiektyCechy T2 WHERE T.ObiektId = T2.ObiektId AND T2.CechaId = @CechaId AND T2.VirtualTypeId = @VirtualZwyklaCecha),
				CalculatedByAlgorithm = @AlgorytmA1Id, 
				AlgorithmRun = @LastRunId
			FROM Alg_ObiektyCechy T
			WHERE T.CechaId = @CechaId AND VirtualTypeId = @VirtualAgregujacaCecha AND T.ObiektId IN (SELECT [To] FROM #Transf_1 WHERE Leaf = 1) AND T.SesjaId = @SessionId		
			

--SELECT * FROM Alg_ObiektyCechy WHERE SesjaId = @SessionId
			
			-- przesylanie danych z lisci w gore
			WHILE (SELECT COUNT(1) FROM #Transf_1 WHERE Leaf = 1) > 0  -- AND Parent IS NULL
			BEGIN
				-- obrot petli
				
				--przygotowanie danychw  tabeli pomocniczej
				DELETE FROM #Transf_1_Copy;
				
				INSERT INTO #Transf_1_Copy(Id, [From], [To], [Parent], Leaf)
				SELECT Id, [From], [To], [Parent], Leaf
				FROM #Transf_1

--print 'obtot petli'
				
				DECLARE cur5 CURSOR LOCAL FOR
				SELECT Id, [From], [To] FROM #Transf_1_Copy WHERE Leaf = 1 --AND Parent IS NULL
				OPEN cur5
				FETCH NEXT FROM cur5 INTO @Id, @from, @to
				WHILE @@FETCH_STATUS = 0
				BEGIN
				
					IF NOT EXISTS (SELECT [From] FROM #Transf_1 WHERE [From] = @From AND (Leaf IS NULL OR Leaf = 1) AND Id <> @Id)
						SET @DodajJednostkowe = 1;
					ELSE
						SET @DodajJednostkowe = 0;
--print 'cursor'

					-- sprawdzenie czy istneije juz wpis dla cechy dla podanego obiektu
					IF EXISTS (SELECT CechaId FROM Alg_ObiektyCechy WHERE SesjaId = @SessionId AND ObiektId = @from AND CechaId = @CechaId AND VirtualTypeId = @VirtualAgregujacaCecha) -- @CechaZuzycieId ) --cechaId
					BEGIN
							
						-- pobranie wartosci cechy jednostkowej i zagregowanej obiektu prawego (liscia w danej chwili)
						SET @XmlAgregujaca = (SELECT TOP 1 ColumnsSet FROM Alg_ObiektyCechy WHERE SesjaId = @SessionId AND ObiektId = @to AND CechaId = @CechaId AND VirtualTypeId = @VirtualAgregujacaCecha);
						SET @XmlJednostkowa = (SELECT TOP 1 ColumnsSet FROM Alg_ObiektyCechy WHERE SesjaId = @SessionId AND ObiektId = @from AND CechaId = @CechaId AND VirtualTypeId = @VirtualZwyklaCecha); 
	
						
						IF @XmlAgregujaca IS NOT NULL
						BEGIN
							
							SELECT	@TypDanychAgregujaca = C.value('local-name(.)', 'varchar(30)')
									,@WartoscDanychAgregujaca = C.value('text()[1]', 'varchar(30)')
									FROM @XmlAgregujaca.nodes('/*') AS t(c)
						END
						
						IF @XmlJednostkowa IS NOT NULL
						BEGIN
							
							SELECT	@TypDanychJednostkowa = C.value('local-name(.)', 'varchar(30)')
									,@WartoscDanychJednostkowa = C.value('text()[1]', 'varchar(30)')
									FROM @XmlJednostkowa.nodes('/*') AS t(c)
						END
						
						SET @Query = '
							UPDATE Alg_ObiektyCechy SET ' +
							@TypDanychAgregujaca + ' = ISNULL(' + @TypDanychAgregujaca + ', 0) + ISNULL(' + @WartoscDanychAgregujaca + ', 0)'
							
							IF @DodajJednostkowe = 1
							BEGIN
								SET @Query += ' + ISNULL(' + @WartoscDanychJednostkowa + ', 0)';
							END 
							 
							SET @Query += ', CalculatedByAlgorithm = ' + CAST(@AlgorytmA1Id AS varchar) + ' 
							,AlgorithmRun = ' + CAST(@LastRunId AS varchar) + '
							WHERE SesjaId = ' + CAST(@SessionId AS varchar) + ' AND ObiektId = ' + CAST(@From AS varchar) + 
							' AND CechaId = ' + CAST(@CechaId AS varchar) + ' AND VirtualTypeId = ' + CAST(@VirtualAgregujacaCecha AS varchar)
							
							--PRINT @Query
							EXECUTE sp_executesql @Query;
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
					
--SELECT * FROM Alg_ObiektyCechy WHERE SesjaId = @SessionId
--SELECT * FROM #Transf_1	
			
					FETCH NEXT FROM cur5 INTO @Id, @From, @To;
				END
				CLOSE cur5;
				DEALLOCATE cur5;
				
--SELECT * FROM #Transf_1
			END
			
			-- pobranie danych relacji korzenia i przepisanie pomiaru z wezla polaczonego z korzeniem na korzen
			SELECT TOP 1 @From = [From], @To = [To]
			FROM #Transf_1 WHERE Parent = 1;

			--SET @Query = '
			--UPDATE Alg_ObiektyCechy SET ' +
			--@TypDanychAgregujaca + ' = ISNULL(' + @TypDanychAgregujaca + ', 0) + (SELECT ISNULL(' + @TypDanychAgregujaca + ', 0) FROM Alg_ObiektyCechy WHERE SesjaId = ' 
			--+ CAST(@SessionId AS varchar) + ' AND ObiektId = ' + CAST(@To AS varchar) + ' AND CechaId = ' + CAST(@AttributeC1Id AS varchar) + ' AND VirtualTypeId = ' + CAST(@VirtualAgregujacaCecha AS varchar) + ')
			--WHERE SesjaId = ' + CAST(@SessionId AS varchar) + ' AND ObiektId = ' + CAST(@From AS varchar) + ' AND CechaId = ' + CAST(@AttributeC1Id AS varchar) + ' AND VirtualTypeId = ' + CAST(@VirtualAgregujacaCecha AS varchar)
			
			----PRINT @Query
			--EXECUTE sp_executesql @Query
			
			--pobranie wyniku obliczen i zwrocenie go
			SET @ResultValue = (SELECT TOP 1 ColumnsSet FROM Alg_ObiektyCechy WHERE SesjaId = @SessionId AND ObiektId = @From AND CechaId = @CechaId AND VirtualTypeId = @VirtualAgregujacaCecha);
			
		--	COMMIT TRAN TRAN_A1

--SELECT * FROM Alg_ObiektyCechy WHERE SesjaId = @SessionId
			
		END
		ELSE
		BEGIN
			SET @Success = 0;
			SET @ERRMSG = 'Nie istnieje żadna 3 spełniająca kryterium przesyłu danych po drzewie od liścia do korzenia.';
		END
		
	END TRY
	BEGIN CATCH
	
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
	
		SET @Success = 0;
		--print 'rollback'
		SELECT @ERRMSG;
		
		--IF @@TRANCOUNT > 0
		--BEGIN
		--	ROLLBACK TRAN TRAN_A1
		--END
	END CATCH
	
	--dodanie wpisu do tabel statystycznych algorytmow
	INSERT INTO Algorytmy_Uruchomienia (AlgorytmId, LastRunTime, LastRunId, ExecutedBy, Succeeded, ErrorMessage)
	VALUES(@AlgorytmA1Id, @DataModyfikacji, @LastRunId, @UserId, @Success, @ERRMSG);
	
	--IF @Success = 1
	--	COMMIT TRAN TRAN_A1
	
	IF OBJECT_ID('tempdb..#ObiektyZCechami') IS NOT NULL
		DROP TABLE #ObiektyZCechami;
		
	IF OBJECT_ID('tempdb..#Transf_1') IS NOT NULL
		DROP TABLE #Transf_1;

	IF OBJECT_ID('tempdb..#Transf_1_Copy') IS NOT NULL
		DROP TABLE #Transf_1_Copy;
		

END
