-- =============================================
-- Author:		DK
-- Create date: 2012-06-05
-- Last modified on: 2013-02-18
-- Description:	Usuwa powiazanie wskazanej cechy z podanymi branzami.

-- Przyjmuje XML wejsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Request RequestType="AttributeTypes_DeleteAssignedBranches" IsSoftDelete="false" UserId="1" AppDate="2012-02-09T12:45:22">
	--	<Ref Id="2" EntityType="AttributeType">
	--		<Ref Id="19" EntityType="Branch"/>
	--		<Ref Id="2" EntityType="Branch"/>
	--		<Ref Id="3" EntityType="Branch"/>
	--		<Ref Id="4" EntityType="Branch"/>
	--		<Ref Id="5" EntityType="Branch"/>
	--	</Ref>	
	--</Request>
	
-- Zwraca XML w postaci:

	--<Response ResponseType="AttributeTypes_DeleteAssignedBranches"" AppDate="2012-02-09" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Result>
	--		<Error ErrorMessage="blad"/>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[AttributeTypes_DeleteAssignedBranches]
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
		@IdCechy int,
		@DataUsuniecia datetime = GETDATE(),
		@DataUsunieciaApp datetime,
		@DeleteHardCondition varchar(100),
		@DeleteSoftCondition varchar(100)

	BEGIN TRY
		SET @ERRMSG = '';
		
		--usuniecie tabel tymczasowych			
		IF OBJECT_ID('tempdb..#DoUsuniecia') IS NOT NULL
			DROP TABLE #DoUsuniecia
			
		CREATE TABLE #DoUsuniecia(CechaId int, BranzaId int);
		
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
			
			CREATE TABLE #Cechy (ID int);
					
			--wyciaganie daty i typu zadania
			SELECT @DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(50)')
					,@UzytkownikID = C.value('./@UserId', 'nvarchar(32)')
					,@UsuwanieMiekkie = C.value('./@IsSoftDelete', 'bit')
					,@BranzaId = C.value('./@BranchId', 'int')
			FROM @xml_data.nodes('/Request') T(C)
			
			--pobranie id typow cech do usuniecia
			INSERT INTO #DoUsuniecia (CechaId, BranzaId)
			SELECT C.value('../@Id', 'int')
			, C.value('./@Id', 'int') 
			FROM @xml_data.nodes('/Request/Ref/Ref') T(C)
			WHERE C.value('../@EntityType', 'nvarchar(30)') = 'AttributeType' AND C.value('./@EntityType', 'nvarchar(30)') = 'Branch'		
			
			--SELECT @DataProgramu, @RequestType, @UzytkownikID, @UsuwanieMiekkie			
			--SELECT * FROM #DoUsuniecia;

			IF @RequestType = 'AttributeTypes_DeleteAssignedBranches'
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
				
					BEGIN TRAN T1_AT_DeleteBranches
					
					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','cur') > 0 
					BEGIN
						 CLOSE cur
						 DEALLOCATE cur
					END
							
					DECLARE cur CURSOR LOCAL FOR 
						SELECT DISTINCT CechaId FROM #DoUsuniecia
					OPEN cur
					FETCH NEXT FROM cur INTO @IdCechy
					WHILE @@FETCH_STATUS = 0
					BEGIN		
						
						IF @UsuwanieMiekkie = 0
						BEGIN									
							--trwale usuwanie danych z bazy
							SET @Query = '						
								DELETE FROM dbo.[Branze_Cechy]
								WHERE CechaId = @Id AND BranzaId IN (SELECT BranzaId FROM #DoUsuniecia WHERE CechaId = @Id)' + @DeleteHardCondition + ';
								
								IF @@ROWCOUNT > 0
									SET @Usunieto = 1;
									
								UPDATE dbo.[Branze_Cechy] SET
									IsValid = 0,
									IsDeleted = 1,
									DeletedBy = ' + CAST(@UzytkownikID AS varchar) + ',
									DeletedFrom = @DataUsunieciaApp,
									ValidTo = @DataUsunieciaApp,
									RealDeletedFrom = @DataUsuniecia
								WHERE IsDeleted = 0 AND CechaId = @Id AND BranzaId IN (SELECT BranzaId FROM #DoUsuniecia WHERE CechaId = @Id)' + @DeleteSoftCondition + '
								
								IF @@ROWCOUNT > 0
									SET @Usunieto = 1;' 
									
							--PRINT @Query;
							EXEC sp_executesql @Query, N'@Id int, @DataUsunieciaApp datetime, @DataUsuniecia datetime, @Usunieto bit OUTPUT', 
								@Id = @IdCechy, @DataUsunieciaApp = @DataUsunieciaApp, @DataUsuniecia = @DataUsuniecia, @Usunieto = @Usunieto OUTPUT
							
						END
						ELSE
						BEGIN
							--ustawienie odpowiednich flag
							UPDATE dbo.[Branze_Cechy] SET
							IsValid = 0,
							IsDeleted = 1,
							DeletedBy = @UzytkownikID,
							DeletedFrom = @DataUsunieciaApp,
							ValidTo = @DataUsunieciaApp,
							RealDeletedFrom = @DataUsuniecia
							WHERE IsDeleted = 0 AND CechaId = @IdCechy AND BranzaId IN (SELECT BranzaId FROM #DoUsuniecia WHERE CechaId = @IdCechy);
							
							IF @@ROWCOUNT > 0
								SET @Usunieto = 1;
						END						
						
						FETCH NEXT FROM cur INTO @IdCechy
					END
					CLOSE cur
					DEALLOCATE cur									
										
					COMMIT TRAN T1_AT_DeleteBranches
	
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'AttributeTypes_DeleteAssignedBranches', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'AttributeTypes_DeleteAssignedBranches', @Wiadomosc = @ERRMSG OUTPUT
		END
				
	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN T1_AT_DeleteBranches
		END
	END CATCH
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="AttributeTypes_DeleteAssignedBranches"';
	
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
