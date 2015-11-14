-- =============================================
-- Author:		DK
-- Create date: 2012-08-09
-- Last modified on: 2012-08-16
-- Description:	Realizuje algorytm przeszukujący graf wszerz.
-- =============================================
CREATE PROCEDURE [THB].[CalculationDFP]
(
	@SessionId int,
	@UserId int,
	
	-- okreslenie lewego i prawego obiektu (obiektow miedzy ktorymi sciezki szukamy).
	@LObiektId int,
	@LTypObiektuId int,
	@RObiektId int,
	@RTypObiektuId int,	
	@Success bit OUTPUT,
	@Path xml OUTPUT, -- wyznaczona sciezka
	@ERRMSG nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET @Success = 1;

	DECLARE @Query nvarchar(max) = '',
		@AlgorytmDFPId int = 3, -- Id algorytmu przeszukujacego wszerz
		@LastRunId int = 0,
		@SaRelacjeDoPobrania bit = 1,		
		@JestWezelKoncowy bit = 0,
		@JestWezelPoczatkowy bit = 0,
		@TypObiektu int,
		@ObiektId int,
		@ObiektPoczatkowyId int,
		@ObiektKoncowyId int,
		@RelacjaId int,
		@IloscRelacji int,
		@RelacjeCounter int = 0
	
	--usuwanie tabel tymczasowych, jesli istnieja	
	IF OBJECT_ID('tempdb..#TabTemp') IS NOT NULL
		DROP TABLE #TabTemp;
		
	IF OBJECT_ID('tempdb..#Sciezka') IS NOT NULL
		DROP TABLE #Sciezka;
		
	IF OBJECT_ID('tempdb..#SciezkaFinal') IS NOT NULL
		DROP TABLE #SciezkaFinal;
	
	CREATE TABLE #TabTemp(RelacjaId int, ObiektId_L int, ObiektId_R int);
	CREATE TABLE #Sciezka(Lp int IDENTITY(1,1), RelacjaId int, ObiektId int);
	CREATE TABLE #SciezkaFinal(Lp int IDENTITY(1,1), RelacjaId int);
	
	BEGIN TRY	
		
		SET @ERRMSG = NULL;
		
		-- ustalenie nowego Id dla LastRun
		SET @LastRunId = (SELECT (SELECT ISNULL(MAX(LastRunId), 0) FROM Algorytmy_Uruchomienia WHERE AlgorytmId = @AlgorytmDFPId) + 1);
		
		--pobranie id obiektow (poczatkowego i koncowego)
		SET @ObiektPoczatkowyId = (SELECT Id FROM Alg_Obiekty WHERE SesjaId = @SessionId AND TypObiektuId = @LTypObiektuId AND ObiektId = @LObiektId);	
		SET @ObiektKoncowyId = (SELECT Id FROM Alg_Obiekty WHERE SesjaId = @SessionId AND TypObiektuId = @RTypObiektuId AND ObiektId = @RObiektId);
		
		--pobranie ilosci relacji
		SET @IloscRelacji = (SELECT COUNT(Id) FROM Alg_ObiektyRelacje WHERE SesjaId = @SessionId);
	
		--sprawdzenie czy obiekty (poczatkowy i koncowy) istnieja w relacjach struktury
		IF (SELECT COUNT(Id) FROM Alg_ObiektyRelacje 
			--WHERE (ObiektId_L = @ObiektPoczatkowyId OR ObiektId_R = @ObiektPoczatkowyId) OR (ObiektId_L = @ObiektKoncowyId OR ObiektId_R = @ObiektKoncowyId)) < 2
			WHERE ObiektId_L = @ObiektPoczatkowyId OR ObiektId_R = @ObiektKoncowyId) < 2
		BEGIN
			SET @Success = 0;
			SET @ERRMSG = 'Nieprawidłowe dane uruchomieniowe (obiekt początkowy lub obiekt końcowy nie istnieje w ramach podanej struktury).';
		END		
		ELSE
		BEGIN
			--zaczynanie poszukiwania sciezki
			
			--wstawienie do tabeli tymczasowej 1 rekordu
			INSERT INTO #TabTemp(RelacjaId, ObiektId_L, ObiektId_R)
			VALUES(0, NULL, @ObiektPoczatkowyId);

	--SELECT * FROM #TabTemp

			SET @RelacjeCounter = 0;
			
			--przeszukiwanie drzewa/grafu tak dlugo az znajdziemy obiekt koncowy poszukiwan
			WHILE @JestWezelKoncowy = 0 AND @RelacjeCounter < @IloscRelacji
			BEGIN
				-- sprawdzenie czy kazdy obiekt struktury ma cechy agregujace, jesli nie to ich stworzenie
				IF Cursor_Status('local','curWszerz') > 0 
				BEGIN
					 CLOSE curWszerz
					 DEALLOCATE curWszerz
				END
			
				DECLARE curWszerz CURSOR LOCAL FOR 
				SELECT DISTINCT ObiektId_R FROM #TabTemp
				OPEN curWszerz
				FETCH NEXT FROM curWszerz INTO @ObiektId
				WHILE @@FETCH_STATUS = 0
				BEGIN
					--dodanie relacji ktore po lewej stronie maja obiekty bedace w relacjach juz przetworoznych po prawej stronie
					INSERT INTO #TabTemp(RelacjaId, ObiektId_L, ObiektId_R)
					SELECT r.RelacjaId, r.ObiektID_L, r.ObiektID_R
					FROM Alg_ObiektyRelacje r
					WHERE SesjaId = @SessionId AND r.ObiektID_L = @ObiektId AND NOT EXISTS (SELECT RelacjaId FROM #TabTemp WHERE RelacjaId = r.RelacjaId)
					
					FETCH NEXT FROM curWszerz INTO @ObiektId
				END
				CLOSE curWszerz
				DEALLOCATE curWszerz
	
				SET @RelacjeCounter += 1;
				
				IF EXISTS (SELECT RelacjaId FROM #TabTemp WHERE ObiektId_R = @ObiektKoncowyId) --TypObiektuId_R = @RTypObiektuId AND ObiektId_R = @RObiektId)
					SET @JestWezelKoncowy = 1;	
					
				PRINT @JestWezelKoncowy
			
			END
		
	--		SET @RelacjaId = (SELECT TOP 1 RelacjaId FROM #TabTemp WHERE ObiektId_R = @ObiektKoncowyId);
			
			--wstawienie elementu koncowego do sciezki jako 1
			INSERT INTO #Sciezka(RelacjaId, ObiektId)
			VALUES (NULL, @ObiektKoncowyId);
		
			--wyszukiwanie kolejnych elementow sciezki
			WHILE @JestWezelPoczatkowy = 0
			BEGIN
			
				--pobranie obiektu ostatnio dodanego do sciezki
				SET @ObiektId = (SELECT TOP 1 ObiektId FROM #Sciezka ORDER BY Lp DESC);
			
				INSERT INTO #Sciezka(RelacjaId, ObiektId)
				SELECT RelacjaId, ObiektId_L
				FROM #TabTemp
				WHERE ObiektId_R = @ObiektId;		
			
				--sprawdzenie czy w sciezce jest juz element poczatkowy
				IF EXISTS (SELECT Lp FROM #Sciezka WHERE ObiektId = @ObiektPoczatkowyId)
					SET @JestWezelPoczatkowy = 1;
			END
			
			INSERT INTO #SciezkaFinal (RelacjaId)
			SELECT RelacjaId FROM #Sciezka
			WHERE RelacjaId IS NOT NULL
			ORDER BY Lp DESC
		
			SET @Path = (
				SELECT Lp AS "@Lp",
					   RelacjaId AS "@RelationId"
				FROM #SciezkaFinal
				ORDER BY Lp
				FOR XML PATH('PathStep')
			);
		END
	
	END TRY
	BEGIN CATCH
	
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
	
		SET @Success = 0;
	END CATCH
	
	--dodanie wpisu do tabel statystycznych algorytmow
	INSERT INTO Algorytmy_Uruchomienia (AlgorytmId, LastRunTime, LastRunId, ExecutedBy, Succeeded, ErrorMessage)
	VALUES(@AlgorytmDFPId, GETDATE(), @LastRunId, @UserId, @Success, @ERRMSG);
	
	--usuwanie tabel tymczasowych, jesli istnieja	
	IF OBJECT_ID('tempdb..#TabTemp') IS NOT NULL
		DROP TABLE #TabTemp;
		
	IF OBJECT_ID('tempdb..#Sciezka') IS NOT NULL
		DROP TABLE #Sciezka;
	
	IF OBJECT_ID('tempdb..#SciezkaFinal') IS NOT NULL
		DROP TABLE #SciezkaFinal;

END
