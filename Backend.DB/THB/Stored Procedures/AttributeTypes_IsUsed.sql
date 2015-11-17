-- =============================================
-- Author:		DK
-- Create date: 2012-06-20
-- Last modified on: 2012-09-14
-- Description:	Sprawdza czy istnieje chociaz 1 instancja podanej cechy (w relacjach lub obiektach).
-- Wynik zwrocony do interfejsu w formie XML'a

-- XML wejsciowy:

	--<Request RequestType="AttributeTypes_IsUsed" UserId="1" AppDate="2012-02-09T11:45:20">
	--	<Ref Id="1" EntityType="AttributeType" />    
	--</Request>

-- XML wyjsciowy:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="AttributeTypes_IsUsed" AppDate="2012-02-09">
	--	<Result>
	--		<Value>true</Value>
	--	</Result>
	--</Response>
	
-- =============================================
CREATE PROCEDURE [THB].[AttributeTypes_IsUsed]
(	
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN

	DECLARE @Query nvarchar(MAX) = '',
		@IdCechy int,
		@DataProgramu datetime,
		@RequestType nvarchar(255),
		@xml_data xml,
		@xmlOut xml,
		@xmlOk bit = 0,
		@CechaIstnieje varchar(5) = 'false',
		@ERRMSG nvarchar(255),
		@UzytkownikID int,
		@BranzaID int = NULL,
		@MaUprawnienia bit = 0,
		@NazwaTypuObiektu nvarchar(500),
		@AppDate datetime,
		@ActualDate bit,
		@BreakLoop bit = 0		
	
	SET @XMLDataOut = '';
	
	--walidacja poprawnosci XMLa
	EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Standard_GetByIds', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT --Schema_Users_IsAuthenticated
	
	IF @xmlOk = 0
	BEGIN
		SET @ERRMSG = @ERRMSG;
	END
	ELSE
	BEGIN
		SET @xml_data = CAST(@XMLDataIn AS xml)
		
		BEGIN TRY
			
		--wyciaganie danych uzytkownika
		SELECT @DataProgramu = C.value('./@AppDate', 'datetime')
			   ,@RequestType = C.value('./@RequestType', 'nvarchar(255)')
				,@UzytkownikID = C.value('./@UserId', 'int')
				,@BranzaID = C.value('./@BranchId', 'int')
				FROM @xml_data.nodes('/Request') T(C)
				
		SELECT @IdCechy = C.value('./@Id', 'int')
		FROM @xml_data.nodes('/Request/Ref') T(C)
		WHERE C.value('./@EntityType', 'varchar(30)') = 'AttributeType'
		
		IF @RequestType = 'AttributeTypes_IsUsed'
		BEGIN
			
			-- pobranie daty na podstawie przekazanego AppDate
			SELECT @AppDate = THB.PrepareAppDate(@DataProgramu);
			SELECT @ActualDate = THB.IsActualDate(@AppDate);
			
			--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji select
			EXEC [THB].[CheckUserPermission]
				@Operation = N'GET',
				@UserId = @UzytkownikID,
				@BranchId = @BranzaId,
				@Result = @MaUprawnienia OUTPUT
			
			IF @MaUprawnienia = 1
			BEGIN
				IF @IdCechy IS NOT NULL
				BEGIN
					
					IF EXISTS (SELECT Cecha_ID FROM Cechy WHERE Cecha_ID = @IdCechy AND IsValid = 1 AND IsDeleted = 0)
					BEGIN
						SET @Query = ' 						
							IF EXISTS (SELECT Id FROM [Relacja_Cecha_Hist] WHERE CechaID = ' + CAST(@IdCechy AS varchar);
								
						IF @AppDate IS NOT NULL
							SET @Query += ' AND (ValidFrom <= ''' + CONVERT(varchar, @AppDate, 112) + ' 23:59:59'' AND (ValidTo IS NULL OR ValidTo >= ''' + CONVERT(varchar, @AppDate, 112) + ' 00:00:00''))';
			
						IF @ActualDate = 1
							SET @Query += ' AND IsDeleted = 0';
							
						SET @Query += ')
							BEGIN
								SET @CechaIstniejeTmp = ''true''
							END'
							
						EXECUTE sp_executesql @Query, N'@CechaIstniejeTmp nvarchar(5) OUTPUT', @CechaIstniejeTmp = @CechaIstnieje OUTPUT			
						
						--jesli poszukiwana cecha nie istnieje juz w relacjach, to szukamy jej dalej w obiektach
						IF @CechaIstnieje = 'false'
						BEGIN
						-- jesli w relacjach nie ma poszukiwanej cechy, to szukamy jej w cechach obiektow
					
							--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
							IF Cursor_Status('local','cur') > 0 
							BEGIN
								 CLOSE cur
								 DEALLOCATE cur
							END
								
							--stworzenie zapytania dla usuniecia cech w kazdym z istniejacych typow obiektu
							DECLARE cur CURSOR LOCAL FOR 
								SELECT DISTINCT Nazwa FROM TypObiektu
							OPEN cur
							FETCH NEXT FROM cur INTO @NazwaTypuObiektu
							WHILE @@FETCH_STATUS = 0 AND @BreakLoop = 0
							BEGIN		
								SET @NazwaTypuObiektu = RTRIM(@NazwaTypuObiektu);

									--ustawienie odpowiednich flag
									SET @Query = ' 
									IF OBJECT_ID (N''[_' + @NazwaTypuObiektu + '_Cechy_Hist]'', N''U'') IS NOT NULL
									BEGIN
								
										IF EXISTS (SELECT Id FROM [_' + @NazwaTypuObiektu + '_Cechy_Hist] WHERE CechaID = ' + CAST(@IdCechy AS varchar);
										
								IF @AppDate IS NOT NULL
									SET @Query += ' AND (ValidFrom <= ''' + CONVERT(varchar, @AppDate, 112) + ' 23:59:59'' AND (ValidTo IS NULL OR ValidTo >= ''' + CONVERT(varchar, @AppDate, 112) + ' 00:00:00''))';
					
								IF @ActualDate = 1
									SET @Query += ' AND IsDeleted = 0';
									
								SET @Query += ')
									BEGIN
										SET @CechaIstniejeTmp = ''true''
									END
								
								END'
		
								--PRINT @Query
								EXECUTE sp_executesql @Query, N'@CechaIstniejeTmp nvarchar(5) OUTPUT', @CechaIstniejeTmp = @CechaIstnieje OUTPUT
								
								--jesli znaleziono ceche to przerwanie dalszego poszukiwania bo i tak wynikiem jest true
								IF @CechaIstnieje = 'true'
									SET @BreakLoop = 1;							
								
								FETCH NEXT FROM cur INTO @NazwaTypuObiektu
							END
							CLOSE cur
							DEALLOCATE cur
						END
					END
					ELSE
						SET @ERRMSG = 'Błąd. Nie istnieje cecha o podanym Id (' + CAST(ISNULL(@IdCechy, '') AS varchar) + ').';
				END
				ELSE
					SET @ERRMSG = 'Nie podano Id Cechy to wyszukania jej instancji.';
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'AttributeTypes_IsUsed', @Wiadomosc = @ERRMSG OUTPUT
		END
		ELSE
			EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'AttributeTypes_IsUsed', @Wiadomosc = @ERRMSG OUTPUT

		END TRY
		BEGIN CATCH
			SET @ERRMSG = @@ERROR;
			SET @ERRMSG += ' ';
			SET @ERRMSG += ERROR_MESSAGE();
		END CATCH
	END
	
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="AttributeTypes_IsUsed"';

	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
		
	SET @XMLDataOut += '>';
	
	IF @ERRMSG IS NULL OR @ERRMSG = ''
	BEGIN
		SET @XMLDataOut += CAST(
		(
			SELECT @CechaIstnieje AS "Value"
			FOR XML PATH('Result')
		) AS nvarchar(MAX)
		)
	END
	ELSE
	BEGIN
		SET @XMLDataOut += CAST(
		(
			SELECT [THB].[PrepareErrorMessage](@ERRMSG) AS "Error/@ErrorMessage"
			FOR XML PATH('Result')
		) AS nvarchar(MAX)
		)
	END
	
	SET @XMLDataOut += '</Response>';
	
END
