-- =============================================
-- Author:		DK
-- Create date: 2012-07-18
-- Last modified on: 2013-02-12
-- Description:	Sprawdza czy istnieje uzytkownik o podanym loginie.

-- XML wejsciowy w postaci:

	--<?xml version="1.0">
	--<Request RequestType="AttributeTypes_IsUsedByUnitType" UserId="1"  AppDate="2012-02-09T12:45:11">
	--	<Ref Id="1" EntityType="AttributeType" />
	--	<Ref Id="10" EntityType="UnitType" />
	--</Request>

-- XML wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="AttributeTypes_IsUsedByUnitType" AppDate="2012-02-09">
	--	<Result>
	--		<Value>True</Value>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[AttributeTypes_IsUsedByUnitType]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DataProgramu datetime,
		@RequestType nvarchar(100),
		@UzytkownikID int,
		@BranzaID int,
		@xml_data xml,
		@xmlOk bit = 0,
		@ERRMSG nvarchar(255),
		@xmlResponse xml,
		@IsUsed varchar(5) = 'false',
		@MaUprawnienia bit = 0,
		@NazwaTypuObiektu nvarchar(500),
		@TypObiektuId int,
		@CechaId int,
		@Query nvarchar(MAX),
		@AppDate datetime,
		@ActualDate bit,
		@BreakLoop bit = 0,
		@CzyTabela bit = 0
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Standard_GetByIds', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT

		IF @xmlOk = 0
		BEGIN
			-- co zrobic jak nie poprawna walidacja XML
			SET @ERRMSG = @ERRMSG;
		END
		ELSE
		BEGIN	
			--poprawny XML wejsciowy
			SET @xml_data = CAST(@XMLDataIn AS xml);
			
			BEGIN TRY
			
			--wyciaganie daty i typu zadania
			SELECT	@DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
					,@BranzaId = C.value('./@BranchId', 'int')
					,@UzytkownikID = C.value('./@UserId', 'nvarchar(32)')
			FROM @xml_data.nodes('/Request') T(C) 
			
			--pobranie id cechy i id typu obiektu
			SELECT @TypObiektuId = C.value('./@Id', 'int')
			FROM @xml_data.nodes('/Request/Ref') T(C)
			WHERE C.value('./@EntityType', 'varchar(30)') = 'UnitType';	
			
			SELECT @CechaId = C.value('./@Id', 'int')
			FROM @xml_data.nodes('/Request/Ref') T(C)
			WHERE C.value('./@EntityType', 'varchar(30)') = 'AttributeType';	
			
			IF @RequestType = 'AttributeTypes_IsUsedByUnitType'
			BEGIN
				
				-- pobranie daty na podstawie przekazanego AppDate
				SELECT @AppDate = THB.PrepareAppDate(@DataProgramu);
				SELECT @ActualDate = THB.IsActualDate(@AppDate);
				
				--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji save
				EXEC [THB].[CheckUserPermission]
					@Operation = N'GET',
					@UserId = @UzytkownikID,
					@BranchId = @BranzaId,
					@Result = @MaUprawnienia OUTPUT
				
				IF @MaUprawnienia = 1
				BEGIN
					
					IF @TypObiektuId IS NOT NULL
					BEGIN
						--sprawdzenie czy podany typ obiektu i cecha istnieja
						SELECT @NazwaTypuObiektu = Nazwa, @CzyTabela = Tabela
						FROM TypObiektu
						WHERE TypObiekt_ID = @TypObiektuId AND IsValid = 1 AND IsDeleted = 0;
								
						IF EXISTS (SELECT Cecha_ID FROM Cechy WHERE Cecha_ID = @CechaId AND IsValid = 1 AND IsDeleted = 0)
						BEGIN
							IF @NazwaTypuObiektu IS NOT NULL AND LEN(@NazwaTypuObiektu) > 0
							BEGIN
								IF @CzyTabela = 0
								BEGIN
							
									SET @Query = 'IF EXISTS (SELECT Id FROM [_' + @NazwaTypuObiektu + '_Cechy_Hist] WHERE CechaID = ' + CAST(@CechaId AS varchar) --+ ' AND IdArch IS NULL AND IsValid = 1 AND IsDeleted = 0'
									
									--dodanie frazy na daty
									SET @Query += [THB].[PrepareDatesPhrase] (NULL, @AppDate);								
									SET @Query += ')'
								END
								ELSE
								BEGIN
									SET @Query = 'IF (SELECT COUNT(Id) FROM dbo.[_' + @NazwaTypuObiektu + '] WHERE 1=1 '
									
									--dodanie frazy na daty
									SET @Query += [THB].[PrepareDatesPhrase] (NULL, @AppDate);
									SET @Query += ') > 0'
								END
								
							SET @Query += '
								BEGIN
									SET @IsUsedTmp = ''true'';
								END
								ELSE
								BEGIN
									SET @IsUsedTmp = ''false'';
								END'
								
								--PRINT @Query;
								EXECUTE sp_executesql @Query, N'@IsUsedTmp varchar(5) OUTPUT', @IsUsedTmp = @IsUsed OUTPUT
							
							END
							ELSE
								SET @ERRMSG = 'Błąd. Nie istnieje typ obiektu o podanym Id (' + CAST(ISNULL(@TypObiektuId, '') AS varchar) + ').';
						END
						ELSE
							SET @ERRMSG = 'Błąd. Nie istnieje cecha o podanym Id (' + CAST(ISNULL(@CechaId, '') AS varchar) + ').';
					END
					ELSE
						SET @ERRMSG = 'Błąd. Nie podano Id typu obiektu.';			
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'AttributeTypes_IsUsedByUnitType', @Wiadomosc = @ERRMSG OUTPUT				
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'AttributeTypes_IsUsedByUnitType', @Wiadomosc = @ERRMSG OUTPUT	
			
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH
		END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="AttributeTypes_IsUsedByUnitType"';
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
		
	SET @XMLDataOut += '>';
	
	IF @ERRMSG iS NULL OR @ERRMSG = ''		
		SET @XMLDataOut += '<Result><Value>' + @IsUsed + '</Value></Result>'
	ELSE
		SET @XMLDataOut += '<Result><Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/></Result>';
	
	SET @XMLDataOut += '</Response>'; 
	
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut

END
