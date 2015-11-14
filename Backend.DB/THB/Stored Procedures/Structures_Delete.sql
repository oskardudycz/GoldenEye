-- =============================================
-- Author:		DK
-- Create date: 2012-03-23
-- Last modified on: 2013-05-10
-- Description:	Usuwa wpis z tabel Struktura i  Struktura_Obiekt dla struktur o podanych Id.
-- Usuwane (modyfikowane) sa takze wiersze w tabelach powiazanych z usuwanym typem cechy.

-- Przyjmuje XML wejsciowy w postaci:

	--<Request RequestType="Structures_Delete" UserId="1" AppDate="2012-02-09T09:23:11" IsSoftDelete="false" 
	--	xsi:noNamespaceSchemaLocation="14.2.Request.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Ref Id="1" EntityType="Structure" />
	--	<Ref Id="2" EntityType="Structure" />
	--	<Ref Id="3" EntityType="Structure" />
	--	<Ref Id="4" EntityType="Structure" />
	--	<Ref Id="5" EntityType="Structure" />
	--	<Ref Id="6" EntityType="Structure" />
	--	<Ref Id="7" EntityType="Structure" />
	--</Request>
	
-- Zwraca XML w postaci:

	--<Response ResponseType="Structures_Delete" AppDate="2012-02-09" xsi:noNamespaceSchemaLocation="8.1.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Result>
		--	<Value>true</Value>
		--LUB
		--	<Error ErrorMessage="blad"/>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Structures_Delete]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Query nvarchar(MAX), 
		@DataProgramu datetime,
		@RequestType nvarchar(100),
		@UzytkownikID int,
		@BranzaID int,
		@UsuwanieMiekkie bit = 1,
		@ERRMSG nvarchar(255) = '',
		@xmlOk bit = 0,
		@xml_data xml,
		@Usunieto bit = 0,
		@MaUprawnienia bit = 0,
		@DataUsuniecia datetime = GETDATE(),
		@DataUsunieciaApp datetime,
		@DeleteHardCondition varchar(100),
		@DeleteSoftCondition varchar(100),
		@MoznaUsuwacNaTwardo bit = 0,
		@StrukturaId int,
		@ZablokowanyDoEdycji bit = 0

	BEGIN TRY
		
		--usuniecie tabel tymczasowych		
		IF OBJECT_ID('tempdb..#Struktury') IS NOT NULL
			DROP TABLE #Struktury
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Standard_Delete', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
	
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
					,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
					,@UzytkownikID = C.value('./@UserId', 'int')
					,@UsuwanieMiekkie = C.value('./@IsSoftDelete', 'bit')
					,@BranzaID = c.value('./@BranchId', 'int')
			FROM @xml_data.nodes('/Request') T(C)
			
			--pobranie id typow cech do usuniecia
			SELECT C.value('./@Id', 'int') AS ID
			INTO #Struktury
			FROM @xml_data.nodes('/Request/Ref') T(C)
			WHERE C.value('./@EntityType', 'nvarchar(50)') = 'Structure'			
			
			--SELECT @DataProgramu, @RequestType, @UzytkownikID, @UsuwanieMiekkie
			
			IF @RequestType = 'Structures_Delete'
			BEGIN
			
				-- pobranie daty usuniecia na podstawie przekazanego AppDate
				SELECT @DataUsunieciaApp = THB.PrepareAppDate(@DataProgramu);
				
				--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji select
				EXEC [THB].[CheckUserPermission]
					@Operation = N'DELETE',
					@UserId = @UzytkownikID,
					@BranchId = @BranzaId,
					@Result = @MaUprawnienia OUTPUT
				
				IF @MaUprawnienia = 1
				BEGIN
				
					--sprawdzenie czy podano do usuniecia slownik zablokowany do edycji					
					IF EXISTS (SELECT Id FROM dbo.Struktura_Obiekt WHERE IsBlocked = 1 AND Id IN (SELECT Id FROM #Struktury))
					BEGIN
						SET @ERRMSG = 'Błąd. Nie można usunąć zamrożonej struktury.';
						SET @ZablokowanyDoEdycji = 1;
					END
					ELSE
						SET @ZablokowanyDoEdycji = 0;
				
					IF @ZablokowanyDoEdycji = 0
					BEGIN
				
						--pobranie warunkow usuniecia danych w trybie miekkim i twardym
						SET @DeleteHardCondition = THB.GetHardDeleteCondition();
						SET @DeleteSoftCondition = THB.GetSoftDeleteCondition();
									
						BEGIN TRAN Str_DEL
						
						--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
						IF Cursor_Status('local','curStruktury') > 0 
						BEGIN
							 CLOSE curStruktury
							 DEALLOCATE curStruktury
						END
							
						--stworzenie zapytania dla usuniecia cech w kazdym z istniejacych typow obiektu
						DECLARE curStruktury CURSOR LOCAL FOR 
							SELECT DISTINCT Id FROM #Struktury
						OPEN curStruktury
						FETCH NEXT FROM curStruktury INTO @StrukturaId
						WHILE @@FETCH_STATUS = 0
						BEGIN
							--sprawdzenie czy mozemy usuwac na twardo
							SET @Query = '
								IF EXISTS (SELECT Id FROM dbo.Struktura_Obiekt WHERE Id = ' + CAST(@StrukturaId AS varchar) + @DeleteHardCondition + ')
									SET @MoznaUsuwacNaTwardo = 1;
								ELSE
									SET @MoznaUsuwacNaTwardo = 0;'
									
							EXEC sp_executesql @Query, N'@MoznaUsuwacNaTwardo bit OUTPUT', @MoznaUsuwacNaTwardo = @MoznaUsuwacNaTwardo OUTPUT	
					
							--usuwanie pozostalych danych w zaleznosci od trybu usuwania
							IF @UsuwanieMiekkie = 0 AND @MoznaUsuwacNaTwardo = 1
							BEGIN
								DELETE FROM dbo.Struktura_Algorytmy
								WHERE StrukturaId = @StrukturaId;
								
								DELETE FROM [dbo].[Struktura]
								WHERE StrukturaObiektId = @StrukturaId;
								
								DELETE FROM [dbo].[Struktura_Obiekt]
								WHERE Id = @StrukturaId OR IdArch = @StrukturaId;				
							END
							ELSE
							BEGIN
								DELETE FROM dbo.Struktura_Algorytmy
								WHERE StrukturaId = @StrukturaId;
								
								UPDATE [dbo].[Struktura] SET
								ObowiazujeDo = @DataUsunieciaApp,
								IsValid = 0,
								IsDeleted = 1,
								DeletedBy = @UzytkownikId,
								DeletedFrom = @DataUsunieciaApp,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
							--	LastModifiedOn = GETDATE(),
							--	LastModifiedBy = @UzytkownikId
								WHERE StrukturaObiektId = @StrukturaId;
								
								UPDATE [dbo].[Struktura_Obiekt] SET
								ObowiazujeDo = @DataUsunieciaApp,
								IsValid = 0,
								IsDeleted = 1,
								DeletedBy = @UzytkownikId,
								DeletedFrom = @DataUsunieciaApp,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
							--	LastModifiedOn = GETDATE(),
							--	LastModifiedBy = @UzytkownikId
								WHERE IsDeleted = 0 AND (Id = @StrukturaId OR IdArch = @StrukturaId);
								
							END
						
							IF @@ROWCOUNT > 0
							BEGIN
								SET @Usunieto = 1;
							END
							
							FETCH NEXT FROM curStruktury INTO @StrukturaId						
						END
						CLOSE curStruktury;
						DEALLOCATE curStruktury;
							
						COMMIT TRAN Str_DEL
					END
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Structures_Delete', @Wiadomosc = @ERRMSG OUTPUT 
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Structures_Delete', @Wiadomosc = @ERRMSG OUTPUT 
		END
				
		END TRY
		BEGIN CATCH
			SET @ERRMSG = @@ERROR;
			SET @ERRMSG += ' ';
			SET @ERRMSG += ERROR_MESSAGE();
			
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRAN Str_DEL
			END
		END CATCH
		
		--przygotowanie XMLa zwrotnego
		SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Structures_Delete"'
		
		IF @DataProgramu IS NOT NULL
			SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
		
		SET @XMLDataOut += '>';
		
		IF @ERRMSG IS NULL OR @ERRMSG = ''
		BEGIN
			IF @Usunieto = 1
				SET @XMLDataOut += '<Result><Value>true</Value></Result>';
			ELSE
				SET @XMLDataOut += '<Result><Value/></Result>';
		END
		ELSE		
			SET @XMLDataOut += '<Result><Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/></Result>'; 
		
		SET @XMLDataOut += '</Response>'; 
		
		--usuniecie tabel tymczasowych		
		IF OBJECT_ID('tempdb..#Struktury') IS NOT NULL
			DROP TABLE #Struktury
			
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
	
END
