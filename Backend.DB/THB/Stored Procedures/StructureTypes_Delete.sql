-- =============================================
-- Author:		DK
-- Create date: 2012-03-08
-- Last modified on: 2013-04-04
-- Description:	Usuwa wpis z tabeli TypStruktury_Obiekt o podanych Id.

-- XML wejsciowy o postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Request RequestType="StructureTypes_Delete" UserId="1" AppDate="2012-02-09T11:59:56" IsSoftDelete="false" 
	--	xsi:noNamespaceSchemaLocation="5.2.Request.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Ref Id="1" EntityType="StructureType" />
	--	<Ref Id="2" EntityType="StructureType" />
	--	<Ref Id="3" EntityType="StructureType" />
	--</Request>
	
-- XML wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="StructureTypes_Delete" AppDate="2012-02-09">
	--	<Result>
	--		<Value>true</Value>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[StructureTypes_Delete]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @query nvarchar(max) = '',
		@DataProgramu datetime,
		@RequestType nvarchar(100),
		@UzytkownikID int,
		@BranzaID int,
		@UsuwanieMiekkie bit = 0,
		@ERRMSG nvarchar(255),
		@xmlOk bit = 0,
		@xml_data xml,
		@IloscZmienionych int = 0,
		@MaUprawnienia bit = 0,
		@DataUsuniecia datetime = GETDATE(),
		@DataUsunieciaApp datetime,
		@TypStrukturyId int,
		@DeleteHardCondition varchar(100),
		@DeleteSoftCondition varchar(100),
		@MoznaUsuwacNaTwardo bit = 0,
		@ZablokowanyDoEdycji bit = 0

	BEGIN TRY
		
		--usuniecie tabel tymczasowych
		IF OBJECT_ID('tempdb..#TypyStruktur') IS NOT NULL
			DROP TABLE #TypyStruktur
			
		IF OBJECT_ID('tempdb..#StukturaObiekt') IS NOT NULL
			DROP TABLE #StukturaObiekt
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Standard_Delete', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT --'Schema_StructureTypes_Delete'
	
		IF @xmlOk = 0
		BEGIN
			-- co zrobic jak nie poprawna walidacja XML
			SET @ERRMSG = @ERRMSG;
		END
		ELSE
		BEGIN	

			--poprawny XML wejsciowy
			SET @xml_data = CAST(@XMLDataIn AS xml);
		
			--wyciaganie daty i typu zadania
			SELECT @DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(32)')
					,@UzytkownikID = C.value('./@UserId', 'nvarchar(32)')
					,@BranzaId = C.value('./@BranchId', 'int')
					,@UsuwanieMiekkie = C.value('./@IsSoftDelete', 'bit')
			FROM @xml_data.nodes('/Request') T(C)
			
			--pobranie id typow struktur do usuniecia
			SELECT C.value('./@Id', 'int') AS ID
			INTO #TypyStruktur
			FROM @xml_data.nodes('/Request/Ref') T(C)
			WHERE C.value('./@EntityType', 'nvarchar(50)') = 'StructureType'
			
			SELECT Id, TypStruktury_Obiekt_Id AS TypStrukturyId
			INTO #StukturaObiekt
			FROM dbo.[Struktura_Obiekt]
			WHERE TypStruktury_Obiekt_Id IN (SELECT ID FROM #TypyStruktur);
			
		--	SELECT * FROM 	#StukturaObiekt
		--	SELECT @DataProgramu, @RequestType, @UzytkownikID, @UsuwanieMiekkie
		--	SELECT * FROM #TypyStruktur
			
			IF @RequestType = 'StructureTypes_Delete'
			BEGIN
				
				-- pobranie daty usuniecia na podstawie przekazanego AppDate
				SELECT @DataUsunieciaApp = THB.PrepareAppDate(@DataProgramu);
				
				--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji save
				EXEC [THB].[CheckUserPermission]
					@Operation = N'SAVE',
					@UserId = @UzytkownikID,
					@BranchId = @BranzaId,
					@Result = @MaUprawnienia OUTPUT
				
				IF @MaUprawnienia = 1
				BEGIN
				
					--sprawdzenie czy podano do usuniecia slownik zablokowany do edycji					
					IF EXISTS (SELECT Id FROM dbo.TypStruktury_Obiekt WHERE IsBlocked = 1 AND Id IN (SELECT Id FROM #TypyStruktur))
					BEGIN
						SET @ERRMSG = 'Błąd. Nie można usunąć zamrożonego typu struktury.';
						SET @ZablokowanyDoEdycji = 1;
					END
					ELSE
						SET @ZablokowanyDoEdycji = 0;
				
					IF @ZablokowanyDoEdycji = 0
					BEGIN
					
						--pobranie warunkow usuniecia danych w trybie miekkim i twardym
						SET @DeleteHardCondition = THB.GetHardDeleteCondition();
						SET @DeleteSoftCondition = THB.GetSoftDeleteCondition();
						
						BEGIN TRAN Str_DELETE
						
						--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
						IF Cursor_Status('local','curTypyStruktur') > 0 
						BEGIN
							 CLOSE curTypyStruktur
							 DEALLOCATE curTypyStruktur
						END
								
						--stworzenie zapytania dla usuniecia cech w kazdym z istniejacych typow obiektu
						DECLARE curTypyStruktur CURSOR LOCAL FOR 
							SELECT DISTINCT Id FROM #TypyStruktur
						OPEN curTypyStruktur
						FETCH NEXT FROM curTypyStruktur INTO @TypStrukturyId
						WHILE @@FETCH_STATUS = 0
						BEGIN	
					
							--sprawdzenie czy mozemy usuwac na twardo
							SET @Query = '
								IF EXISTS (SELECT Id FROM dbo.TypStruktury_Obiekt WHERE Id = ' + CAST(@TypStrukturyId AS varchar) + @DeleteHardCondition + ')
									SET @MoznaUsuwacNaTwardo = 1;
								ELSE
									SET @MoznaUsuwacNaTwardo = 0;'
									
							EXEC sp_executesql @Query, N'@MoznaUsuwacNaTwardo bit OUTPUT', @MoznaUsuwacNaTwardo = @MoznaUsuwacNaTwardo OUTPUT		
					
							IF @UsuwanieMiekkie = 0 AND @MoznaUsuwacNaTwardo = 1
							BEGIN									
								--trwale ususwanie danych z bazy
								DELETE FROM dbo.[TypStruktury]
								WHERE TypStruktury_Obiekt_Id = @TypStrukturyId;
								
								DELETE FROM dbo.[Struktura]
								WHERE StrukturaObiektId IN (SELECT ID FROM #StukturaObiekt WHERE TypStrukturyId = @TypStrukturyId);
								
								DELETE FROM dbo.[Relacje]
								WHERE TypStruktury_Obiekt_Id = @TypStrukturyId;
								
								DELETE FROM dbo.[Struktura_Obiekt]
								WHERE TypStruktury_Obiekt_Id = @TypStrukturyId;
								
								DELETE FROM dbo.[TypStruktury_Obiekt]
								WHERE Id = @TypStrukturyId OR IdArch = @TypStrukturyId;
							
							END
							ELSE
							BEGIN
								--ustawienie odpoweiednich flag							
								UPDATE dbo.[TypStruktury] SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedBy = @UzytkownikID,
								DeletedFrom = @DataUsunieciaApp,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE TypStruktury_Obiekt_Id = @TypStrukturyId;
								
								UPDATE dbo.[Struktura] SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedBy = @UzytkownikID,
								DeletedFrom = @DataUsunieciaApp,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE StrukturaObiektId IN (SELECT ID FROM #StukturaObiekt WHERE TypStrukturyId = @TypStrukturyId);
								
								UPDATE dbo.[Relacje] SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedBy = @UzytkownikID,
								DeletedFrom = @DataUsunieciaApp,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE TypStruktury_Obiekt_Id = @TypStrukturyId;
							
								UPDATE dbo.[Struktura_Obiekt] SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedBy = @UzytkownikID,
								DeletedFrom = @DataUsunieciaApp,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE TypStruktury_Obiekt_Id = @TypStrukturyId;
								
								UPDATE dbo.[TypStruktury_Obiekt] SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedBy = @UzytkownikID,
								DeletedFrom = @DataUsunieciaApp,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE IsDeleted = 0 AND (Id = @TypStrukturyId OR IdArch = @TypStrukturyId);
								
							END
							
							SET @IloscZmienionych += @@ROWCOUNT;
							
							FETCH NEXT FROM curTypyStruktur INTO @TypStrukturyId
						END
						CLOSE curTypyStruktur;
						DEALLOCATE curTypyStruktur;
							
						COMMIT TRAN Str_DELETE
					END
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'StructureTypes_Delete', @Wiadomosc = @ERRMSG OUTPUT	
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'StructureTypes_Delete', @Wiadomosc = @ERRMSG OUTPUT
		END		
	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG +=  ERROR_MESSAGE();

		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN Str_DELETE
		END
	END CATCH
		
	--przygotowanie XMLa zwrotnego	
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="StructureTypes_Delete"'
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), GETDATE(), 23) + '"';

	SET @XMLDataOut += '>';

	IF @ERRMSG IS NULL OR @ERRMSG = ''
	BEGIN
		IF @IloscZmienionych > 0
			SET @XMLDataOut += '<Result><Value>true</Value></Result>';
		ELSE
			SET @XMLDataOut += '<Result><Value/></Result>';
	END
	ELSE
	BEGIN			
		SET @XMLDataOut += '<Result><Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/></Result>'; 
	END
	
	SET @XMLDataOut += '</Response>';
	
	--usuniecie tabel tymczasowych
	IF OBJECT_ID('tempdb..#TypyStruktur') IS NOT NULL
		DROP TABLE #TypyStruktur
		
	IF OBJECT_ID('tempdb..#StukturaObiekt') IS NOT NULL
		DROP TABLE #StukturaObiekt
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
END
