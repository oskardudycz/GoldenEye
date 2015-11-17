-- =============================================
-- Author:		DK
-- Create date: 2012-06-06
-- Last modified date: 2013-02-18
-- Description:	Usuwa powiazanie wskazanych cech z podanym typem relacji.

-- Przyjmuje XML wejsciowy w postaci:

	--<?xml version="1.0"?>
	--<Request RequestType="UnitTypes_DeleteAssignedAttributeTypes" IsSoftDelete="false" UserId="1" AppDate="2012-09-10T11:44:22">
	--	<Ref Id="2" EntityType="UnitType">
	--		<Ref Id="19" EntityType="AttributeType"/>
	--		<Ref Id="2" EntityType="AttributeType"/>
	--		<Ref Id="3" EntityType="AttributeType"/>
	--		<Ref Id="4" EntityType="AttributeType"/>
	--		<Ref Id="5" EntityType="AttributeType"/>
	--	</Ref>	
	--</Request>
	
-- Zwraca XML w postaci:

	--<Response ResponseType="UnitTypes_DeleteAssignedAttributeTypes" AppDate="2012-02-09" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Result>
	--		<Value>true</Value>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[UnitTypes_DeleteAssignedAttributeTypes]
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
		@ERRMSG nvarchar(255),
		@xmlOk bit = 0,
		@xml_data xml,
		@Id int,
		@Usunieto bit = 0,
		@MaUprawnienia bit = 0,
		@IdTypuObiektu int,
		@DataUsuniecia datetime = GETDATE(),
		@DataUsunieciaApp datetime,
		@NazwaTypuObiektu nvarchar(500),
		@CzyTabela bit,
		@ZablokowanyDoEdycji bit = 0

	BEGIN TRY
		SET @ERRMSG = '';
		
		--usuniecie tabel tymczasowych			
		IF OBJECT_ID('tempdb..#DoUsunieciaCechyTypuObiektu') IS NOT NULL
			DROP TABLE #DoUsunieciaCechyTypuObiektu
			
		CREATE TABLE #DoUsunieciaCechyTypuObiektu(TypObiektuId int, CechaId int);
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Standard_DeleteAssign', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
	
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
					,@RequestType = C.value('./@RequestType', 'nvarchar(50)')
					,@UzytkownikID = C.value('./@UserId', 'nvarchar(32)')
					,@UsuwanieMiekkie = C.value('./@IsSoftDelete', 'bit')
					,@BranzaId = C.value('./@BranchId', 'int')
			FROM @xml_data.nodes('/Request') T(C)
			
			--pobranie id typow cech do usuniecia
			INSERT INTO #DoUsunieciaCechyTypuObiektu (TypObiektuId, CechaId)
			SELECT C.value('../@Id', 'int')
			, C.value('./@Id', 'int') 
			FROM @xml_data.nodes('/Request/Ref/Ref') T(C)
			WHERE C.value('../@EntityType', 'nvarchar(30)') = 'UnitType' AND C.value('./@EntityType', 'nvarchar(30)') = 'AttributeType'		
			
			--SELECT @DataProgramu, @RequestType, @UzytkownikID, @UsuwanieMiekkie			
			--SELECT * FROM #DoUsunieciaCechyTypuObiektu;

			IF @RequestType = 'UnitTypes_DeleteAssignedAttributeTypes'
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
				
					BEGIN TRAN T1_UnitTypes_DeleteAT
					
					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','cur') > 0 
					BEGIN
						 CLOSE cur
						 DEALLOCATE cur
					END
							
					DECLARE cur CURSOR LOCAL FOR 
						SELECT DISTINCT TypObiektuId FROM #DoUsunieciaCechyTypuObiektu
					OPEN cur
					FETCH NEXT FROM cur INTO @IdTypuObiektu
					WHILE @@FETCH_STATUS = 0
					BEGIN
	
						--pobranie nazwy typu obiektu
						SELECT @NazwaTypuObiektu = Nazwa, @CzyTabela = Tabela, @ZablokowanyDoEdycji = IsBlocked
						FROM dbo.TypObiektu
						WHERE TypObiekt_ID = @IdTypuObiektu AND IsValid = 1 AND IsDeleted = 0;
						
						--usuwamy dane tylko jesli typ obiektu nie jest zablokowny do edycji
						IF 0=0 --@ZablokowanyDoEdycji = 0
						BEGIN
					
							IF @UsuwanieMiekkie = 0
							BEGIN									
								--trwale usuwanie danych z bazy							
								DELETE FROM dbo.[TypObiektu_Cechy]
								WHERE TypObiektu_ID = @IdTypuObiektu AND Cecha_Id IN (SELECT CechaId FROM #DoUsunieciaCechyTypuObiektu WHERE TypObiektuId = @IdTypuObiektu);
							END
							ELSE
							BEGIN
								--ustawienie odpowiednich flag
								UPDATE dbo.TypObiektu_Cechy SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedBy = @UzytkownikID,
								DeletedFrom = @DataUsunieciaApp,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia 
								WHERE IsDeleted = 0 AND TypObiektu_ID = @IdTypuObiektu AND Cecha_Id IN (SELECT CechaId FROM #DoUsunieciaCechyTypuObiektu WHERE TypObiektuId = @IdTypuObiektu);
							END
						
							--jesli usunieto jakies rekordy w tabeli TypObiektu_Cechy
							IF @@ROWCOUNT > 0
							BEGIN
								SET @Usunieto = 1;
								
								IF @NazwaTypuObiektu IS NOT NULL AND LEN(@NazwaTypuObiektu) > 0
								BEGIN
								
									IF @UsuwanieMiekkie = 0
									BEGIN
										SET @Query = '
											IF OBJECT_ID(''[_' + @NazwaTypuObiektu + '_Cechy_Hist]'') IS NOT NULL
											BEGIN
												DELETE FROM [_' + @NazwaTypuObiektu + '_Cechy_Hist]
												WHERE CechaID IN (SELECT CechaId FROM #DoUsunieciaCechyTypuObiektu WHERE TypObiektuId = ' + CAST(@IdTypuObiektu AS varchar) + ')
											END'
									END
									ELSE
									BEGIN
										SET @Query = '
											IF OBJECT_ID(''[_' + @NazwaTypuObiektu + '_Cechy_Hist]'') IS NOT NULL
											BEGIN
												UPDATE [_' + @NazwaTypuObiektu + '_Cechy_Hist] SET
												IsValid = 0,
												IsDeleted = 1,
												DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
												DeletedFrom = ''' + CONVERT(varchar, @DataUsunieciaApp, 109) + ''',
												ValidTo = ''' + CONVERT(varchar, @DataUsunieciaApp, 109) + ''',
												RealDeletedFrom = ''' + CONVERT(varchar, @DataUsuniecia, 109) + '''										
												WHERE IsValid = 1 AND IsDeleted = 0 AND CechaID IN (SELECT CechaId FROM #DoUsunieciaCechyTypuObiektu WHERE TypObiektuId = ' + CAST(@IdTypuObiektu AS varchar) + ')
											END'
									END
									
									--PRINT @Query;
									EXEC(@Query);
										
								END
							END
							
							IF @CzyTabela = 1
							BEGIN
								DECLARE @ColumnName nvarchar(100),
										@CechaIdDoUsuniecia int
							
								DECLARE curColumns CURSOR LOCAL FOR 
								SELECT DISTINCT CechaId FROM #DoUsunieciaCechyTypuObiektu WHERE TypObiektuId = @IdTypuObiektu
								OPEN curColumns
								FETCH NEXT FROM curColumns INTO @CechaIdDoUsuniecia
								WHILE @@FETCH_STATUS = 0
								BEGIN
									--usuniecie odpowiednich kolumn z tabeli
																										
									SELECT @ColumnName = dbo.Trim(c.Nazwa)
									FROM dbo.Cechy c
									WHERE c.Cecha_ID = @CechaIdDoUsuniecia;

									--jesli kolumna nie istnieje to jej dodanie do tabeli
									SET @Query = '
										IF [THB].[ColumnExists] (''_' + @NazwaTypuObiektu + ''', ''' + @ColumnName + ''') = 1
										BEGIN
											ALTER TABLE [_' + @NazwaTypuObiektu + ']
											DROP COLUMN [' + @ColumnName + '];
										END'
										
									--PRINT @Query
									EXECUTE sp_executesql @Query;
									
									FETCH NEXT FROM curColumns INTO @CechaIdDoUsuniecia
								END
								CLOSE curColumns;
								DEALLOCATE curColumns;
					
								--zmiana trigera na update jesli typ tabelaryczny
								EXEC [THB].[UpdateTriggerForTableUnitType]
									@UnitTypeId = @IdTypuObiektu,
									@OldName = @NazwaTypuObiektu,
									@NewName = @NazwaTypuObiektu
							
							END
						END
						ELSE
							SET @ERRMSG = 'Błąd. Nie można usunąć typu obiektu zablokowanego do edycji.';
						
						FETCH NEXT FROM cur INTO @IdTypuObiektu
					END
					CLOSE cur
					DEALLOCATE cur									
										
					COMMIT TRAN T1_UnitTypes_DeleteAT	
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'UnitTypes_DeleteAssignedAttributeTypes', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'UnitTypes_DeleteAssignedAttributeTypes', @Wiadomosc = @ERRMSG OUTPUT
		END
				
	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN T1_UnitTypes_DeleteAT
		END
	END CATCH
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="UnitTypes_DeleteAssignedAttributeTypes"';
	
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
	IF OBJECT_ID('tempdb..#DoUsunieciaCechyTypuObiektu') IS NOT NULL
		DROP TABLE #DoUsunieciaCechyTypuObiektu
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
	
END
