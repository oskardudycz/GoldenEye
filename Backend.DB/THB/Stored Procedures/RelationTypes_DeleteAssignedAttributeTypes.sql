-- =============================================
-- Author:		DK
-- Create date: 2012-06-06
-- Last modified on: 2013-04-04
-- Description:	Usuwa powiazanie wskazanych cech z podanym typem relacji.

-- Przyjmuje XML wejsciowy w postaci:

	--<?xml version="1.0"?>
	--<Request RequestType="RelationTypes_DeleteAssignedAttributeTypes" IsSoftDelete="false" UserId="1" StatusS="" StatusP="" StatusW="" AppDate="2012-09-09T08:23:45" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Ref Id="2" EntityType="RelationType">
	--		<Ref Id="19" EntityType="AttributeType"/>
	--		<Ref Id="2" EntityType="AttributeType"/>
	--		<Ref Id="3" EntityType="AttributeType"/>
	--		<Ref Id="4" EntityType="AttributeType"/>
	--		<Ref Id="5" EntityType="AttributeType"/>
	--	</Ref>	
	--</Request>
	
-- Zwraca XML w postaci:

	--<Response ResponseType="RelationTypes_DeleteAssignedAttributeTypes" AppDate="2012-02-09" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Result>
	--		<Error ErrorMessage="blad"/>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[RelationTypes_DeleteAssignedAttributeTypes]
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
		@BranzaID int = NULL,
		@UsuwanieMiekkie bit = 1,
		@ERRMSG nvarchar(255),
		@xmlOk bit = 0,
		@xml_data xml,
		@Id int,
		@Usunieto bit = 0,
		@MaUprawnienia bit = 0,
		@IdTypuRelacji int,
		@DataUsuniecia datetime = GETDATE(),
		@DataUsunieciaApp datetime,
		@DeleteHardCondition varchar(100),
		@DeleteSoftCondition varchar(100),
		@TypRelacjiId int,
		@MoznaUsuwacNaTwardo bit = 0,
		@ZablokowanyDoEdycji bit = 0

	BEGIN TRY
		SET @ERRMSG = '';
		
		--usuniecie tabel tymczasowych			
		IF OBJECT_ID('tempdb..#DoUsuniecia') IS NOT NULL
			DROP TABLE #DoUsuniecia
			
		CREATE TABLE #DoUsuniecia(TypRelacjiId int, CechaId int);
		
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
			INSERT INTO #DoUsuniecia (TypRelacjiId, CechaId)
			SELECT C.value('../@Id', 'int')
			, C.value('./@Id', 'int') 
			FROM @xml_data.nodes('/Request/Ref/Ref') T(C)
			WHERE C.value('../@EntityType', 'nvarchar(30)') = 'RelationType' AND C.value('./@EntityType', 'nvarchar(30)') = 'AttributeType'		
			
			--SELECT @DataProgramu, @RequestType, @UzytkownikID, @UsuwanieMiekkie			
			--SELECT * FROM #DoUsuniecia;

			IF @RequestType = 'RelationTypes_DeleteAssignedAttributeTypes'
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
					IF EXISTS (SELECT TypRelacji_ID FROM dbo.TypRelacji WHERE IsBlocked = 1 AND TypRelacji_ID IN (SELECT TypRelacjiId FROM #DoUsuniecia))
					BEGIN
						SET @ERRMSG = 'Błąd. Nie można usunąć cechy z zamrożonego typu relacji.';
						SET @ZablokowanyDoEdycji = 1;
					END
					ELSE
						SET @ZablokowanyDoEdycji = 0;
			
					IF @ZablokowanyDoEdycji = 0
					BEGIN	
				
						--pobranie warunkow usuniecia danych w trybie miekkim i twardym
						SET @DeleteHardCondition = THB.GetHardDeleteCondition();
						SET @DeleteSoftCondition = THB.GetSoftDeleteCondition();	
					
						BEGIN TRAN T1_RelationTypes_DeleteAtt
						
						--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
						IF Cursor_Status('local','cur') > 0 
						BEGIN
							 CLOSE cur
							 DEALLOCATE cur
						END
								
						DECLARE cur CURSOR LOCAL FOR 
							SELECT DISTINCT TypRelacjiId FROM #DoUsuniecia
						OPEN cur
						FETCH NEXT FROM cur INTO @IdTypuRelacji
						WHILE @@FETCH_STATUS = 0
						BEGIN
					
							--sprawdzenie czy mozemy usuwac na twardo
							SET @Query = '
								IF EXISTS (SELECT TypRelacji_ID FROM dbo.TypRelacji WHERE TypRelacji_ID = ' + CAST(@IdTypuRelacji AS varchar) + @DeleteHardCondition + ')
									SET @MoznaUsuwacNaTwardo = 1;
								ELSE
									SET @MoznaUsuwacNaTwardo = 0;'
							
							PRINT @Query;	
							EXEC sp_executesql @Query, N'@MoznaUsuwacNaTwardo bit OUTPUT', @MoznaUsuwacNaTwardo = @MoznaUsuwacNaTwardo OUTPUT		
							
							IF @UsuwanieMiekkie = 0 AND @MoznaUsuwacNaTwardo = 1
							BEGIN									
								--trwale usuwanie danych z bazy							
								DELETE FROM dbo.[TypRelacji_Cechy]
								WHERE TypRelacji_ID = @IdTypuRelacji AND Cecha_Id IN (SELECT CechaId FROM #DoUsuniecia WHERE TypRelacji_ID = @IdTypuRelacji);
							END
							ELSE
							BEGIN
								--ustawienie odpowiednich flag
								UPDATE dbo.[TypRelacji_Cechy] SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedBy = @UzytkownikID,
								DeletedFrom = @DataUsunieciaApp,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE TypRelacji_ID = @IdTypuRelacji AND Cecha_Id IN (SELECT CechaId FROM #DoUsuniecia WHERE TypRelacji_ID = @IdTypuRelacji) AND IsValid = 1 AND IsDeleted = 0;
							END
							
							IF @@ROWCOUNT > 0
								SET @Usunieto = 1;
							
							FETCH NEXT FROM cur INTO @IdTypuRelacji
						END
						CLOSE cur
						DEALLOCATE cur									
										
						COMMIT TRAN T1_RelationTypes_DeleteAtt
					END
	
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'RelationTypes_DeleteAssignedAttributeTypes', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'RelationTypes_DeleteAssignedAttributeTypes', @Wiadomosc = @ERRMSG OUTPUT
		END
				
	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN T1_RelationTypes_DeleteAtt
		END
	END CATCH
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="RelationTypes_DeleteAssignedAttributeTypes"';
	
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
	IF OBJECT_ID('tempdb..#DoUsuniecia') IS NOT NULL
		DROP TABLE #DoUsuniecia
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
	
END
