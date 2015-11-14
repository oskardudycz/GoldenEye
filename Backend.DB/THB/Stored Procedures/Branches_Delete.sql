-- =============================================
-- Author:		DK
-- Create date: 2012-03-07
-- Last modified on: 2013-02-18
-- Description:	Usuwa branze o podanych ID.

-- przykładowy plik XML wejściowy:
	--<?xml version="1.0" encoding="utf-8"?>
	--<Request RequestType="Branches_Delete" UserId="1" AppDate="2012-09-09T11:45:22" IsSoftDelete="false">
	--	<Ref Id="1" EntityType="Branch" />
	--	<Ref Id="2" EntityType="Branch" />
	--	<Ref Id="3" EntityType="Branch" />
	--	<Ref Id="4" EntityType="Branch" />
	--	<Ref Id="5" EntityType="Branch" />
	--</Request>

-- przykładowy plik XML wyjściowy:
	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="Branches_Delete" AppDate="2012-09-09">
	--	<Result>
	--		<Error ErrorMessage="blad"/>
	--	</Result>
	--</Response>
-- =============================================
CREATE PROCEDURE [THB].[Branches_Delete]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DataProgramu datetime,
		@UzytkownikID int,
		@RequestType nvarchar(100) = '',
		@UsuwanieMiekkie bit = 1,
		@xmlOk bit = 0,
		@xml_data xml,
		@BranzaID int,
		@ERRMSG nvarchar(255),
		@Usunieto bit = 0,
		@MaUprawnienia bit = 0,
		@DataUsuniecia datetime = GETDATE(),
		@DataUsunieciaApp datetime,
		@BranzaAdministracyjnaId int = 0,
		@DeleteHardCondition varchar(100),
		@DeleteSoftCondition varchar(100),
		@Query nvarchar(MAX)

	BEGIN TRY

		SET @ERRMSG = '';
		
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
			
			--usuwanie tabel tymczasowych, jesli istnieja
			IF OBJECT_ID('tempdb..#BranzeDoUsuniecia') IS NOT NULL
				DROP TABLE #BranzeDoUsuniecia
			
			--wyciaganie daty i typu zadania
			SELECT @DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(32)')
					,@UzytkownikID = C.value('./@UserId', 'nvarchar(32)')
					,@UsuwanieMiekkie = C.value('./@IsSoftDelete', 'bit')
			FROM @xml_data.nodes('/Request') T(C)
			
			--pobranie id elementow do usuniecia
			SELECT C.value('./@Id', 'int') AS ID
			INTO #BranzeDoUsuniecia
			FROM @xml_data.nodes('/Request/Ref') T(C)
			WHERE C.value('./@EntityType', 'nvarchar(50)') = 'Branch'
			
			--SELECT * FROM #DoUsuniecia
			--SELECt @DataProgramu, @RequestType, @UzytkownikID, @UsuwanieMiekkie
			
			IF @RequestType = 'Branches_Delete'
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
				
					--pobranie warunkow usuniecia danych w trybie miekkim i twardym
					SET @DeleteHardCondition = THB.GetHardDeleteCondition();
					SET @DeleteSoftCondition = THB.GetSoftDeleteCondition();

					BEGIN TRAN T1_Branches_Delete
					
					IF Cursor_Status('local','curBranze') > 0 
					BEGIN
						 CLOSE curBranze
						 DEALLOCATE curBranze
					END
						
					--stworzenie zapytania dla usuniecia cech w kazdym z istniejacych typow obiektu
					DECLARE curBranze CURSOR LOCAL FOR 
						SELECT DISTINCT Id FROM #BranzeDoUsuniecia
					OPEN curBranze
					FETCH NEXT FROM curBranze INTO @BranzaId
					WHILE @@FETCH_STATUS = 0
					BEGIN
					
						--rozny tryb usuwania danych zalezny od flagi
						IF @UsuwanieMiekkie = 0
						BEGIN
							SET @Query = ' 
								IF EXISTS (SELECT Id FROM dbo.Branze WHERE Id = @BranzaId' + @DeleteHardCondition + ')
								BEGIN
									DELETE FROM [Branze_Cechy]
									WHERE BranzaId <> @BranzaAdministracyjnaId AND BranzaId = @BranzaId;
									
									DELETE FROM [RolaOperacja]
									WHERE Branza <> @BranzaAdministracyjnaId AND Branza = @BranzaId;
									
									DELETE FROM [Branze]
									WHERE Id <> @BranzaAdministracyjnaId AND (Id = @BranzaId OR IdArch = @BranzaId);
								END
								ELSE
								BEGIN
									UPDATE [Branze_Cechy] SET
										IsValid = 0,
										IsDeleted = 1,
										DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
										DeletedFrom = @DataUsunieciaApp,
										ValidTo = @DataUsunieciaApp,
										RealDeletedFrom = @DataUsuniecia
									WHERE IsDeleted = 0 AND BranzaId <> @BranzaAdministracyjnaId AND BranzaId = @BranzaId' + @DeleteSoftCondition + ';
										
									DELETE FROM [RolaOperacja]
									WHERE Branza IN (SELECT ID FROM #BranzeDoUsuniecia);
										
									UPDATE [Branze] SET
										IsValid = 0,
										IsDeleted = 1,
										DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
										DeletedFrom = @DataUsunieciaApp,
										ValidTo = @DataUsunieciaApp,
										RealDeletedFrom = @DataUsuniecia
									WHERE IsDeleted = 0 AND Id <> @BranzaAdministracyjnaId AND (Id = @BranzaId OR IdArch = @BranzaId)' + @DeleteSoftCondition + ';
								END
								
								IF @@ROWCOUNT > 0
									SET @Usunieto = 1;'
							
							EXEC sp_executesql @Query, N'@DataUsunieciaApp datetime, @BranzaId int, @BranzaAdministracyjnaId int, @DataUsuniecia datetime, @Usunieto bit OUTPUT', 
								@BranzaAdministracyjnaId = @BranzaAdministracyjnaId, @BranzaId = @BranzaId, @DataUsunieciaApp = @DataUsunieciaApp, @DataUsuniecia = @DataUsuniecia, @Usunieto = @Usunieto OUTPUT
						END
						ELSE
						BEGIN
							UPDATE [Branze_Cechy] SET
							IsValid = 0,
							IsDeleted = 1,
							DeletedBy = @UzytkownikID,
							DeletedFrom = @DataUsunieciaApp,
							ValidTo = @DataUsunieciaApp,
							RealDeletedFrom = @DataUsuniecia
							WHERE IsDeleted = 0 AND BranzaId <> @BranzaAdministracyjnaId AND BranzaId = @BranzaId;
							
							DELETE FROM [RolaOperacja]
							WHERE Branza IN (SELECT ID FROM #BranzeDoUsuniecia);
							
							UPDATE [Branze] SET
							IsValid = 0,
							IsDeleted = 1,
							DeletedBy = @UzytkownikID,
							DeletedFrom = @DataUsunieciaApp,
							ValidTo = @DataUsunieciaApp,
							RealDeletedFrom = @DataUsuniecia
							WHERE IsDeleted = 0 AND Id <> @BranzaAdministracyjnaId AND (Id = @BranzaId OR IdArch = @BranzaId);
							
							IF @@ROWCOUNT > 0
								SET @Usunieto = 1;
						END
						
						FETCH NEXT FROM curBranze INTO @BranzaId
				
					END
					CLOSE curBranze;
					DEALLOCATE curBranze;
						
					COMMIT TRAN T1_Branches_Delete
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Branches_Delete', @Wiadomosc = @ERRMSG OUTPUT	
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Branches_Delete', @Wiadomosc = @ERRMSG OUTPUT

		END			
		END TRY
		BEGIN CATCH
			SET @ERRMSG = @@ERROR;
			SET @ERRMSG += ' ';
			SET @ERRMSG += ERROR_MESSAGE();
			
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRAN T1_Branches_Delete
			END
		END CATCH 
		
		--przygotowanie XMLa zwrotnego
		SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Branches_Delete"'
		
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
		
		--usuwanie tabel tymczasowych, jesli istnieja
		IF OBJECT_ID('tempdb..#BranzeDoUsuniecia') IS NOT NULL
			DROP TABLE #BranzeDoUsuniecia  
			
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
		
END
