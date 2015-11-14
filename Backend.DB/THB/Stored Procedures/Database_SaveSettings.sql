-- =============================================
-- Author:		DK
-- Create date: 2012-10-26
-- Last modified on: 2013-02-18
-- Description:	Zapisuje dane ustawien użytkowników (klucz i wartość).

-- XML wejsciowy w postaci:

--<Request RequestType="Database_SaveSettings" UserId="1" AppDate="2012-02-09T12:45:22">
--		<SettingEntry Key="CompleteContinuityOfAttributes" Value="ExtendRange" DataType="3"/>
--		<SettingEntry Key="AutomaticAlternativeHistoryEnable" Value="1" DataType="3"/>
--</Request>
	
-- XML wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="Database_SaveSettings" AppDate="2012-02-09">
	--	<Result>
	--		<Value>true</Value>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Database_SaveSettings]
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
		@xmlOk bit = 0,
		@xml_data xml,
		@BranzaID int,
		@ERRMSG nvarchar(255),
		@xmlResponse xml,
		@MaUprawnienia bit = 0,
		@Klucz varchar(100),
		@Wartosc nvarchar(100),
		@DataType smallint,
		@Query nvarchar(MAX) = '',
		@DataModyfikacji datetime = GETDATE(),
		@Zapisano varchar(5) = 'false',
		@MinRoleRank int

	BEGIN TRY

		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Database_SaveSettings', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT

		--usuwanie tabel tymczasowych, jesli istnieja
		IF OBJECT_ID('tempdb..#UstawieniaAplikacji') IS NOT NULL
			DROP TABLE #UstawieniaAplikacji
			
		IF @xmlOk = 0 OR @xmlOk IS NULL
		BEGIN
			--co zrobic na skutek zlej walidacji?
			SET @ERRMSG = @ERRMSG;
		END
		ELSE
		BEGIN
		
			SET @xml_data = CAST(@XMLDataIn AS xml);

			--wyciaganie daty, uzytkownika, typu zadania i nazwy slownika
			SELECT @DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
					,@UzytkownikID = C.value('./@UserId', 'int')
					,@BranzaID = C.value('./@BranchId', 'int')
			FROM @xml_data.nodes('/Request') T(C);			
			
			--odczytywanie ustawien uzytkownikow
			SELECT	C.value('./@Key', 'varchar(100)') AS Klucz,
					C.value('./@Value', 'nvarchar(100)') AS Wartosc,
					C.value('./@DataType', 'smallint') AS DataType
			INTO #UstawieniaAplikacji
			FROM @xml_data.nodes('/Request/SettingEntry') T(C);

			IF @RequestType = 'Database_SaveSettings'
			BEGIN 
				
				--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji select
				--EXEC [THB].[CheckUserPermission]
				--	@Operation = N'SAVE',
				--	@UserId = @UzytkownikID,
				--	@BranchId = @BranzaId,
				--	@Result = @MaUprawnienia OUTPUT
				
				--weryfikacja uprawnien an podstawie nalezenia uzytownika do roli Supervisor lub Administrator - tylko tacy moga zmieniac ustawienia aplikacji, bazy danych
				EXEC [THB].[GetUserMinRoleRank]
					@UserId = @UzytkownikID,
					@AppDate = NULL,
					@CheckDate = 0,
					@MinRoleRank = @MinRoleRank OUTPUT
				
				IF @MinRoleRank IS NULL OR @MinRoleRank > 2
					SET @MaUprawnienia = 0;
				ELSE
					SET @MaUprawnienia = 1;
			
				IF @MaUprawnienia = 1
				BEGIN
				
					BEGIN TRAN T1_DATABASE_SETTINGS
					
					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','cur') > 0 
					BEGIN
						 CLOSE cur
						 DEALLOCATE cur
					END
					
					DECLARE cur CURSOR LOCAL FOR 
						SELECT Klucz, Wartosc, DataType FROM #UstawieniaAplikacji
					OPEN cur
					FETCH NEXT FROM cur INTO @Klucz, @Wartosc, @DataType
					WHILE @@FETCH_STATUS = 0
					BEGIN
						
						--zapis ustawien do bazy
						MERGE dbo.[Ustawienia] AS target
						USING (SELECT @Klucz, @Wartosc, @DataType) AS source (Klucz, Wartosc, DataType)
						ON (target.Klucz = source.Klucz)
						WHEN MATCHED THEN 
							UPDATE SET 
							Wartosc = source.Wartosc,
							TypPola = source.DataType,
							LastModifiedOn = @DataModyfikacji,
							LastModifiedBy = @UzytkownikID
						WHEN NOT MATCHED THEN	
							INSERT (Klucz, Wartosc, TypPola, CreatedOn, CreatedBy)
							VALUES (source.Klucz, source.Wartosc, source.DataType, @DataModyfikacji, @UzytkownikID);
	
						IF @@ROWCOUNT > 0
							SET @Zapisano = 'true';
						
						FETCH NEXT FROM cur INTO @Klucz, @Wartosc, @DataType
						
					END
					CLOSE cur
					DEALLOCATE cur  
					
					COMMIT TRAN T1_DATABASE_SETTINGS
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Database_SaveSettings', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Database_SaveSettings', @Wiadomosc = @ERRMSG OUTPUT
		END
			
	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN T1_DATABASE_SETTINGS
		END
	END CATCH

	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Database_SaveSettings"';
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';

	SET @XMLDataOut += '>';
	
	IF @ERRMSG iS NULL OR @ERRMSG = '' 	
	BEGIN
		SET @XMLDataOut += '<Result><Value>' + @Zapisano + '</Value></Result>';
	END
	ELSE
	BEGIN
		SET @XMLDataOut += '<Result><Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"></Error></Result>';
	END	

	SET @XMLDataOut += '</Response>';	
	
	--usuwanie tabel tymczasowych, jesli istnieja
	IF OBJECT_ID('tempdb..#UstawieniaAplikacji') IS NOT NULL
		DROP TABLE #UstawieniaAplikacji
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut

END
