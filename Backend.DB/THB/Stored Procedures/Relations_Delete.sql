-- =============================================
-- Author:		DK
-- Create date: 2012-03-23
-- Last modified on: 2013-02-19
-- Description:	Usuwa wpis z tabeli Relacje o podanych Id.
-- Usuwane (modyfikowane) sa takze wiersze w tabelach powiazanych z usuwanym typem cechy.

-- Przyjmuje XML wejsciowy w postaci:

	--<Request RequestType="Relations_Delete" UserId="1" AppDate="2012-09-20T11:45:22" IsSoftDelete="true">
	--	<Ref Id="1" EntityType="Relation" />
	--	<Ref Id="2" EntityType="Relation" />
	--	<Ref Id="3" EntityType="Relation" />
	--	<Ref Id="4" EntityType="Relation" />
	--	<Ref Id="5" EntityType="Relation" />
	--	<Ref Id="6" EntityType="Relation" />
	--	<Ref Id="7" EntityType="Relation" />
	--</Request>
	
-- Zwraca XML w postaci:

	--<Response ResponseType="UnitsOfMeasure_Delete" AppDate="2012-02-09" xsi:noNamespaceSchemaLocation="8.1.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Result>
		--	<Value>true</Value>
		--LUB
		--	<Error ErrorMessage="ble vble"/>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Relations_Delete]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Query nvarchar(max) = '',
		@vTypObiektu nvarchar(256),
		@DataProgramu datetime,
		@RequestType nvarchar(100),
		@UzytkownikID int,
		@BranzaID int = NULL,
		@UsuwanieMiekkie bit = 1,
		@ERRMSG nvarchar(255) = '',
		@xmlOk bit = 0,
		@xml_data xml,
		@MaUprawnienia bit = 0,
		@tableName nvarchar(256),
		@Usunieto bit = 0,
		@DataUsuniecia datetime = GETDATE(),
		@DataUsunieciaApp datetime,
		@DeleteHardCondition varchar(100),
		@DeleteSoftCondition varchar(100),
		@RelacjaId int,
		@MoznaUsuwacNaTwardo bit = 0

	BEGIN TRY
		
		--usuniecie tabel tymczasowych		
		IF OBJECT_ID('tempdb..#Relacje') IS NOT NULL
			DROP TABLE #Relacje
			
		CREATE TABLE #Relacje(Id int);
		
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
					,@BranzaID = C.value('./@BranchId', 'int')
					,@UsuwanieMiekkie = C.value('./@IsSoftDelete', 'bit')
			FROM @xml_data.nodes('/Request') T(C)
			
			--pobranie id typow cech do usuniecia
			INSERT INTO #Relacje
			SELECT C.value('./@Id', 'int') AS ID
			FROM @xml_data.nodes('/Request/Ref') T(C)
			WHERE C.value('./@EntityType', 'nvarchar(50)') = 'Relation'			
			
			--SELECT @DataProgramu, @RequestType, @UzytkownikID, @UsuwanieMiekkie
			--SELECT * FROM #Relacje
			
			IF @RequestType = 'Relations_Delete'
			BEGIN					
				
				-- pobranie daty modyfikacji na podstawie przekazanego AppDate
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
				
					BEGIN TRAN T1_Relations_Delete
					
					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','curRelations_DELETE') > 0 
					BEGIN
						 CLOSE curRelations_DELETE
						 DEALLOCATE curRelations_DELETE
					END
					
					--stworzenie zapytania dla usuniecia danych relacji w kazdym z istniejacych typow obiektu
					DECLARE curRelations_DELETE CURSOR LOCAL FOR 
						SELECT DISTINCT Id FROM #Relacje
					OPEN curRelations_DELETE
					FETCH NEXT FROM curRelations_DELETE INTO @RelacjaId
					WHILE @@FETCH_STATUS = 0
					BEGIN
					
						SET @Query = '
							IF EXISTS (SELECT Id FROM dbo.Relacje WHERE Id = ' + CAST(@RelacjaId AS varchar) + @DeleteHardCondition + ')
								SET @MoznaUsuwacNaTwardo = 1;
							ELSE
								SET @MoznaUsuwacNaTwardo = 0;'
								
						EXEC sp_executesql @Query, N'@MoznaUsuwacNaTwardo bit OUTPUT', @MoznaUsuwacNaTwardo = @MoznaUsuwacNaTwardo OUTPUT
					
					
						--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
						IF Cursor_Status('local','curRel_DELETE') > 0 
						BEGIN
							 CLOSE curRel_DELETE
							 DEALLOCATE curRel_DELETE
						END
						
						--stworzenie zapytania dla usuniecia danych relacji w kazdym z istniejacych typow obiektu
						DECLARE curRel_DELETE CURSOR LOCAL FOR 
							SELECT DISTINCT Nazwa FROM TypObiektu --WHERE IdArch IS NULL
						OPEN curRel_DELETE
						FETCH NEXT FROM curRel_DELETE INTO @tableName
						WHILE @@FETCH_STATUS = 0
						BEGIN		
							IF @UsuwanieMiekkie = 0 AND @MoznaUsuwacNaTwardo = 1
							BEGIN									
								--trwale ususwanie danych z bazy
								SET @Query = '
								IF OBJECT_ID (N''[_' + @tableName + '_Relacje_Hist]'', N''U'') IS NOT NULL
								BEGIN
									DELETE FROM [dbo].[_' + @tableName + '_Relacje_Hist] 
									WHERE RelacjaID = ' + CAST(@RelacjaId AS varchar) + ';
								END'
							END
							ELSE
							BEGIN
								--ustawienie odpowiednich flag
								SET @Query = '
								IF OBJECT_ID (N''[_' + @tableName + '_Relacje_Hist]'', N''U'') IS NOT NULL
								BEGIN
									UPDATE [dbo].[_' + @tableName + '_Relacje_Hist] SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
									DeletedFrom = ''' + CAST(@DataUsunieciaApp AS varchar) + ''',
									ValidTo = ''' + CAST(@DataUsunieciaApp AS varchar) + ''',
									RealDeletedFrom = ''' + CAST(@DataUsuniecia AS varchar) + '''
									WHERE RelacjaID = ' + CAST(@RelacjaId AS varchar) + ';
								END'
							END
							
							--usuniecie wystapien cech danego typu w historii cech wszystkich obiektow
							EXEC(@Query);
							
							FETCH NEXT FROM curRel_DELETE INTO @tableName
						END
						CLOSE curRel_DELETE
						DEALLOCATE curRel_DELETE					
			
						--usuwanie pozostalych danych w zaleznosci od trybu usuwania
						IF @UsuwanieMiekkie = 0 AND @MoznaUsuwacNaTwardo = 1
						BEGIN
							DELETE FROM [Struktura]
							WHERE RelacjaId = @RelacjaId;
							
							DELETE FROM [Relacja_Cecha_Hist]
							WHERE RelacjaId = @RelacjaId;
							
							DELETE FROM [TypObiektu_Relacje_Cechy]
							WHERE RelacjaId = @RelacjaId;
							
							DELETE FROM [TypObiektu_Relacje]
							WHERE RelacjaId = @RelacjaId;
							
							DELETE FROM [Relacje]
							WHERE (Id = @RelacjaId OR IdArch = @RelacjaId);
							
						END
						ELSE
						BEGIN
							UPDATE [Struktura] SET
							IsValid = 0,
							IsDeleted = 1,
							DeletedBy = @UzytkownikID,
							DeletedFrom = @DataUsunieciaApp,
							ValidTo = @DataUsunieciaApp,
							RealDeletedFrom = @DataUsuniecia
							WHERE IsDeleted = 0 AND RelacjaId = @RelacjaId;
						
							UPDATE [Relacja_Cecha_Hist] SET
							IsValid = 0,
							IsDeleted = 1,
							DeletedBy = @UzytkownikID,
							DeletedFrom = @DataUsunieciaApp,
							ValidTo = @DataUsunieciaApp,
							RealDeletedFrom = @DataUsuniecia
							WHERE IsDeleted = 0 AND RelacjaId = @RelacjaId;
							
							UPDATE [TypObiektu_Relacje_Cechy] SET
							IsValid = 0,
							IsDeleted = 1,
							DeletedBy = @UzytkownikID,
							DeletedFrom = @DataUsunieciaApp,
							ValidTo = @DataUsunieciaApp,
							RealDeletedFrom = @DataUsuniecia
							WHERE IsDeleted = 0 AND RelacjaId = @RelacjaId;
							
							UPDATE [TypObiektu_Relacje] SET
							IsValid = 0,
							IsDeleted = 1,
							DeletedBy = @UzytkownikID,
							DeletedFrom = @DataUsunieciaApp,
							ValidTo = @DataUsunieciaApp,
							RealDeletedFrom = @DataUsuniecia						
							WHERE IsDeleted = 0 AND RelacjaId = @RelacjaId;
							
							UPDATE [Relacje] SET
							IsValid = 0,
							IsDeleted = 1,
							DeletedBy = @UzytkownikID,
							DeletedFrom = @DataUsunieciaApp,
							ValidTo = @DataUsunieciaApp,
							RealDeletedFrom = @DataUsuniecia
							WHERE IsDeleted = 0 AND (Id = @RelacjaId OR IdArch = @RelacjaId);
						END
					
						IF @@ROWCOUNT > 0
						BEGIN
							SET @Usunieto = 1;
						END
						
						FETCH NEXT FROM curRelations_DELETE INTO @RelacjaId
					END
					CLOSE curRelations_DELETE;
					DEALLOCATE curRelations_DELETE;
						
					COMMIT TRAN T1_Relations_Delete
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Relations_Delete', @Wiadomosc = @ERRMSG OUTPUT 
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Relations_Delete', @Wiadomosc = @ERRMSG OUTPUT 
		END
				
		END TRY
		BEGIN CATCH
			SET @ERRMSG = @@ERROR;
			SET @ERRMSG += ' ';
			SET @ERRMSG += ERROR_MESSAGE();
			
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRAN T1_Relations_Delete
			END
		END CATCH
		
		--przygotowanie XMLa zwrotnego
		SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Relations_Delete"';
		
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
		IF OBJECT_ID('tempdb..#Relacje') IS NOT NULL
			DROP TABLE #Relacje
			
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
	
END
