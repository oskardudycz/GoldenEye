-- =============================================
-- Author:		DK
-- Create date: 2012-06-13
-- Description:	Rozdziela wyliczone zużycie (koszt) z obiektu głownego na obiekty podrzędne od podanego. Dla podanych cech wagi (zagregowanej, jednostkowej i roboczej).
-- =============================================
CREATE PROCEDURE [THB].[CalculationA2]
(
	@SesjaId int,
	@O1ObiektId int = NULL, -- Id obiektu, od ktorego maja byc rozdzielane wartosci cech
	@O1TypObiektuId int = NULL, -- Id typu obiektu, od kotrego maja byc rozdizelane wartosci cech
	@UzytkownikID int,
	@AttributeC2Id int,  --cecha ktorej wartosc zagregowana ma byc rozdzielana
	@AttributeC3Id int,  --cecha okreslajaca wage
	@DivideMethod varchar(5) = 'M1a',
	@ERRMSG nvarchar(MAX) OUTPUT,
	@Success bit OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CechaDoRozdzieleniaId int,
		@CechaWagaId int,
		@LastRunId int,
		@IdObiektKorzen int,
		@SaRelacjeDoPobrania bit = 1,
		@AlgorytmA2Id int = 2, -- Id algorytmu A2 - rozdzielajacego
		
		--identyfikatory po ktorych rozrozniane sa cechy zwykla od agregujacej i wagowej
		@VirtualZwyklaCecha smallint = 0,
		@VirtualAgregujacaCecha smallint = 1,
		@VirtualWagaCecha smallint = 2,
		@ObiektId int,
		@DataModyfikacji datetime = GETDATE();

	BEGIN TRY
	
		SET @Success = 1;
		SET @ERRMSG = NULL;	
	
		IF OBJECT_ID('tempdb..#Transf_A2_ObiektyZCechami') IS NOT NULL
			DROP TABLE #Transf_A2_ObiektyZCechami;
		
		IF OBJECT_ID('tempdb..#Transf_A2_Relacje') IS NOT NULL
			DROP TABLE #Transf_A2_Relacje;
			
		IF OBJECT_ID('tempdb..#Transf_A2_Obiekty') IS NOT NULL
			DROP TABLE #Transf_A2_Obiekty;
		
		IF OBJECT_ID('tempdb..#Transf_A2_Obiekty_Copy') IS NOT NULL
			DROP TABLE #Transf_A2_Obiekty_Copy;
		
		--dane obiektow, dla ktorych wyliczane beda wagi i wartosci podzialu - wyznaczone na podstawie metody podzialu M1x
		IF OBJECT_ID('tempdb..#Transf_A2_Obiekty_DoPrzetworzenia') IS NOT NULL
			DROP TABLE #Transf_A2_Obiekty_DoPrzetworzenia;		
			
		CREATE TABLE #Transf_A2_ObiektyZCechami(Id int);	
		CREATE TABLE #Transf_A2_Obiekty(ObiektId int);
		CREATE TABLE #Transf_A2_Obiekty_Copy(ObiektId int);		
		CREATE TABLE #Transf_A2_Relacje(Id int, [From] int, [To] int, [Parent] int, Leaf int);		
		CREATE TABLE #Transf_A2_Obiekty_DoPrzetworzenia(Id int);
		
		--pobranie ID cechy z tabel tymczasowych
		SET @CechaDoRozdzieleniaId = (SELECT Id FROM Alg_Cechy WHERE SesjaId = @SesjaId AND CechaId = @AttributeC2Id);
		SET @CechaWagaId = (SELECT Id FROM Alg_Cechy WHERE SesjaId = @SesjaId AND CechaId = @AttributeC3Id);
		SET @LastRunId = (SELECT (SELECT ISNULL(MAX(LastRunId), 0) FROM Algorytmy_Uruchomienia WHERE AlgorytmId = @AlgorytmA2Id) + 1);	

----	
		-- sprawdzenie czy kazdy obiekt struktury ma cechy agregujace, jesli nie to ich stworzenie?
		IF Cursor_Status('local','curWer') > 0 
		BEGIN
			 CLOSE curWer
			 DEALLOCATE curWer
		END

		DECLARE curWer CURSOR LOCAL FOR 
		SELECT Id FROM Alg_Obiekty WHERE SesjaId = @SesjaId
		OPEN curWer
		FETCH NEXT FROM curWer INTO @ObiektId
		WHILE @@FETCH_STATUS = 0
		BEGIN

			IF NOT EXISTS (SELECT Id FROM Alg_ObiektyCechy WHERE ObiektId = @ObiektId AND SesjaId = @SesjaId AND CechaId = @CechaDoRozdzieleniaId AND VirtualTypeId = @VirtualAgregujacaCecha)
			 AND EXISTS(SELECT Id FROM Alg_ObiektyCechy WHERE ObiektId = @ObiektId AND SesjaId = @SesjaId AND CechaId = @CechaDoRozdzieleniaId AND VirtualTypeId = @VirtualZwyklaCecha)
			BEGIN						
				PRINT 'Insert cechy agregujacej z A2 dla obiektu: ' + CAST(@ObiektId AS varchar);
				
				INSERT INTO Alg_ObiektyCechy(SesjaId, ObiektId, CechaId, VirtualTypeId, IsValidForAlgorithm, CreatedOn, CalculatedByAlgorithm, AlgorithmRun)
				VALUES(@SesjaId, @ObiektId, @CechaDoRozdzieleniaId, @VirtualAgregujacaCecha, 1, @DataModyfikacji, @AlgorytmA2Id, @LastRunId);
			END
			
			FETCH NEXT FROM curWer INTO @ObiektId
		END
		CLOSE curWer
		DEALLOCATE curWer
	
		--sprawdzenie czy kazdy z obiektow struktury ma ceche wagowa, jesli nie to ich stworzenie?
		IF Cursor_Status('local','curWagi') > 0 
		BEGIN
			 CLOSE curWagi
			 DEALLOCATE curWagi
		END

		DECLARE curWagi CURSOR LOCAL FOR 
		SELECT Id FROM Alg_Obiekty WHERE SesjaId = @SesjaId
		OPEN curWagi
		FETCH NEXT FROM curWagi INTO @ObiektId
		WHILE @@FETCH_STATUS = 0
		BEGIN

			-- jesli obiekt posiada cechy C2 do rozdzielenia (zagregowana i jednostkowa) a nie posiada cechy wagowej
			IF NOT EXISTS (SELECT Id FROM Alg_ObiektyCechy WHERE ObiektId = @ObiektId AND SesjaId = @SesjaId AND CechaId = @CechaWagaId AND VirtualTypeId = @VirtualWagaCecha)
			 AND EXISTS(SELECT Id FROM Alg_ObiektyCechy WHERE ObiektId = @ObiektId AND SesjaId = @SesjaId AND CechaId = @CechaDoRozdzieleniaId AND VirtualTypeId = @VirtualZwyklaCecha)
			 AND EXISTS(SELECT Id FROM Alg_ObiektyCechy WHERE ObiektId = @ObiektId AND SesjaId = @SesjaId AND CechaId = @CechaDoRozdzieleniaId AND VirtualTypeId = @VirtualAgregujacaCecha)
			BEGIN					
				PRINT 'Insert cechy wagi z A2 dla obiektu: ' + CAST(@ObiektId AS varchar);
				
				INSERT INTO Alg_ObiektyCechy(SesjaId, ObiektId, CechaId, VirtualTypeId, IsValidForAlgorithm, CreatedOn, CalculatedByAlgorithm, AlgorithmRun)
				VALUES(@SesjaId, @ObiektId, @CechaWagaId, @VirtualWagaCecha, 1, @DataModyfikacji, @AlgorytmA2Id, @LastRunId);
			END
			
			FETCH NEXT FROM curWagi INTO @ObiektId
		END
		CLOSE curWagi
		DEALLOCATE curWagi		
---		
		
		-- pobranie Id obiektow posiadajacych ceche do rozdzelenia wartosci i ceche wagowa
		INSERT INTO #Transf_A2_ObiektyZCechami(Id)
		SELECT Z.ObiektId  
		 FROM
		 (
			 SELECT ObiektId FROM Alg_ObiektyCechy
			 WHERE  CechaId = @CechaDoRozdzieleniaId AND VirtualTypeId = @VirtualZwyklaCecha AND SesjaId = @SesjaId
				UNION ALL
			 SELECT ObiektId FROM Alg_ObiektyCechy
			 WHERE CechaId = @CechaDoRozdzieleniaId AND VirtualTypeId = @VirtualAgregujacaCecha AND SesjaId = @SesjaId
				UNION ALL
			 SELECT ObiektId FROM Alg_ObiektyCechy
			 WHERE CechaId = @CechaWagaId AND VirtualTypeId = @VirtualWagaCecha AND SesjaId = @SesjaId
		 ) AS Z
		 GROUP BY Z.ObiektId
		 HAVING COUNT(Z.ObiektId) = 3
		 	
----		
		-- pobranie ID obiektu bedacego korzeniem przetwarzanej struktury
		IF @O1TypObiektuId IS NOT NULL AND @O1ObiektId IS NOT NULL
			SELECT @IdObiektKorzen = Id FROM Alg_Obiekty WHERE SesjaId = @SesjaId AND TypObiektuId = @O1TypObiektuId AND ObiektId = @O1ObiektId;
		ELSE
			SELECT @IdObiektKorzen = Id, @O1TypObiektuId = TypObiektuId, @O1ObiektId = ObiektId FROM Alg_Obiekty WHERE SesjaId = @SesjaId AND KorzenStruktury = 1;
		
		--pobranie relacji "w dol" od wskazanego wezla
		 
			-- jesli nie podano obiektu O1 lub podanym obiektem O1 jest korzen struktury to pobranie wszystkich relacji struktury
		IF @O1ObiektId IS NULL OR @O1TypObiektuId IS NULL OR (SELECT KorzenStruktury FROM Alg_Obiekty WHERE SesjaId = @SesjaId AND ObiektId = @O1ObiektId AND TypObiektuId = @O1TypObiektuId) = 1
		BEGIN
			
PRINT 'Relacje Korzenia';
			
			--pobranie relacji dla obiektow (3) majacych cechy jednostkowe i agregujace
			INSERT INTO #Transf_A2_Relacje([Id], [From], [To], [Parent], [Leaf])
			SELECT Id, ObiektId_L, ObiektId_R, NULL, NULL
			FROM Alg_ObiektyRelacje WITH(NOLOCK)
			WHERE ObiektId_L IN (SELECT Id FROM #Transf_A2_ObiektyZCechami)
				AND ObiektId_R IN (SELECT Id FROM #Transf_A2_ObiektyZCechami)
				AND SesjaId = @SesjaId
		END
		ELSE
		BEGIN
		 	
PRINT 'Relacje Wezla';		 	
		
			-- pobranie relacji dla podanego korzenia - obiektu O1
			INSERT INTO #Transf_A2_Relacje([Id], [From], [To], [Parent], [Leaf])
			SELECT Id, ObiektId_L, ObiektId_R, NULL, NULL
			FROM Alg_ObiektyRelacje WITH(NOLOCK)
			WHERE ObiektId_L IN (SELECT Id FROM #Transf_A2_ObiektyZCechami) 
				AND ObiektId_R IN (SELECT Id FROM #Transf_A2_ObiektyZCechami)
				AND SesjaId = @SesjaId AND ObiektId_L = @IdObiektKorzen;

			INSERT INTO #Transf_A2_Obiekty(ObiektId)
			SELECT [To] FROM #Transf_A2_Relacje --#Transf_1
		
			WHILE @SaRelacjeDoPobrania = 1
			BEGIN
				--pobranie relacji od obiektow bedacych ostatnio dziecmi
				INSERT INTO #Transf_A2_Relacje([Id], [From], [To], [Parent], [Leaf])  --#Transf_1
				SELECT Id, ObiektId_L, ObiektId_R, NULL, NULL
				FROM Alg_ObiektyRelacje WITH(NOLOCK)
				WHERE ObiektId_L IN (SELECT Id FROM #Transf_A2_ObiektyZCechami)  
				AND ObiektId_R IN (SELECT Id FROM #Transf_A2_ObiektyZCechami) 
				AND SesjaId = @SesjaId AND ObiektId_L IN (SELECT ObiektId FROM #Transf_A2_Obiekty);  --#Transf_1_Obiekty
				
				INSERT INTO #Transf_A2_Obiekty_Copy(ObiektId)  --#Transf_1_Obiekty_Copy
				SELECT [To] FROM #Transf_A2_Relacje WHERE [From] IN (SELECT ObiektId FROM #Transf_A2_Obiekty);  --#Transf_1_Obiekty
	
				--przekopiowanie danych z jednej tabeli roboczej do drugiej
				DELETE FROM #Transf_A2_Obiekty;			
					
				INSERT INTO #Transf_A2_Obiekty(ObiektId)
				SELECT ObiektId FROM #Transf_A2_Obiekty_Copy;
				
				DELETE FROM #Transf_A2_Obiekty_Copy;
				
				--ustawienie flagi zwiazanej z petla
				IF (SELECT COUNT(1) FROM #Transf_A2_Obiekty) > 0
					SET @SaRelacjeDoPobrania = 1;
				ELSE
					SET @SaRelacjeDoPobrania = 0;
			END
		END		
		
		--usuniecie z tabeli obiektow z cechami tych, dla ktorych nie ma relacji!
		DELETE FROM #Transf_A2_ObiektyZCechami
		WHERE Id NOT IN (SELECT [From] FROM #Transf_A2_Relacje) AND Id NOT IN (SELECT [To] FROM #Transf_A2_Relacje)			

--SELECT * FROM #Transf_A2_Relacje
--SELECT @IdObiektKorzen AS IDKorzenia;
		
		-- wyznaczenie pod struktury na podstawie przyjetej metody podzialu
		IF @DivideMethod = 'M1a'
		BEGIN
			--jesli metoda M1a - przekopiowanie wszystkich obiektow majacych odpowiednie cechy (oprocz korzenia)
			INSERT INTO #Transf_A2_Obiekty_DoPrzetworzenia(Id)
			SELECT ozc.Id FROM #Transf_A2_ObiektyZCechami ozc
			JOIN Alg_Obiekty ao ON (ozc.Id = ao.Id)
			WHERE SesjaId = @SesjaId --AND KorzenStruktury = 0;
		END
		ELSE IF @DivideMethod = 'M1b'
		BEGIN
			--dodanie obiektow podrzednych do wskazanego obiektu O1
			INSERT INTO #Transf_A2_Obiekty_DoPrzetworzenia(Id)
			SELECT [To] FROM #Transf_A2_Relacje
			WHERE [From] = @IdObiektKorzen;
			
			--dodanie obiektow sasiadujacych (RODZICOW czy BRACI)?
			INSERT INTO #Transf_A2_Obiekty_DoPrzetworzenia(Id)
			SELECT [From] FROM #Transf_A2_Relacje
			WHERE [To] = @IdObiektKorzen;
		END
		ELSE IF @DivideMethod = 'M1c'
		BEGIN
			--dodanie obiektow podrzednych do wskazanego obiektu O1
			INSERT INTO #Transf_A2_Obiekty_DoPrzetworzenia(Id)
			SELECT [To] FROM #Transf_A2_Relacje
			WHERE [From] = @IdObiektKorzen;
			
			--dodanie obiektow sasiadujacych (RODZICOW czy BRACI)?
			INSERT INTO #Transf_A2_Obiekty_DoPrzetworzenia(Id)
			SELECT [From] FROM #Transf_A2_Relacje
			WHERE [To] = @IdObiektKorzen;
		END

--select * from #Transf_A2_Obiekty_DoPrzetworzenia;		
--SELECT * FROM #Transf_A2_Relacje;	

	
		IF (SELECT COUNT(1) FROM #Transf_A2_Obiekty_DoPrzetworzenia) = 0
		BEGIN
			SET @ERRMSG = 'Brak obiektów podrzędnych wg podanej metody podziału (' + @DivideMethod + ')';
			SET @Success = 0;
		END
		ELSE
		BEGIN
		
			-- 1. obliczenie wag i przesyl ich od lisci do korzenia
			EXEC [THB].[CalculateWeights]
				@SessionId = @SesjaId,
				@AttributeC2Id = @AttributeC2Id,
				@AttributeC3Id = @AttributeC3Id,
				@LastRunId = @LastRunId,
				@DivideMethod = @DivideMethod,
				@Success = @Success OUTPUT,
				@ERRMSG = @ERRMSG OUTPUT
			
				IF @Success = 0
				BEGIN
					SET @ERRMSG = 'A2. Błąd podczas wyliczania wag. ' + @ERRMSG;
				END
				ELSE
				BEGIN
					
					-- 2. rozeslanie wartosci cechy zliczajacej z wskazanego obiektu na wezly podrzedne
					EXEC [THB].[DivideValues]
						@SessionId = @SesjaId,
						@O1ObiektId = @O1ObiektId,
						@O1TypObiektuId = @O1TypObiektuId,
						@AttributeC2Id = @AttributeC2Id,
						@AttributeC3Id = @AttributeC3Id,
						@LastRunId = @LastRunId,
						@Success = @Success OUTPUT,
						@ERRMSG = @ERRMSG OUTPUT
			
					IF @Success = 0
					BEGIN
						SET @ERRMSG = 'A2. Błąd podczas rozdzielania wartości cechy. ' + @ERRMSG
					END
			
				END		
		END
										
	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		SET @Success = 0;
		
		--IF @@TRANCOUNT > 0
		--BEGIN
		--	ROLLBACK TRAN T1
		--END
	END CATCH
	
	--dodanie wpisu do tabel statystycznych algorytmow
	INSERT INTO Algorytmy_Uruchomienia (AlgorytmId, LastRunTime, LastRunId, ExecutedBy, Succeeded, ErrorMessage)
	VALUES(@AlgorytmA2Id, @DataModyfikacji, @LastRunId, @UzytkownikID, @Success, @ERRMSG);	
	
	--usuwanie tabel tymczasowych, jesli istnieja	
	IF OBJECT_ID('tempdb..#Transf_A2_ObiektyZCechami') IS NOT NULL
		DROP TABLE #Transf_A2_ObiektyZCechami;
	
	IF OBJECT_ID('tempdb..#Transf_A2_Relacje') IS NOT NULL
		DROP TABLE #Transf_A2_Relacje;
		
	IF OBJECT_ID('tempdb..#Transf_A2_Obiekty') IS NOT NULL
		DROP TABLE #Transf_A2_Obiekty;
	
	IF OBJECT_ID('tempdb..#Transf_A2_Obiekty_Copy') IS NOT NULL
		DROP TABLE #Transf_A2_Obiekty_Copy;
	
	--dane obiektow, dla ktorych wyliczane beda wagi i wartosci podzialu - wyznaczone na podstawie metody podzialu M1x
	IF OBJECT_ID('tempdb..#Transf_A2_Obiekty_DoPrzetworzenia') IS NOT NULL
		DROP TABLE #Transf_A2_Obiekty_DoPrzetworzenia;

END
