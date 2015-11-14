-- =============================================
-- Author:		DK
-- Create date: 2012-03-13
-- Last modified on: 2013-02-18
-- Description:	Usuwa wpis z tabeli Cecha_Typy o podanym Id.
-- Usuwane (modyfikowane) sa takze wiersze w tabelach powiazanych z usuwanym typem cechy.

-- Przyjmuje XML wejsciowy w postaci:

	--<Request RequestType="DataTypes_Delete" UserId="1" AppDate="2012-02-09T11:45:22" IsSoftDelete="false">
	--	<Ref Id="1" EntityType="DataType" />
	--	<Ref Id="2" EntityType="DataType" />
	--	<Ref Id="3" EntityType="DataType" />
	--	<Ref Id="4" EntityType="DataType" />
	--</Request>
	
-- Zwraca XML w postaci:

	--<Response ResponseType="DataTypes_Delete" AppDate="2012-02-09" xsi:noNamespaceSchemaLocation="8.1.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Result>
	--		<Error ErrorMessage="blad"/>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[DataTypes_Delete]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Query nvarchar(max) = '',
		@TypObiektu nvarchar(256),
		@DataProgramu datetime = NULL,
		@RequestType nvarchar(100),
		@UzytkownikID int,
		@BranzaID int = NULL,
		@UsuwanieMiekkie bit = 1,
		@ERRMSG nvarchar(255),
		@xmlOk bit = 0,
		@xml_data xml,
		@Usunieto bit = 0,
		@MaUprawnienia bit = 0,
		@DataUsuniecia datetime = GETDATE(),
		@DataUsunieciaApp datetime,
		@DeleteHardCondition varchar(100),
		@DeleteSoftCondition varchar(100),
		@TypCechyId int,
		@MoznaUsuwacNaTwardo bit = 0
	
	BEGIN TRY
		SET @ERRMSG = '';
		
		--usuniecie tabel tymczasowych
		IF OBJECT_ID('tempdb..#Cechy') IS NOT NULL
			DROP TABLE #Cechy
			
		IF OBJECT_ID('tempdb..#TypyCech') IS NOT NULL
			DROP TABLE #TypyCech
		
		--walidacja poprawnosci XMLa 
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Standard_Delete', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT  --Schema_AttributeDataTypes_Delete
	
		IF @xmlOk = 0
		BEGIN
			-- co zrobic jak nie poprawna walidacja XML
			SET @ERRMSG = @ERRMSG;
		END
		ELSE
		BEGIN	
			--poprawny XML wejsciowy
			SET @xml_data = CAST(@XMLDataIn AS xml);
		
			CREATE TABLE #Cechy (Cecha_ID int, TypId int);
							
			--wyciaganie daty i typu zadania
			SELECT @DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(32)')
					,@UzytkownikID = C.value('./@UserId', 'nvarchar(32)')
					,@BranzaID = C.value('./@BranchId', 'int')
					,@UsuwanieMiekkie = C.value('./@IsSoftDelete', 'bit')
			FROM @xml_data.nodes('/Request') T(C)
			
			--pobranie id typow cech do usuniecia
			SELECT C.value('./@Id', 'int') AS ID
			INTO #TypyCech
			FROM @xml_data.nodes('/Request/Ref') T(C)
			WHERE C.value('./@EntityType', 'varchar(30)') = 'DataType';
			
			--SELECT @DataProgramu, @RequestType, @UzytkownikID, @UsuwanieMiekkie
			
			IF @RequestType = 'DataTypes_Delete'
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
				
					BEGIN TRAN DT_DELETE
					
					--pobranie cech o podanym typie
					INSERT INTO #Cechy (Cecha_ID, TypId)
					SELECT Cecha_ID, TypId FROM [Cechy] c
					WHERE c.TypID IN (SELECT ID FROM #TypyCech)  --AND ct.IdArch IS NULL AND ct.IsValid = 1 AND ct.IsDeleted = 0						
						
			--		SELECT * FROM #CECHY;
			--		SELECT * FROM #TypyCech;					
					
					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','curTypyCech') > 0 
					BEGIN
						 CLOSE curTypyCech
						 DEALLOCATE curTypyCech
					END
							
					--stworzenie zapytania dla usuniecia cech w kazdym z istniejacych typow obiektu
					DECLARE curTypyCech CURSOR LOCAL FOR 
						SELECT DISTINCT Id FROM #TypyCech
					OPEN curTypyCech
					FETCH NEXT FROM curTypyCech INTO @TypCechyId
					WHILE @@FETCH_STATUS = 0
					BEGIN
					
						SET @Query = '
							IF EXISTS (SELECT Id FROM dbo.Cecha_Typy WHERE Id IN (SELECT ID FROM #TypyCech)' + @DeleteHardCondition + ')
								SET @MoznaUsuwacNaTwardo = 1;
							ELSE
								SET @MoznaUsuwacNaTwardo = 0;'
								
						EXEC sp_executesql @Query, N'@MoznaUsuwacNaTwardo bit OUTPUT', @MoznaUsuwacNaTwardo = @MoznaUsuwacNaTwardo OUTPUT
							
						--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
						IF Cursor_Status('local','cur') > 0 
						BEGIN
							 CLOSE cur
							 DEALLOCATE cur
						END
		
						--stworzenie zapytania dla usuniecia cech w kazdym z istniejacych typow obiektu
						DECLARE cur CURSOR LOCAL FOR 
							SELECT Nazwa FROM TypObiektu WHERE IdArch IS NULL
						OPEN cur
						FETCH NEXT FROM cur INTO @TypObiektu
						WHILE @@FETCH_STATUS = 0
						BEGIN		
							IF @UsuwanieMiekkie = 0 AND @MoznaUsuwacNaTwardo = 1
							BEGIN									
								--trwale usuwanie danych z bazy
								SET @Query = ' 
								IF OBJECT_ID (N''[_' + @TypObiektu + '_Cechy_Hist]'', N''U'') IS NOT NULL
								BEGIN
									DELETE FROM [dbo].[_' + @TypObiektu + '_Cechy_Hist] 
									WHERE CechaID IN (SELECT Cecha_ID FROM #Cechy);
								END
								
								IF OBJECT_ID (N''[_' + @TypObiektu + '_Relacje_Hist]'', N''U'') IS NOT NULL
								BEGIN	
									DELETE FROM [dbo].[_' + @TypObiektu + '_Relacje_Hist] 
									WHERE CechaID IN (SELECT Cecha_ID FROM #Cechy WHERE TypId = ' + CAST(@TypCechyId AS varchar) + ');
								END';
							END
							ELSE
							BEGIN
								--ustawienie odpowiednich flag
								SET @Query = ' 
								IF OBJECT_ID (N''[_' + @TypObiektu + '_Cechy_Hist]'', N''U'') IS NOT NULL
								BEGIN
									UPDATE [dbo].[_' + @TypObiektu + '_Cechy_Hist] SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
									DeletedFrom = ''' + CAST(@DataUsunieciaApp AS varchar) + ''',
									ValidTo = ''' + CAST(@DataUsuniecia AS varchar) + ''',
									RealDeletedFrom = ''' + CAST(@DataUsuniecia AS varchar) + '''
									WHERE IsDeleted = 0 AND CechaID IN (SELECT Cecha_ID FROM #Cechy WHERE TypId = ' + CAST(@TypCechyId AS varchar) + ');
								END
							
								IF OBJECT_ID (N''[_' + @TypObiektu + '_Relacje_Hist]'', N''U'') IS NOT NULL
								BEGIN
									UPDATE [dbo].[_' + @TypObiektu + '_Relacje_Hist] SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
									DeletedFrom = ''' + CAST(@DataUsunieciaApp AS varchar) + ''',
									ValidTo = ''' + CAST(@DataUsunieciaApp AS varchar) + ''',
									RealDeletedFrom = ''' + CAST(@DataUsuniecia AS varchar) + '''
									WHERE IsDeleted = 0 AND CechaID IN (SELECT Cecha_ID FROM #Cechy WHERE TypId = ' + CAST(@TypCechyId AS varchar) + ');
								END'
							END
							
							--usuniecie danych z kazdej tabeli typu obiektu
							--PRINT @Query;
							EXEC(@Query);
							
							FETCH NEXT FROM cur INTO @TypObiektu
						END
						CLOSE cur
						DEALLOCATE cur						
			
						--usuwanie pozostalych danych w zaleznosci od trybu usuwania
						IF @UsuwanieMiekkie = 0 AND @MoznaUsuwacNaTwardo = 1
						BEGIN
							DELETE FROM [Slowniki]
							WHERE TypId = @TypCechyId;
							
							DELETE FROM [TypRelacji_Cechy]
							WHERE Cecha_ID IN (SELECT Cecha_ID FROM #Cechy WHERE TypId = @TypCechyId);
							
							DELETE FROM [TypObiektu_Cechy]
							WHERE Cecha_ID IN (SELECT Cecha_ID FROM #Cechy WHERE TypId = @TypCechyId);
							
							DELETE FROM [Relacja_Cecha_Hist]
							WHERE CechaID IN (SELECT Cecha_ID FROM #Cechy WHERE TypId = @TypCechyId);
							
							DELETE FROM [Cechy]
							WHERE Cecha_ID IN (SELECT Cecha_ID FROM #Cechy WHERE TypId = @TypCechyId); 

							DELETE FROM [Cecha_Typy]
							WHERE (Id = @TypCechyId OR IdArch = @TypCechyId);
						END
						ELSE
						BEGIN
						
							UPDATE [Slowniki] SET
							IsValid = 0,
							IsDeleted = 1,
							DeletedBy = @UzytkownikID,
							DeletedFrom = @DataUsunieciaApp,
							ValidTo = @DataUsunieciaApp,
							RealDeletedFrom = @DataUsuniecia
							WHERE TypId = @TypCechyId AND IsValid = 1 AND IsDeleted = 0;
							
							UPDATE [TypRelacji_Cechy] SET
							IsValid = 0,
							IsDeleted = 1,
							DeletedBy = @UzytkownikID,
							DeletedFrom = @DataUsunieciaApp,
							ValidTo = @DataUsunieciaApp,
							RealDeletedFrom = @DataUsuniecia
							WHERE Cecha_ID IN (SELECT Cecha_ID FROM #Cechy WHERE TypId = @TypCechyId) AND IsValid = 1 AND IsDeleted = 0;
							
							UPDATE [TypObiektu_Cechy] SET
							IsValid = 0,
							IsDeleted = 1,
							DeletedBy = @UzytkownikID,
							DeletedFrom = @DataUsunieciaApp,
							ValidTo = @DataUsunieciaApp,
							RealDeletedFrom = @DataUsuniecia
							WHERE Cecha_ID IN (SELECT Cecha_ID FROM #Cechy WHERE TypId = @TypCechyId) AND IsValid = 1 AND IsDeleted = 0;
						
							UPDATE [Relacja_Cecha_Hist] SET
							IsValid = 0,
							IsDeleted = 1,
							DeletedBy = @UzytkownikID,
							DeletedFrom = @DataUsunieciaApp,
							ValidTo = @DataUsunieciaApp,
							RealDeletedFrom = @DataUsuniecia
							WHERE CechaID IN (SELECT Cecha_ID FROM #Cechy WHERE TypId = @TypCechyId) AND IsValid = 1 AND IsDeleted = 0;
					
							UPDATE [Cechy] SET
							IsValid = 0,
							IsDeleted = 1,
							DeletedBy = @UzytkownikID,
							DeletedFrom = @DataUsunieciaApp,
							ValidTo = @DataUsunieciaApp,
							RealDeletedFrom = @DataUsuniecia
							WHERE Cecha_ID IN (SELECT Cecha_ID FROM #Cechy WHERE TypId = @TypCechyId) AND IsValid = 1 AND IsDeleted = 0; 
						
							UPDATE [Cecha_Typy] SET
							IsValid = 0,
							IsDeleted = 1,
							DeletedBy = @UzytkownikID,
							DeletedFrom = @DataUsunieciaApp,
							ValidTo = @DataUsunieciaApp,
							RealDeletedFrom = @DataUsuniecia
							WHERE IsDeleted = 0 AND (IdArch = @TypCechyId OR Id = @TypCechyId);
						END
						
						IF @@ROWCOUNT > 0
							SET @Usunieto = 1;
							
						FETCH NEXT FROM curTypyCech INTO @TypCechyId
					
					END
					CLOSE curTypyCech;
					DEALLOCATE curTypyCech;
						
					COMMIT TRAN DT_DELETE
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'DataTypes_Delete', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'DataTypes_Delete', @Wiadomosc = @ERRMSG OUTPUT
			END
				
		END TRY
		BEGIN CATCH
			SET @ERRMSG = @@ERROR;
			SET @ERRMSG += ' ';
			SET @ERRMSG += ERROR_MESSAGE();
			
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRAN DT_DELETE
			END
		END CATCH
		
		--przygotowanie XMLa zwrotnego
		SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="DataTypes_Delete"';
		
		IF @DataProgramu IS NOT NULL
			SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), GETDATE(), 23) + '"';

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
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
	
END
