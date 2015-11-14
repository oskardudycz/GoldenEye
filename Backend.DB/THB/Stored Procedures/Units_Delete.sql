-- =============================================
-- Author:		DK
-- Create date: 2012-03-22
-- Last modified on: 2013-02-20
-- Description:	Usuwa wpis z tabeli {TypObiektu} i {TypObiektu_Cechy_Hist} dla obiektu o podanych Id.

-- XML wejsciowy o postaci:

	--<Request RequestType="Units_Delete" UserId="1" AppDate="2012-09-21T12:33:44" IsSoftDelete="true">
	--	<ObjectRef Id="1" TypeId="12" EntityType="Unit"/>
	--	<ObjectRef Id="15" TypeId="52" EntityType="Unit"/>
	--	<ObjectRef Id="601" TypeId="200" EntityType="Unit"/>
	--</Request>
	
-- XML wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="StructureTypes_Delete" AppDate="2012-02-09Z" xsi:noNamespaceSchemaLocation="5.2.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Result>
	--		<Value>true</Value>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Units_Delete]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Query nvarchar(max) = '',
		@DataProgramu nvarchar(20),
		@RequestType nvarchar(100),
		@UzytkownikID int,
		@BranzaID int,
		@UsuwanieMiekkie bit = 0,
		@ERRMSG nvarchar(255) = '',
		@xmlOk bit = 0,
		@xml_data xml,
		@IloscZmienionych int = 0,
		@IloscZmienionychTmp int = 0,
		@tableName nvarchar(200),
		@TypObiektuId int,
		@MaUprawnienia bit = 0,
		@DataUsuniecia datetime = GETDATE(),
		@DataUsunieciaApp datetime,
		@DeleteHardCondition varchar(100),
		@DeleteSoftCondition varchar(100),
		@MoznaUsuwacNaTwardo bit = 0,
		@ObiektId int
		
		--usuniecie tabel tymczasowych
		IF OBJECT_ID('tempdb..#DaneObiektow') IS NOT NULL
			DROP TABLE #DaneObiektow
			
		IF OBJECT_ID('tempdb..#RelacjeDlaObiektow') IS NOT NULL
			DROP TABLE #RelacjeDlaObiektow
		
		CREATE TABLE #RelacjeDlaObiektow (Id int);
		CREATE TABLE #DaneObiektow(Id int, TypObiektuId int);	
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Units_Delete', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
	
		IF @xmlOk = 0
		BEGIN
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
					,@BranzaID = C.value('./@BranchId', 'int')
			FROM @xml_data.nodes('/Request') T(C)
			
			--wyciaganie danych obiektow do usuniecia
			INSERT INTO #DaneObiektow
			SELECT	C.value('./@Id', 'int')
				,C.value('./@TypeId', 'int')
			FROM @xml_data.nodes('/Request/ObjectRef') T(C)
			WHERE C.value('./@EntityType', 'nvarchar(50)') = 'Unit'
			
		--	SELECT * FROM 	#StukturaObiekt
		--	SELECT @DataProgramu, @RequestType, @UzytkownikID, @UsuwanieMiekkie
		--	SELECT * FROM #TypyStruktur
		  --SELECT * FROM #DaneObiektow
			
			IF @RequestType = 'Units_Delete'
			BEGIN
			
				BEGIN TRY
		
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
						
					BEGIN TRAN T1_Units_DELETE
		
					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','cur') > 0 
					BEGIN
						 CLOSE cur
						 DEALLOCATE cur
					END
				
					DECLARE cur CURSOR LOCAL FOR 
						SELECT DISTINCT TypObiektuId FROM #DaneObiektow
					OPEN cur
					FETCH NEXT FROM cur INTO @TypObiektuId
					WHILE @@FETCH_STATUS = 0
					BEGIN
					
						--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
						IF Cursor_Status('local','curObiekty') > 0 
						BEGIN
							 CLOSE curObiekty
							 DEALLOCATE curObiekty
						END
					
						DECLARE curObiekty CURSOR LOCAL FOR 
							SELECT DISTINCT Id FROM #DaneObiektow WHERE TypObiektuId = @TypObiektuId
						OPEN curObiekty
						FETCH NEXT FROM curObiekty INTO @ObiektId
						WHILE @@FETCH_STATUS = 0
						BEGIN
						
							DELETE FROM #RelacjeDlaObiektow;
						
							--pobranie Id Relacji w ktorych sa usuane obiekty
							INSERT INTO #RelacjeDlaObiektow(Id)
							SELECT Id
							FROM Relacje
							WHERE (TypObiektuID_L = @TypObiektuId OR TypObiektuID_R = @TypObiektuId) AND (ObiektID_L = @ObiektId OR ObiektID_R = @ObiektId) 

							SELECT DISTINCT @tableName = t.Nazwa 
							FROM dbo.TypObiektu t 
							WHERE t.TypObiekt_ID = @TypObiektuId

							--sprawdzenie czy mozemy usuwac na twardo
							SET @Query = '
								IF EXISTS (SELECT Id FROM dbo.[_' + @tableName + '] WHERE Id = ' + CAST(@ObiektId AS varchar) + @DeleteHardCondition + ')
									SET @MoznaUsuwacNaTwardo = 1;
								ELSE
									SET @MoznaUsuwacNaTwardo = 0;'
									
							EXEC sp_executesql @Query, N'@MoznaUsuwacNaTwardo bit OUTPUT', @MoznaUsuwacNaTwardo = @MoznaUsuwacNaTwardo OUTPUT	
					
						
							--usuwanie danych w tabelach powiazanych
							IF @UsuwanieMiekkie = 0 AND @MoznaUsuwacNaTwardo = 1
							BEGIN
								DELETE FROM [Struktura]
								WHERE RelacjaId IN (SELECT Id FROM #RelacjeDlaObiektow);
								
								DELETE FROM [Relacja_Cecha_Hist]
								WHERE RelacjaId IN (SELECT Id FROM #RelacjeDlaObiektow);
								
								DELETE FROM [TypObiektu_Relacje_Cechy]
								WHERE RelacjaId IN (SELECT Id FROM #RelacjeDlaObiektow);
								
								DELETE FROM [TypObiektu_Relacje]
								WHERE RelacjaId IN (SELECT Id FROM #RelacjeDlaObiektow);
								
								DELETE FROM [Relacje]
								WHERE Id IN (SELECT Id FROM #RelacjeDlaObiektow) OR IdArch IN (SELECT Id FROM #RelacjeDlaObiektow);
							
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
								WHERE IsDeleted = 0 AND RelacjaId IN (SELECT Id FROM #RelacjeDlaObiektow);
							
								UPDATE [Relacja_Cecha_Hist] SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedBy = @UzytkownikID,
								DeletedFrom = @DataUsunieciaApp,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE IsDeleted = 0 AND RelacjaId IN (SELECT Id FROM #RelacjeDlaObiektow);
								
								UPDATE [TypObiektu_Relacje_Cechy] SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedBy = @UzytkownikID,
								DeletedFrom = @DataUsunieciaApp,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE IsDeleted = 0 AND RelacjaId IN (SELECT Id FROM #RelacjeDlaObiektow);
								
								UPDATE [TypObiektu_Relacje] SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedBy = @UzytkownikID,
								DeletedFrom = @DataUsunieciaApp,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia						
								WHERE IsDeleted = 0 AND RelacjaId IN (SELECT Id FROM #RelacjeDlaObiektow);
							
								UPDATE [Relacje] SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedBy = @UzytkownikID,
								DeletedFrom = @DataUsunieciaApp,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE IsDeleted = 0 AND (Id IN (SELECT Id FROM #RelacjeDlaObiektow) OR IdArch IN (SELECT Id FROM #RelacjeDlaObiektow));
							END

							--usuwanie danych z tabel typu obiektu
							IF @UsuwanieMiekkie = 0 AND @MoznaUsuwacNaTwardo = 1
							BEGIN									
								--trwale ususwanie danych z bazy
								SET @Query = '
								IF OBJECT_ID (N''[_' + @tableName + '_Cechy_Hist]'', N''U'') IS NOT NULL
								BEGIN
									DELETE FROM [dbo].[_' + @tableName + '_Cechy_Hist] 
									WHERE ObiektId = ' + CAST(@ObiektId AS varchar) + '
								END
								
								IF OBJECT_ID (N''[_' + @tableName + '_Relacje_Hist]'', N''U'') IS NOT NULL
								BEGIN	
									DELETE FROM [dbo].[_' + @tableName + '_Relacje_Hist] 
									WHERE ObiektId = ' + CAST(@ObiektId AS varchar) + '
								END
								
								IF OBJECT_ID (N''[_' + @tableName + ']'', N''U'') IS NOT NULL
								BEGIN	
									DELETE FROM [dbo].[_' + @tableName + '] 
									WHERE Id = ' + CAST(@ObiektId AS varchar) + ' OR IdArch = ' + CAST(@ObiektId AS varchar) + '
								END
								'							
							END
							ELSE
							BEGIN
								--ustawienie odpowiednich flag							
								SET @Query = '
								IF OBJECT_ID (N''[_' + @tableName + '_Cechy_Hist]'', N''U'') IS NOT NULL
								BEGIN						
									UPDATE [dbo].[_' + @tableName + '_Cechy_Hist] SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
									DeletedFrom = ''' + CAST(@DataUsunieciaApp AS varchar) + ''',
									--LastModifiedBy = ' + CAST(@UzytkownikID AS varchar) + ',
									--LastModifiedOn = ''' + CAST(@DataUsunieciaApp AS varchar) + ''',
									ValidTo = ''' + CAST(@DataUsunieciaApp AS varchar) + ''',
									RealDeletedFrom = ''' + CAST(@DataUsuniecia AS varchar) + '''
									WHERE IsDeleted = 0 AND ObiektId = ' + CAST(@ObiektId AS varchar) + '
								END
									
								IF OBJECT_ID (N''[_' + @tableName + '_Relacje_Hist]'', N''U'') IS NOT NULL
								BEGIN
									UPDATE [dbo].[_' + @tableName + '_Relacje_Hist] SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
									DeletedFrom = ''' + CAST(@DataUsunieciaApp AS varchar) + ''',
									--LastModifiedBy = ' + CAST(@UzytkownikID AS varchar) + ',
									--LastModifiedOn = ''' + CAST(@DataUsunieciaApp AS varchar) + ''',
									ValidTo = ''' + CAST(@DataUsunieciaApp AS varchar) + ''',
									RealDeletedFrom = ''' + CAST(@DataUsuniecia AS varchar) + '''
									WHERE IsDeleted = 0 AND ObiektId = ' + CAST(@ObiektId AS varchar) + '
								END'
								
							SET @Query += '
								IF OBJECT_ID (N''[_' + @tableName + ']'', N''U'') IS NOT NULL
								BEGIN	
									UPDATE [dbo].[_' + @tableName + '] SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
									DeletedFrom = ''' + CAST(@DataUsunieciaApp AS varchar) + ''',
									--LastModifiedBy = ' + CAST(@UzytkownikID AS varchar) + ',
									--LastModifiedOn = ''' + CAST(@DataUsunieciaApp AS varchar) + ''',
									ValidTo = ''' + CAST(@DataUsunieciaApp AS varchar) + ''',
									RealDeletedFrom = ''' + CAST(@DataUsuniecia AS varchar) + '''
									WHERE IsDeleted = 0 AND (Id = ' + CAST(@ObiektId AS varchar) + ' OR IdArch = ' + CAST(@ObiektId AS varchar) + ')
								END'
							END
							
							SET @Query += ' SET @IloscZmienionychTmp = @@ROWCOUNT;';
								
							--PRINT @Query;
							EXECUTE sp_executesql @Query, N'@IloscZmienionychTmp int OUTPUT', @IloscZmienionychTmp = @IloscZmienionychTmp OUTPUT
							
							SET @IloscZmienionych += @IloscZmienionychTmp;
							
							FETCH NEXT FROM curObiekty INTO @ObiektId
						END
						CLOSE curObiekty;
						DEALLOCATE curObiekty;
							
						FETCH NEXT FROM cur INTO @TypObiektuId							
					END
					CLOSE cur;
					DEALLOCATE cur;			
					
					COMMIT TRAN T1_Units_DELETE
		
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Units_Delete', @Wiadomosc = @ERRMSG OUTPUT
					
				END TRY
				BEGIN CATCH
					SET @ERRMSG = @@ERROR;
					SET @ERRMSG += ' ';
					SET @ERRMSG +=  ERROR_MESSAGE();

					IF @@TRANCOUNT > 0
					BEGIN
						ROLLBACK TRAN T1_Units_DELETE
					END
				END CATCH
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Units_Delete', @Wiadomosc = @ERRMSG OUTPUT 
		END	
		
	--przygotowanie XMLa zwrotnego	
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Units_Delete"'
	
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
	IF OBJECT_ID('tempdb..#DaneObiektow') IS NOT NULL
		DROP TABLE #DaneObiektow
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
END
