-- =============================================
-- Author:		DK
-- Create date: 2012-07-11
-- Description:	Przepisuje wyznaczone wartosci cech z tabel roboczych (dla algorytmow) do "normalnych" tabel w bazie danych.
-- =============================================
CREATE PROCEDURE [THB].[RewriteAttributeValuesFromTempToObjects]
(
	@SesjaId int,
	@UzytkownikID int,
	@ERRMSG nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE 
		@Query nvarchar(MAX),
		@NazwaTypuObiektu nvarchar(500),
		@ObiektId int,
		@TypObiektuId int,
		@CechaId int,
		@TmpObiektId int,
		@TmpCechaId int,
		@TmpColumnsSet xml,
		@TmpColumnsSetString nvarchar(MAX),
		@TmpValString nvarchar(200),
		@TmpVirtualTypeId smallint, 
		@TmpIsValidForAlgorithm bit,
		@TmpCalculatedByAlgorithm smallint,
		@TmpAlgorithmRun int,
		@DataUtworzenia datetime,
		@CechaZwyklaVirtualType smallint = 0,	
		--@CechaWagaVirtualType smallint = 2,
		@CechaAgregujacaVirtualType smallint = 1,
		@DataModyfikacji datetime = GETDATE(),
		@RecordId int

	BEGIN TRY	

		--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
		IF Cursor_Status('local','curPrzepisz') > 0 
		BEGIN
			 CLOSE curPrzepisz
			 DEALLOCATE curPrzepisz
		END
	
		--pobranie wartosci cech ktorych wartosc zostala ustalona przez algorytm i ma jakas wartosc pzypisana
		DECLARE curPrzepisz CURSOR LOCAL FOR 
			SELECT aoc.ObiektId, aoc.CechaId, ValString, ColumnsSet, VirtualTypeId, IsValidForAlgorithm, CalculatedByAlgorithm, AlgorithmRun 
			FROM Alg_ObiektyCechy aoc WITH (NOLOCK)
			JOIN Alg_Obiekty ao ON (ao.Id = aoc.ObiektId)
			WHERE aoc.SesjaId = @SesjaId AND aoc.CalculatedByAlgorithm IS NOT NULL 
			AND (aoc.ValString IS NOT NULL OR aoc.ColumnsSet IS NOT NULL) AND ( (aoc.VirtualTypeId = @CechaAgregujacaVirtualType AND ao.LiscStruktury = 0) OR aoc.VirtualTypeId = @CechaZwyklaVirtualType)
		OPEN curPrzepisz
		FETCH NEXT FROM curPrzepisz INTO @TmpObiektId, @TmpCechaId, @TmpValString, @TmpColumnsSet, @TmpVirtualTypeId, @TmpIsValidForAlgorithm, @TmpCalculatedByAlgorithm, @TmpAlgorithmRun 
		WHILE @@FETCH_STATUS = 0
		BEGIN

			--pobranie danych obiektu zwiazanego z cecha i nazwy jego typu
			SELECT @NazwaTypuObiektu = tob.Nazwa, @TypObiektuId = tob.TypObiekt_ID, @ObiektId = ao.ObiektId
			FROM Alg_Obiekty ao
			JOIN TypObiektu tob ON (ao.TypObiektuId = tob.TypObiekt_ID)
			WHERE ao.SesjaId = @SesjaId AND ao.Id = @TmpObiektId;
			
			--pobranie Id cechy
			SELECT @CechaId = CechaId
			FROM Alg_Cechy
			WHERE Id = @TmpCechaId AND SesjaId = @SesjaId

--SELECT @NazwaTypuObiektu AS NazwaTypu, @TypObiektuId AS TypObiektuId, @ObiektId AS ObiektId, @CechaId AS CechaId;

			IF @TmpValString IS NOT NULL
				SET @TmpValString = '''' + @TmpValString + '''';
			ELSE
				SET @TmpValString = 'NULL';
				
			IF @TmpColumnsSet IS NOT NULL
				SET @TmpColumnsSetString = '''' + CAST(@TmpColumnsSet AS varchar) + '''';
			ELSE
				SET @TmpColumnsSetString = 'NULL';
			
			--przepisanie wartosci cech
			SET @Query = '
				IF OBJECT_ID (N''[_' + @NazwaTypuObiektu + '_Cechy_Hist]'', N''U'') IS NOT NULL
				BEGIN
					
					SELECT @RecordId = Id FROM [_' + @NazwaTypuObiektu + '_Cechy_Hist] WHERE CechaID = ' + CAST(@CechaId AS varchar) + ' AND ObiektId = ' + CAST(@ObiektId AS varchar) + 
					' AND IsValid = 1 AND IsDeleted = 0 AND IdArch IS NULL AND VirtualTypeId = ' + CAST(@TmpVirtualTypeId AS varchar) + ';
					
					IF @RecordId IS NOT NULL AND @RecordId > 0
					BEGIN
						UPDATE [_' + @NazwaTypuObiektu + '_Cechy_Hist] SET	
						ValString = ' + @TmpValString + ',		
						ColumnsSet = ' + @TmpColumnsSetString + ',
						VirtualTypeId = ' + CAST(@TmpVirtualTypeId AS varchar) + ',
						IsValidForAlgorithm = ' + CAST(@TmpIsValidForAlgorithm AS varchar) + ',
						CalculatedByAlgorithm = ' + CAST(@TmpCalculatedByAlgorithm AS varchar) + ',
						AlgorithmRun = ' + CAST(@TmpAlgorithmRun AS varchar) + ',
						LastModifiedBy = ' + CAST(@UzytkownikID AS varchar) + ',
						LastModifiedOn = ''' + CONVERT(varchar, @DataModyfikacji, 109) + ''',
						ValidFrom = ''' + CONVERT(varchar, @DataModyfikacji, 109) + ''',
						Priority = 1
						WHERE Id = @RecordId;
					END
					ELSE
					BEGIN
						INSERT INTO [_' + @NazwaTypuObiektu + '_Cechy_Hist] (ObiektId, CechaID, ColumnsSet, ValString, VirtualTypeId, IsValidForAlgorithm, CalculatedByAlgorithm, AlgorithmRun, CreatedBy, CreatedOn, ValidFrom, Priority)
						VALUES(' + CAST(@ObiektId AS varchar) + ', ' + CAST(@CechaId AS varchar) + ', ' + @TmpColumnsSetString + ', ''' + @TmpValString + ''', ' +
						CAST(@TmpVirtualTypeId AS varchar) + ', ' + CAST(@TmpIsValidForAlgorithm AS varchar) + ', ' + CAST(@TmpCalculatedByAlgorithm AS varchar) + ', ' + CAST(@TmpAlgorithmRun AS varchar) + ', ' + CAST(@UzytkownikID AS varchar) +
						', ''' + CONVERT(varchar, @DataModyfikacji, 109) + ''', ''' + CONVERT(varchar, @DataModyfikacji, 109) + ''', 1)
					END
				END'
				
			--PRINT @Query
			EXECUTE sp_executesql @Query, N'@RecordId int', @RecordId = @RecordId

			FETCH NEXT FROM curPrzepisz INTO @TmpObiektId, @TmpCechaId, @TmpValString, @TmpColumnsSet, @TmpVirtualTypeId, @TmpIsValidForAlgorithm, @TmpCalculatedByAlgorithm, @TmpAlgorithmRun 
		END
		CLOSE curPrzepisz;
		DEALLOCATE curPrzepisz;							
			
	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		SELECT @ERRMSG AS ERROR
		
	END CATCH

END
