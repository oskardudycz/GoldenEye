-- =============================================
-- Author:		DK
-- Create date: 2012-06-14
-- Description:	Rozdziela wartość korzenia na wezly podrzedne wg wyliczonych wag.

-- =============================================
CREATE PROCEDURE [THB].[DivideValues]
(
	@SessionId int,
	@O1ObiektId int, -- Id obiektu, od ktorego maja byc rozdzielane wartosci cech
	@O1TypObiektuId int, --Id typu obiektu, od ktorego maja byc rozdzielane wartosci cech
	@AttributeC2Id int,        -- cecha bedaca do rozdzielenia
	@AttributeC3Id int,        -- cecha bedaca waga
	@LastRunId int,            --identyfikator uruchomienia algorytmu	
	@Success bit OUTPUT,
	@ERRMSG nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET @Success = 0;

	DECLARE @Query nvarchar(max) = '',
		@ObiektId int,
		@DataModyfikacji datetime = GETDATE(),
		@From int,
		@To int,
		@Id int,
		@TypDanychCechyDoRozdzielenie varchar(30),
		@TypDanychCechyDoRozdzielenieCast varchar(10),
		@IdObiektKorzen int,
		@WartoscDoPodzialuXML xml,
		@WartoscDoPodzialu float,
		@WartoscDoWeryfikacji varchar(20),	
		@WagaObiektuXML xml,
		@WagaObiektu float,
		@WartoscDoPodzialuTypDanych varchar(20),
		@CechaWagaId int,
		@CechaDoRozdzieleniaId int,
		@AlgorytmId int = 2,
		@VirtualZwyklaCecha int = 0,
		@VirtualAgregujacaCecha int = 1,
		@VirtualWagaCecha int = 2,
		@RozdzielonoWartosc bit = 0;
	
	--usuwanie tabel tymczasowych, jesli istnieja	
	IF OBJECT_ID('tempdb..#Transf_A2_2') IS NOT NULL
		DROP TABLE #Transf_A2_2;
	
	BEGIN TRY
	
		SET @Success = 1;

		SET @CechaWagaId = (SELECT Id FROM Alg_Cechy WHERE SesjaId = @SessionId AND CechaId = @AttributeC3Id);
		SET @CechaDoRozdzieleniaId = (SELECT Id FROM Alg_Cechy WHERE SesjaId = @SessionId AND CechaId = @AttributeC2Id);
		SET @IdObiektKorzen = (SELECT Id FROM Alg_Obiekty WHERE SesjaId = @SessionId AND TypObiektuId = @O1TypObiektuId AND ObiektId = @O1ObiektId);

		SELECT @WartoscDoPodzialuXML = (SELECT TOP 1 ColumnsSet FROM Alg_ObiektyCechy aoc 
			WHERE aoc.SesjaId = @SessionId AND aoc.CechaId = @CechaDoRozdzieleniaId AND VirtualTypeId = @VirtualZwyklaCecha AND ColumnsSet IS NOT NULL);	
		
		SELECT @TypDanychCechyDoRozdzielenie = C.value('local-name(.)', 'varchar(300)')
		FROM @WartoscDoPodzialuXML.nodes('/*') AS t(c)
		
		SET @TypDanychCechyDoRozdzielenieCast = (SELECT SUBSTRING(@TypDanychCechyDoRozdzielenie, 4, LEN(@TypDanychCechyDoRozdzielenie) - 3));	

--SELECT @TypDanychCechyDoRozdzielenie AS TypDanych

		-- jesli brak obiektow dla sesji to koncz
		IF NOT EXISTS (SELECT Id FROM Alg_Obiekty WHERE SesjaId = @SessionId)
		BEGIN
			
			SELECT 'brak obiektow';
			
			SET @ERRMSG = 'Brak obiektów dla tego wywołania.';
			SET @Success = 0;
			RETURN;
		END
		
		--jesli nie podano danych korzenia struktury, koncz
		IF @O1TypObiektuId IS NULL OR @O1ObiektId IS NULL
		BEGIN
			SET @ERRMSG = 'Nie określono obiektu O1 (korzenia) struktury.';
			SET @Success = 0;
			RETURN;
		END
	
		-- pobranie wartosci do podzialu z korzenia
		SET @WartoscDoPodzialuXML = (SELECT ColumnsSet FROM Alg_ObiektyCechy aoc 
			WHERE aoc.SesjaId = @SessionId AND aoc.ObiektId = @IdObiektKorzen AND aoc.CechaId = @CechaDoRozdzieleniaId AND VirtualTypeId = @VirtualAgregujacaCecha);
	
		-- jesli brak obiektow dla sesji to koncz
		IF @WartoscDoPodzialuXML IS NULL
		BEGIN
			SET @ERRMSG = 'Brak wartości agregującej cechy C2 do podziału.';
			SET @Success = 0;
			RETURN;
		END
		
		SELECT @WartoscDoPodzialu = C.value('text()[1]', 'float')
		FROM @WartoscDoPodzialuXML.nodes('/*') AS t(c)

--SELECT @WartoscDoPodzialu AS WartoscDoPodzialu;

		--wyzerowanie aktualnych wartosci jednostkowych cech dla obiektow struktury
		SET @Query = '
			UPDATE Alg_ObiektyCechy SET
			CreatedOn = GETDATE(),
			ValInt = NULL,
			ValBit = NULL,
			ValFloat = NULL,
			ValDecimal = NULL,
			ValDate = NULL,
			ValDateTime = NULL,
			CalculatedByAlgorithm = ' + CAST(@AlgorytmId AS varchar) + ',
			AlgorithmRun = ' + CAST(@LastRunId AS varchar) + '
			WHERE SesjaId = ' + CAST(@SessionId AS varchar) + ' AND CechaId = ' + CAST(@CechaDoRozdzieleniaId AS varchar) + ' AND VirtualTypeId = ' + CAST(@VirtualZwyklaCecha AS varchar);
		
		--PRINT @Query;
		EXEC(@Query);

--SELECT * FROM Alg_ObiektyCechy aoc JOIN Alg_Cechy ac ON (aoc.CechaId = ac.Id) WHERE aoc.SesjaId = 304 AND ac.CechaId = 306 AND aoc.VirtualTypeId = 0;
--SELECT 2;

	--rozdzielanie wartosci zagregowanej roota na wszystkie podobiekty

		--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
		IF Cursor_Status('local','A2_cur9') > 0 
		BEGIN
			 CLOSE A2_cur9
			 DEALLOCATE A2_cur9
		END	
				
		DECLARE A2_cur9 CURSOR LOCAL FOR
		SELECT DISTINCT Id FROM #Transf_A2_Obiekty_DoPrzetworzenia
		OPEN A2_cur9
		FETCH NEXT FROM A2_cur9 INTO @ObiektId
		WHILE @@FETCH_STATUS = 0
		BEGIN
		
			SET @WagaObiektuXML = (SELECT ColumnsSet FROM Alg_ObiektyCechy 
									WHERE SesjaId = @SessionId AND ObiektId = @ObiektId AND CechaId = @CechaWagaId AND VirtualTypeId = @VirtualWagaCecha);
		
			-- wartosc rozdzilamy tylko na obiekty majace przypisana jakas wage
			IF @WagaObiektuXML IS NOT NULL
			BEGIN
			
				SELECT @WagaObiektu = C.value('text()[1]', 'float')
				FROM @WagaObiektuXML.nodes('/*') AS t(c);
				
	--	SELECT @WagaObiektu AS WagaObiektu;  CONVERT(' + @TypDanychCechyDoRozdzielenieCast + ', (' +
	
				SET @Query = '
					UPDATE Alg_ObiektyCechy SET
					CreatedOn = GETDATE(),
					'
					
				--jesli wartosc cechy jest calkowita to wykonanie zaokraglenia i rzutowania
				IF @TypDanychCechyDoRozdzielenie = 'ValInt'
				BEGIN
					SET @Query += @TypDanychCechyDoRozdzielenie + ' = CONVERT(int, ROUND( (' + CONVERT(varchar, @WartoscDoPodzialu, 1) + ' * ' + CONVERT(varchar, @WagaObiektu, 1) + '), 0) ),'
				END
				ELSE
				BEGIN	
					SET @Query += @TypDanychCechyDoRozdzielenie + ' = CONVERT(' + @TypDanychCechyDoRozdzielenieCast + ', (' + CONVERT(varchar, @WartoscDoPodzialu, 1) + ' * ' + CONVERT(varchar, @WagaObiektu, 1) + ')),'
				END
				
				SET @Query += '	
					CalculatedByAlgorithm = ' + CAST(@AlgorytmId AS varchar) + ',
					AlgorithmRun = ' + CAST(@LastRunId AS varchar) + '
					WHERE ObiektId = ' + CAST(@ObiektId AS varchar) + ' AND SesjaId = ' + CAST(@SessionId AS varchar) + ' AND CechaId = ' + CAST(@CechaDoRozdzieleniaId AS varchar) + 
					' AND VirtualTypeId = ' + CAST(@VirtualZwyklaCecha AS varchar) + ';';
						
				--PRINT @Query;
				EXEC(@Query);
				
				SET @RozdzielonoWartosc = 1;				
				
			END	

			FETCH NEXT FROM A2_cur9 INTO @ObiektId;
		END
		CLOSE A2_cur9;
		DEALLOCATE A2_cur9;
		
		--jesli rozdzielono wartosc to wpisanie wartosci 0 dla obiektow ktore mialy wage NULLowa
		IF @RozdzielonoWartosc = 1
		BEGIN
			SET @Query = '
				UPDATE Alg_ObiektyCechy SET
				CreatedOn = GETDATE(),
				' + @TypDanychCechyDoRozdzielenie + ' = 0,
				CalculatedByAlgorithm = ' + CAST(@AlgorytmId AS varchar) + ',
				AlgorithmRun = ' + CAST(@LastRunId AS varchar) + '
				WHERE SesjaId = ' + CAST(@SessionId AS varchar) + ' AND CechaId = ' + CAST(@CechaDoRozdzieleniaId AS varchar) + ' AND VirtualTypeId = ' + CAST(@VirtualZwyklaCecha AS varchar) 
				+ ' AND ColumnsSet IS NULL AND ValString IS NULL AND CalculatedByAlgorithm = ' + CAST(@AlgorytmId AS varchar) + ';';
				
				--PRINT @Query;
				--EXEC(@Query);			
		END
		
		
	-- sprawdzenie czy suma wartosci cech z podzialu = wartosci do rozdzielenia
--	SET @Query = 'SELECT @WartoscDoWeryfikacjiTmp = SUM(' + @TypDanychCechyDoRozdzielenie + ') FROM Alg_ObiektyCechy
--		WHERE CechaId = ' + CAST(@CechaDoRozdzieleniaId AS varchar) + ' AND SesjaId = ' + CAST(@SessionId AS varchar) + ' AND VirtualTypeId = ' + CAST(@VirtualZwyklaCecha AS varchar) + ' AND CalculatedByAlgorithm = ' + CAST(@AlgorytmId AS varchar)
	
--	EXECUTE sp_executesql @Query, N'@WartoscDoWeryfikacjiTmp varchar(20) OUTPUT', @WartoscDoWeryfikacjiTmp = @WartoscDoWeryfikacji OUTPUT
			
--SELECT @WartoscDoPodzialu as dopodz, @WartoscDoWeryfikacji as dower
	
--	IF CONVERT(float, @WartoscDoWeryfikacji) < CONVERT(float, @WartoscDoPodzialu)
--	BEGIN	
--		SET @ERRMSG = 'Suma wartości wyznaczonych cech na podstawie wag jest mniejsza niż początkowa wartość do podziału.'
--		SET @Success = 0;
--	END

	IF @RozdzielonoWartosc = 0
	BEGIN
		SET @Success = 0;
		SET @ERRMSG = 'Nie rozdzielono wartości. Żaden z obiektów struktury nie posiada wartości dla wagi.';
	END

	END TRY
	BEGIN CATCH
		SET @ERRMSG = ERROR_MESSAGE();
		SET @Success = 0;
	END CATCH

END
