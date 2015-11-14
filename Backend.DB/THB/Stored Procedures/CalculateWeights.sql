-- =============================================
-- Author:		DK
-- Create date: 2012-07-02
-- Description:	Próbuje wyliczyc wagi wg podanej metody M1 (a, b, c).
-- Ustalic wartosc wagi dla wezla na podstawie wartosci Jednostkowej i sumy jednostkowych.
-- =============================================
CREATE PROCEDURE [THB].[CalculateWeights]
(
	@SessionId int,
	@AttributeC2Id int,        -- cecha bedaca do rozdzielenia
	@AttributeC3Id int,        -- cecha bedaca waga
	@DivideMethod varchar(5),  --metoda podzialu
	@LastRunId int,            --identyfikator uruchomienia algorytmu
	@Success bit OUTPUT,
	@ERRMSG nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET @Success = 1;

	DECLARE @Query nvarchar(max) = '',
		@ObiektId int,
		@Id int,
		@XmlValue xml,
		@TypDanych varchar(30),
		@WartoscDanych float, --varchar(50),	
		@CechaWagaId int,
		@SumaWartosciCechy float, --varchar(20),
		@AlgorytmId int = 2,
		@VirtualZwyklaCecha int = 0,
		@VirtualAgregujacaCecha int = 1,
		@VirtualWagaCecha int = 2
	
	--usuwanie tabel tymczasowych, jesli istnieja	
	--IF OBJECT_ID('tempdb..#Transf_A2_Wagi') IS NOT NULL
	--	DROP TABLE #Transf_A2_Wagi;
		
	--IF OBJECT_ID('tempdb..#Transf_A2_Relacje') IS NOT NULL
	--	DROP TABLE #Transf_A2_Relacje_Copy;

	--IF OBJECT_ID('tempdb..#Transf_A2_Wagi_Copy') IS NOT NULL
	--	DROP TABLE #Transf_A2_Wagi_Copy;
	
	--IF OBJECT_ID('tempdb..#Transf_A2_#ObiektyZCechami') IS NOT NULL
	--	DROP TABLE #Transf_A2_#ObiektyZCechami;
	
	--CREATE TABLE #Transf_A2_#ObiektyZCechami(Id int);
--	CREATE TABLE #Transf_1(Id int, [From] int, [To] int, [Parent] int, Leaf int);
--	CREATE TABLE #Transf_A2_Wagi_Copy(Id int, [From] int, [To] int, [Parent] int, Leaf int);
--	CREATE TABLE #Transf_A2_Relacje_Copy(Id int, [From] int, [To] int, [Parent] int, Leaf int);
	-- #Transf_A2_ObiektyZCechami
	-- #Transf_A2_Relacje
	
	BEGIN TRY
		
		SET @CechaWagaId = (SELECT Id FROM Alg_Cechy WHERE SesjaId = @SessionId AND CechaId = @AttributeC3Id);
		
		--pobranie typu cechy wagowej
		SET @XmlValue = (SELECT TOP 1 ColumnsSet FROM Alg_ObiektyCechy WHERE SesjaId = @SessionId AND CechaId = @CechaWagaId AND VirtualTypeId = @VirtualZwyklaCecha); --@VirtualWagaCecha);	
		
		-- pobranie typu danych i wartosci dla korzenia struktury, na podstawie ktorych bedzie wyliczana waga
		SELECT	@TypDanych = C.value('local-name(.)', 'varchar(30)')
		FROM @XmlValue.nodes('/*') AS t(c);
		
		-- pobranie sumy wartosci wskazanej cechy wg podanej metody
		IF @DivideMethod = 'M1a' OR @DivideMethod = 'M1b'
		BEGIN
			SET @Query = 'SELECT @SumaWartosciCechyTmp = CAST(SUM(' + @TypDanych + ') AS float) FROM Alg_ObiektyCechy WHERE SesjaId = ' + CAST(@SessionId AS varchar) + ' AND CechaId = ' + CAST(@CechaWagaId AS varchar) + '
				AND VirtualTypeId = ' + CAST(@VirtualZwyklaCecha AS varchar) + ' AND ObiektId IN (SELECT DISTINCT Id FROM #Transf_A2_Obiekty_DoPrzetworzenia)'; --#Transf_A2_ObiektyZCechami)';
		END
		ELSE IF @DivideMethod = 'M1c'
		BEGIN
			
			SET @Query = 'SELECT @SumaWartosciCechyTmp = CAST(SUM(wart) AS float) FROM
				(
				SELECT SUM(' + @TypDanych + ') AS wart FROM Alg_ObiektyCechy 
				WHERE SesjaId = ' + CAST(@SessionId AS varchar) + ' AND CechaId = ' + CAST(@CechaWagaId AS varchar) + ' AND VirtualTypeId = ' + CAST(@VirtualAgregujacaCecha AS varchar) 
				+ ' AND ObiektId IN (SELECT DISTINCT Id FROM #Transf_A2_Obiekty_DoPrzetworzenia) -- DISTINCT Id FROM Alg_Obiekty WHERE SesjaId = ' + CAST(@SessionId AS varchar) + ' AND KorzenStruktury = 0)
				UNION
				SELECT ' + @TypDanych + ' AS wart FROM Alg_ObiektyCechy
				WHERE SesjaId = ' + CAST(@SessionId AS varchar) + ' AND CechaId = ' + CAST(@CechaWagaId AS varchar) + ' AND VirtualTypeId = ' + CAST(@VirtualZwyklaCecha AS varchar) 
				+ ' AND ObiektId = (SELECT DISTINCT Id FROM Alg_Obiekty WHERE SesjaId = ' + CAST(@SessionId AS varchar) + ' AND KorzenStruktury = 1)
				) X'
			
		END
		
		--PRINT @Query;
		EXECUTE sp_executesql @Query, N'@SumaWartosciCechyTmp varchar(20) OUTPUT', @SumaWartosciCechyTmp = @SumaWartosciCechy OUTPUT

 --SELECT @SumaWartosciCechy AS SumaWartosciCechyDLaRoota;

		--wyzerowanie wartosci wag dla obiektow
		SET @Query = 'UPDATE Alg_ObiektyCechy SET
			ValInt = NULL,
			ValBit = NULL,
			ValFloat = NULL,
			ValDecimal = NULL,
			ValDate = NULL,
			ValDateTime = NULL,
			CalculatedByAlgorithm = ' + CAST(@AlgorytmId AS varchar) + ',
			AlgorithmRun = ' + CAST(@LastRunId AS varchar) + '
			WHERE SesjaId = ' + CAST(@SessionId AS varchar) + ' AND CechaId = ' + CAST(@CechaWagaId AS varchar) + ' AND VirtualTypeId = ' + CAST(@VirtualWagaCecha AS varchar);

		--PRINT @Query;
		EXEC(@Query);

		--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
		IF Cursor_Status('local','cur8') > 0 
		BEGIN
			 CLOSE cur8
			 DEALLOCATE cur8
		END		

--SELECT * FROM #Transf_A2_ObiektyZCechami
		
		DECLARE cur8 CURSOR LOCAL FOR
		SELECT DISTINCT Id FROM #Transf_A2_Obiekty_DoPrzetworzenia --#Transf_A2_ObiektyZCechami
		OPEN cur8
		FETCH NEXT FROM cur8 INTO @Id
		WHILE @@FETCH_STATUS = 0
		BEGIN	
	
			--pobranie wartosci cechy dla obiektu (jednostkowej/agregujacej w zaleznosci od metody podzialu
			IF @DivideMethod = 'M1a' OR @DivideMethod = 'M1b'
				SET @XmlValue = (SELECT ColumnsSet FROM Alg_ObiektyCechy WHERE ObiektId = @Id AND SesjaId = @SessionId AND CechaId = @CechaWagaId AND VirtualTypeId = @VirtualZwyklaCecha);
			ELSE IF @DivideMethod = 'M1c'
				SET @XmlValue = (SELECT ColumnsSet FROM Alg_ObiektyCechy WHERE ObiektId = @Id AND SesjaId = @SessionId AND CechaId = @CechaWagaId AND VirtualTypeId = @VirtualAgregujacaCecha); 
			
			IF @XmlValue IS NOT NULL
			BEGIN			
				SELECT @TypDanych = C.value('local-name(.)', 'varchar(30)')
						,@WartoscDanych = C.value('text()[1]', 'float') --'nvarchar(200)')
				FROM @XmlValue.nodes('/*') AS t(c)
	
--SELECT @WartoscDanych AS WartoscDanych
				
				-- wartosc wagi liczona jako srednia wazona wartosci jednostkowej cechy przez wartosc sumy z wszystkich obiektow
				--IF @DivideMethod = 'M1a'
				--BEGIN
				
				--zabezpieczenie sie przed dzieleniem przez 0
				IF @SumaWartosciCechy = '0'
					SET @SumaWartosciCechy = '1';

				SET @Query = '
					UPDATE Alg_ObiektyCechy SET
						CreatedOn = GETDATE(),
						ValFloat = ' + CONVERT(varchar, @WartoscDanych, 1) + '/' + CONVERT(varchar, @SumaWartosciCechy, 1) + ',
						CalculatedByAlgorithm = ' + CAST(@AlgorytmId AS varchar) + ',
						AlgorithmRun = ' + CAST(@LastRunId AS varchar) + '
						WHERE ObiektId = ' + CAST(@Id AS varchar) + ' AND SesjaId = ' + CAST(@SessionId AS varchar) + ' AND CechaId = ' + CAST(@CechaWagaId AS varchar) + 
						' AND VirtualTypeId = ' + CAST(@VirtualWagaCecha AS varchar);
			
				--PRINT @Query;
				EXEC(@Query);				
			END			
			
			FETCH NEXT FROM cur8 INTO @Id;
		END
		CLOSE cur8;
		DEALLOCATE cur8;		

		
	END TRY
	BEGIN CATCH
		SET @ERRMSG = ERROR_MESSAGE();
		SET @Success = 0;
	END CATCH	

END
