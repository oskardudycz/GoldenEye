-- =============================================
-- Author:		DK
-- Create date: 2012-08-20
-- Last modified on: 2013-02-19
-- Description:	Usuwa wpis z tabeli Relacja_Typ o podanych Id.
-- Usuwane (modyfikowane) sa takze wiersze w tabelach powiazanych z usuwanym typem bazowym relacji.

-- Przyjmuje XML wejsciowy w postaci:

	--<Request RequestType="RelationBaseTypes_Delete" UserId="1" AppDate="2012-09-09T11:34:34" IsSoftDelete="false">
	--	<Ref Id="1" EntityType="RelationBaseType" />
	--	<Ref Id="2" EntityType="RelationBaseType" />
	--	<Ref Id="3" EntityType="RelationBaseType" />
	--</Request>
	
-- Zwraca XML w postaci:

	--<Response ResponseType="RelationBaseTypes_Delete" AppDate="2012-02-09">
	--	<Result>
		--	<Value>true</Value>
		--LUB
		--	<Error ErrorMessage="blad"/>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[RelationBaseTypes_Delete]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Query nvarchar(max) = '',
		@DataProgramu datetime,
		@RequestType nvarchar(100),
		@UzytkownikID int,
		@BranzaID int = NULL,
		@UsuwanieMiekkie bit = 1,
		@ERRMSG nvarchar(255) = '',
		@xmlOk bit = 0,
		@xml_data xml,
		@Usunieto bit = 0,
		@MaUprawnienia bit = 0,
		@DataUsuniecia datetime = GETDATE(),
		@DataUsunieciaApp datetime,
		@ActualDate bit,
		@DeleteHardCondition varchar(100),
		@DeleteSoftCondition varchar(100),
		@BazowyTypRelacjiId int,
		@MoznaUsuwacNaTwardo bit = 0

	BEGIN TRY
		
		--usuniecie tabel tymczasowych
		IF OBJECT_ID('tempdb..#BazoweTypyRelacji') IS NOT NULL
			DROP TABLE #BazoweTypyRelacji
				
		IF OBJECT_ID('tempdb..#TypyRelacji') IS NOT NULL
			DROP TABLE #TypyRelacji
			
		IF OBJECT_ID('tempdb..#Relacje') IS NOT NULL
			DROP TABLE #Relacje
			
		CREATE TABLE #TypyRelacji(Id int, BazowyTypId int);
		CREATE TABLE #Relacje(Id int, BazowyTypId int)
		
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
			SELECT @DataProgramu = C.value('./@AppDate', 'nvarchar(20)')
					,@RequestType = C.value('./@RequestType', 'nvarchar(32)')
					,@UzytkownikID = C.value('./@UserId', 'nvarchar(32)')
					,@BranzaId = C.value('./@BranchId', 'int')
					,@UsuwanieMiekkie = C.value('./@IsSoftDelete', 'bit')
			FROM @xml_data.nodes('/Request') T(C)
			
			--pobranie id bazowych typow relacji do usuniecia
			SELECT C.value('./@Id', 'int') AS ID
			INTO #BazoweTypyRelacji
			FROM @xml_data.nodes('/Request/Ref') T(C)
			WHERE C.value('./@EntityType', 'nvarchar(50)') = 'RelationBaseType'			
			
			--SELECT @DataProgramu, @RequestType, @UzytkownikID, @UsuwanieMiekkie
			--SELECT * FROM #TypyRelacji
			
			IF @RequestType = 'RelationBaseTypes_Delete'
			BEGIN
			
				-- pobranie daty usuniecia na podstawie przekazanego AppDate
				SELECT @DataUsunieciaApp = THB.PrepareAppDate(@DataProgramu);
				SELECT @ActualDate = THB.IsActualDate(@DataUsunieciaApp);
				
				--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji delete
				EXEC [THB].[CheckUserPermission]
					@Operation = N'DELETE',
					@UserId = @UzytkownikID,
					@BranchId = @BranzaId,
					@Result = @MaUprawnienia OUTPUT
			
				IF @MaUprawnienia = 1
				BEGIN
				
					--pobranie warunkow usuniecia danych w trybie miekkim i twardym
					SET @DeleteHardCondition = THB.GetHardDeleteCondition();
					SET @DeleteSoftCondition = THB.GetSoftDeleteCondition();
					
					--pobranie typow relacji dla danego bazowego typu relacji
					INSERT INTO #TypyRelacji(Id, BazowyTypId)
					SELECT TypRelacji_ID, BazowyTypRelacji_ID
					FROM TypRelacji
					WHERE BazowyTypRelacji_ID IN (SELECT ID FROM #BazoweTypyRelacji);
					
					--pobranie Id relacji powiazanch z danym typem relacji
					INSERT INTO #Relacje(Id, BazowyTypId)
					SELECT r.Id, tr.BazowyTypId
					FROM Relacje r
					JOIN #TypyRelacji tr ON (r.TypRelacji_ID = tr.Id)
					WHERE IsDeleted = 0					
					
	--SELECT * FROM #BazoweTypyRelacji
	--SELECT * FROM #TypyRelacji
	--SELECT * FROM #Relacje;
					
					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','curBazoweTypy') > 0 
					BEGIN
						 CLOSE curBazoweTypy
						 DEALLOCATE curBazoweTypy
					END
							
					--stworzenie zapytania dla usuniecia cech w kazdym z istniejacych typow obiektu
					DECLARE curBazoweTypy CURSOR LOCAL FOR 
						SELECT DISTINCT Id FROM #BazoweTypyRelacji
					OPEN curBazoweTypy
					FETCH NEXT FROM curBazoweTypy INTO @BazowyTypRelacjiId
					WHILE @@FETCH_STATUS = 0
					BEGIN
								
						SET @Query = '
							IF EXISTS (SELECT Id FROM dbo.Relacja_Typ WHERE Id = ' + CAST(@BazowyTypRelacjiId AS varchar) + @DeleteHardCondition + ')
								SET @MoznaUsuwacNaTwardo = 1;
							ELSE
								SET @MoznaUsuwacNaTwardo = 0;'
								
						EXEC sp_executesql @Query, N'@MoznaUsuwacNaTwardo bit OUTPUT', @MoznaUsuwacNaTwardo = @MoznaUsuwacNaTwardo OUTPUT
					
		
						BEGIN TRAN RelationBaseTypes_DELETE				
				
						--usuwanie pozostalych danych w zaleznosci od trybu usuwania
						IF @UsuwanieMiekkie = 0 AND @MoznaUsuwacNaTwardo = 1
						BEGIN
							DELETE FROM [dbo].[Struktura]
							WHERE RelacjaId IN (SELECT Id FROM #Relacje WHERE BazowyTypId = @BazowyTypRelacjiId);
							
							DELETE FROM [dbo].[TypRelacji_Cechy]
							WHERE TypRelacji_ID IN (SELECT ID FROM #TypyRelacji WHERE BazowyTypId = @BazowyTypRelacjiId);
							
							DELETE FROM [dbo].[Relacja_Cecha_Hist]
							WHERE RelacjaID IN (SELECT ID FROM #Relacje WHERE BazowyTypId = @BazowyTypRelacjiId);
							
							DELETE FROM [dbo].[Relacje]
							WHERE Id IN (SELECT ID FROM #Relacje WHERE BazowyTypId = @BazowyTypRelacjiId);
							
							DELETE FROM [dbo].[TypRelacji] 
							WHERE TypRelacji_ID IN (SELECT ID FROM #TypyRelacji WHERE BazowyTypId = @BazowyTypRelacjiId) OR IdArch IN (SELECT ID FROM #TypyRelacji WHERE BazowyTypId = @BazowyTypRelacjiId);
							
							DELETE FROM [dbo].[Relacja_Typ]
							WHERE (Id = @BazowyTypRelacjiId OR IdArch = @BazowyTypRelacjiId);					
						END
						ELSE
						BEGIN
							UPDATE [dbo].[Struktura] SET
							ObowiazujeDo = @DataUsunieciaApp,
							IsValid = 0,
							ValidTo = @DataUsunieciaApp,
							IsDeleted = 1,
							DeletedFrom = @DataUsunieciaApp,
							DeletedBy = @UzytkownikId,
							LastModifiedOn = @DataUsunieciaApp,
							LastModifiedBy = @UzytkownikId,
							RealDeletedFrom = @DataUsuniecia
							WHERE RelacjaId IN (SELECT Id FROM #Relacje WHERE BazowyTypId = @BazowyTypRelacjiId);
							
							UPDATE [dbo].[TypRelacji_Cechy] SET
							ObowiazujeDo = @DataUsunieciaApp,
							IsValid = 0,
							IsDeleted = 1,
							ValidTo = @DataUsunieciaApp,
							LastModifiedOn = @DataUsunieciaApp,
							LastModifiedBy = @UzytkownikId,
							DeletedFrom = @DataUsunieciaApp,
							DeletedBy = @UzytkownikId,
							RealDeletedFrom = @DataUsuniecia
							WHERE TypRelacji_ID IN (SELECT ID FROM #TypyRelacji WHERE BazowyTypId = @BazowyTypRelacjiId);
						
							UPDATE [dbo].[Relacja_Cecha_Hist] SET
							ObowiazujeDo = @DataUsunieciaApp,
							IsValid = 0,
							ValidTo = @DataUsunieciaApp,
							IsDeleted = 1,
							DeletedFrom = @DataUsunieciaApp,
							DeletedBy = @UzytkownikId,
							LastModifiedOn = @DataUsunieciaApp,
							LastModifiedBy = @UzytkownikId,
							RealDeletedFrom = @DataUsuniecia
							WHERE RelacjaID IN (SELECT ID FROM #Relacje WHERE BazowyTypId = @BazowyTypRelacjiId);
						
							UPDATE [dbo].[Relacje] SET
							ObowiazujeDo = @DataUsunieciaApp,
							IsValid = 0,
							ValidTo = @DataUsunieciaApp,
							IsDeleted = 1,
							DeletedFrom = @DataUsunieciaApp,
							DeletedBy = @UzytkownikId,
							LastModifiedOn = @DataUsunieciaApp,
							LastModifiedBy = @UzytkownikId,
							RealDeletedFrom = @DataUsuniecia
							WHERE TypRelacji_ID IN (SELECT ID FROM #TypyRelacji WHERE BazowyTypId = @BazowyTypRelacjiId);
							
							UPDATE [dbo].[TypRelacji] SET
							IsValid = 0,
							ValidTo = @DataUsunieciaApp,
							ObowiazujeDo = @DataUsunieciaApp,
							IsDeleted = 1,
							DeletedFrom = @DataUsunieciaApp,
							DeletedBy = @UzytkownikId,
							LastModifiedOn = @DataUsunieciaApp,
							LastModifiedBy = @UzytkownikId,
							RealDeletedFrom = @DataUsuniecia
							WHERE IsDeleted = 0 AND (TypRelacji_ID IN (SELECT ID FROM #TypyRelacji WHERE BazowyTypId = @BazowyTypRelacjiId) OR IdArch IN (SELECT ID FROM #TypyRelacji WHERE BazowyTypId = @BazowyTypRelacjiId));
						
							UPDATE [dbo].[Relacja_Typ] SET
							IsValid = 0,
							ValidTo = @DataUsunieciaApp,
							ObowiazujeDo = @DataUsunieciaApp,
							IsDeleted = 1,
							DeletedFrom = @DataUsunieciaApp,
							DeletedBy = @UzytkownikId,
							LastModifiedOn = @DataUsunieciaApp,
							LastModifiedBy = @UzytkownikId,
							RealDeletedFrom = @DataUsuniecia
							WHERE IsDeleted = 0 AND (Id = @BazowyTypRelacjiId OR IdArch = @BazowyTypRelacjiId);	
						END
						
						IF @@ROWCOUNT > 0
						BEGIN
							SET @Usunieto = 1;
						END
						
						FETCH NEXT FROM curBazoweTypy INTO @BazowyTypRelacjiId

					END
					CLOSE curBazoweTypy
					DEALLOCATE curBazoweTypy
					
					COMMIT TRAN RelationBaseTypes_DELETE
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'RelationBaseTypes_Delete', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'RelationBaseTypes_Delete', @Wiadomosc = @ERRMSG OUTPUT	
		END
				
		END TRY
		BEGIN CATCH
			SET @ERRMSG = @@ERROR;
			SET @ERRMSG += ' ';
			SET @ERRMSG += ERROR_MESSAGE();
			
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRAN RelationBaseTypes_DELETE
			END
		END CATCH
		
		--przygotowanie XMLa zwrotnego
		SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="RelationBaseTypes_Delete"'
		
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
		BEGIN			
			SET @XMLDataOut += '<Result><Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/></Result>'; 
		END
		
		SET @XMLDataOut += '</Response>';
		
		--usuniecie tabel tymczasowych
		IF OBJECT_ID('tempdb..#BazoweTypyRelacji') IS NOT NULL
			DROP TABLE #BazoweTypyRelacji
			
		IF OBJECT_ID('tempdb..#TypyRelacji') IS NOT NULL
			DROP TABLE #TypyRelacji
			
		IF OBJECT_ID('tempdb..#Relacje') IS NOT NULL
			DROP TABLE #Relacje
			
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut	
END
