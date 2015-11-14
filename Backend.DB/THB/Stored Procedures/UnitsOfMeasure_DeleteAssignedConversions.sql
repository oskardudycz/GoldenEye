-- =============================================
-- Author:		DK
-- Create date: 2012-06-19
-- Last modified on: 2013-03-20
-- Description:	Usuwa powiazanie - przeliczniki pomiedzy wskazanymi jednostkami miary.

-- Przyjmuje XML wejsciowy w postaci:

	--<Request RequestType="UnitsOfMeasure_DeleteAssignedConversions" UserId="1" AppDate="2012-09-09T09:23:43" IsSoftDelete="true"
	--xsi:noNamespaceSchemaLocation="10.4.Request.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Ref Id="15" EntityType="UnitOfMeasure">
	--		<Ref Id="1" EntityType="UnitOfMeasure"/>
	--		<Ref Id="2" EntityType="UnitOfMeasure"/>		
	--	</Ref>
	--</Request>
	
-- Zwraca XML w postaci:

	--<Response ResponseType="UnitsOfMeasure_DeleteAssignedConversions" AppDate="2012-02-09">
	--	<Result>
	--		<Error ErrorMessage="ble ble"/>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[UnitsOfMeasure_DeleteAssignedConversions]
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
		@IdJednostki int,
		@IdJednostkiDo int,
		@DataUsuniecia datetime = GETDATE(),
		@DataUsunieciaApp datetime,
		@DeleteHardCondition varchar(100),
		@DeleteSoftCondition varchar(100),
		@MoznaUsuwacNaTwardo bit = 0,
		@ZablokowanyDoEdycji bit

	BEGIN TRY
		SET @ERRMSG = '';
		
		--usuniecie tabel tymczasowych			
		IF OBJECT_ID('tempdb..#DoUsuniecia') IS NOT NULL
			DROP TABLE #DoUsuniecia
			
		CREATE TABLE #DoUsuniecia(JednostkaMiaryId int, JednostkaMiaryDoId int);
		
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
			INSERT INTO #DoUsuniecia (JednostkaMiaryId, JednostkaMiaryDoId)
			SELECT C.value('../@Id', 'int')
			, C.value('./@Id', 'int') 
			FROM @xml_data.nodes('/Request/Ref/Ref') T(C)
			WHERE C.value('../@EntityType', 'nvarchar(30)') = 'UnitOfMeasure' AND C.value('./@EntityType', 'nvarchar(30)') = 'UnitOfMeasure'		
			
			--SELECT @DataProgramu, @RequestType, @UzytkownikID, @UsuwanieMiekkie			
			--SELECT * FROM #DoUsuniecia;

			IF @RequestType = 'UnitsOfMeasure_DeleteAssignedConversions'
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
						
					
					--sprawdzenie czy podano do usuniecia ceche zablokowana do edycji					
					IF EXISTS (SELECT Id FROM dbo.JednostkiMiary WHERE IsBlocked = 1 AND (Id IN (SELECT JednostkaMiaryId FROM #DoUsuniecia) OR Id IN (SELECT JednostkaMiaryDoId FROM #DoUsuniecia)))
					BEGIN
						SET @ERRMSG = 'Błąd. Nie można usunąć przelicznika zamrożonej jednostki miary.';
						SET @ZablokowanyDoEdycji = 1;
					END
					ELSE
						SET @ZablokowanyDoEdycji = 0;
					
					IF @ZablokowanyDoEdycji = 0
					BEGIN	
						BEGIN TRAN T1_DelConv
						
						--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
						IF Cursor_Status('local','cur') > 0 
						BEGIN
							 CLOSE cur
							 DEALLOCATE cur
						END
								
						DECLARE cur CURSOR LOCAL FOR 
							SELECT DISTINCT JednostkaMiaryId, JednostkaMiaryDoId FROM #DoUsuniecia
						OPEN cur
						FETCH NEXT FROM cur INTO @IdJednostki, @IdJednostkiDo
						WHILE @@FETCH_STATUS = 0
						BEGIN
								
							--sprawdzenie czy mozemy usuwac na twardo
							SET @Query = '
								IF EXISTS (SELECT Id FROM dbo.JednostkiMiary WHERE Id = ' + CAST(@IdJednostki AS varchar) + @DeleteHardCondition + ')
									SET @MoznaUsuwacNaTwardo = 1;
								ELSE
									SET @MoznaUsuwacNaTwardo = 0;'
									
							EXEC sp_executesql @Query, N'@MoznaUsuwacNaTwardo bit OUTPUT', @MoznaUsuwacNaTwardo = @MoznaUsuwacNaTwardo OUTPUT							
						
							IF @UsuwanieMiekkie = 0 AND @MoznaUsuwacNaTwardo = 1
							BEGIN									
								--trwale usuwanie danych z bazy							
								DELETE FROM dbo.[JednostkiMiary_Przeliczniki]
								WHERE (IdFrom = @IdJednostki AND IdTo = @IdJednostkiDo) OR (IdFrom = @IdJednostkiDo AND IdTo = @IdJednostki)
							END
							ELSE
							BEGIN
								--ustawienie odpowiednich flag
								UPDATE dbo.[JednostkiMiary_Przeliczniki] SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedBy = @UzytkownikID,
								DeletedFrom = @DataUsunieciaApp,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE IsDeleted = 0 AND ((IdFrom = @IdJednostki AND IdTo = @IdJednostkiDo) OR (IdFrom = @IdJednostkiDo AND IdTo = @IdJednostki));
							END
							
							IF @@ROWCOUNT > 0
								SET @Usunieto = 1;
							
							FETCH NEXT FROM cur INTO @IdJednostki, @IdJednostkiDo
						END
						CLOSE cur
						DEALLOCATE cur									
											
						COMMIT TRAN T1_DelConv
					END
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'UnitsOfMeasure_DeleteAssignedConversions', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'UnitsOfMeasure_DeleteAssignedConversions', @Wiadomosc = @ERRMSG OUTPUT
		END
				
	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN T1_DelConv
		END
	END CATCH
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="UnitsOfMeasure_DeleteAssignedConversions"';
	
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
