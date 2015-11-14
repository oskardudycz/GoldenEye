-- =============================================
-- Author:		DK
-- Create date: 2012-06-25
-- Last modified on: 2013-04-04
-- Description:	Usuwa powiazanie - struktura obiekt -> relacje

-- Przyjmuje XML wejsciowy w postaci:

	--<Request RequestType="Structures_DeleteAssignedRelations" UserId="1" AppDate="2012-02-09Z" IsSoftDelete="true"
	-- xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Ref Id="15" EntityType="Structure">
	--		<Ref Id="1" EntityType="Relation"/>
	--		<Ref Id="2" EntityType="Relation"/>
	--		<Ref Id="3" EntityType="Relation"/>
	--		<Ref Id="4" EntityType="Relation"/>
	--		<Ref Id="5" EntityType="Relation"/>
	--	</Ref>
	--</Request>
	
-- Zwraca XML w postaci:

	--<Response ResponseType="Structures_DeleteAssignedRelations" AppDate="2012-02-09">
	--	<Result>
	--		<Value>true</Value>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Structures_DeleteAssignedRelations]
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
		@Usunieto bit = 0,
		@MaUprawnienia bit = 0,
		@IdStruktury int,
		@DataUsuniecia datetime = GETDATE(),
		@DataUsunieciaApp datetime,
		@DeleteHardCondition varchar(100),
		@DeleteSoftCondition varchar(100),
		@MoznaUsuwacNaTwardo bit = 0,
		@ZablokowanyDoEdycji bit = 0

	BEGIN TRY
		SET @ERRMSG = '';
		
		--usuniecie tabel tymczasowych			
		IF OBJECT_ID('tempdb..#DoUsuniecia') IS NOT NULL
			DROP TABLE #DoUsuniecia
			
		CREATE TABLE #DoUsuniecia(IdStruktury int, IdRelacji int);
		
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
			INSERT INTO #DoUsuniecia (IdStruktury, IdRelacji)
			SELECT C.value('../@Id', 'int')
			, C.value('./@Id', 'int') 
			FROM @xml_data.nodes('/Request/Ref/Ref') T(C)
			WHERE C.value('../@EntityType', 'nvarchar(30)') = 'Structure' AND C.value('./@EntityType', 'nvarchar(30)') = 'Relation'		
			
			--SELECT @DataProgramu, @RequestType, @UzytkownikID, @UsuwanieMiekkie			
			--SELECT * FROM #DoUsuniecia;

			IF @RequestType = 'Structures_DeleteAssignedRelations'
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
					IF EXISTS (SELECT Id FROM dbo.Struktura_Obiekt WHERE IsBlocked = 1 AND Id IN (SELECT IdStruktury FROM #DoUsuniecia))
					BEGIN
						SET @ERRMSG = 'Błąd. Nie można usunąć relacji z zamrożonej struktury.';
						SET @ZablokowanyDoEdycji = 1;
					END
					ELSE
						SET @ZablokowanyDoEdycji = 0;
				
					IF @ZablokowanyDoEdycji = 0
					BEGIN		
					
						--pobranie warunkow usuniecia danych w trybie miekkim i twardym
						SET @DeleteHardCondition = THB.GetHardDeleteCondition();
						SET @DeleteSoftCondition = THB.GetSoftDeleteCondition();					
						
						BEGIN TRAN T1_Struc_Delete_Rel
						
						--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
						IF Cursor_Status('local','cur') > 0 
						BEGIN
							 CLOSE cur
							 DEALLOCATE cur
						END
								
						DECLARE cur CURSOR LOCAL FOR 
							SELECT DISTINCT IdStruktury FROM #DoUsuniecia
						OPEN cur
						FETCH NEXT FROM cur INTO @IdStruktury
						WHILE @@FETCH_STATUS = 0
						BEGIN
					
							--sprawdzenie czy mozemy usuwac na twardo
							SET @Query = '
								IF EXISTS (SELECT Id FROM dbo.Struktura_Obiekt WHERE Id = ' + CAST(@IdStruktury AS varchar) + @DeleteHardCondition + ')
									SET @MoznaUsuwacNaTwardo = 1;
								ELSE
									SET @MoznaUsuwacNaTwardo = 0;'
									
							EXEC sp_executesql @Query, N'@MoznaUsuwacNaTwardo bit OUTPUT', @MoznaUsuwacNaTwardo = @MoznaUsuwacNaTwardo OUTPUT	
					
						
							IF @UsuwanieMiekkie = 0 AND @MoznaUsuwacNaTwardo = 1
							BEGIN									
								--trwale usuwanie danych z bazy							
								DELETE FROM dbo.[Struktura]
								WHERE StrukturaObiektId = @IdStruktury AND RelacjaId IN (SELECT IdRelacji FROM #DoUsuniecia WHERE StrukturaObiektId = @IdStruktury);
							END
							ELSE
							BEGIN
								--ustawienie odpowiednich flag
								UPDATE dbo.[Struktura] SET
								IsValid = 0,
								IsDeleted = 1,
								DeletedBy = @UzytkownikID,
								DeletedFrom = @DataUsunieciaApp,
								ValidTo = @DataUsunieciaApp,
								RealDeletedFrom = @DataUsuniecia
								WHERE IsDeleted = 0 AND StrukturaObiektId = @IdStruktury AND RelacjaId IN (SELECT IdRelacji FROM #DoUsuniecia WHERE StrukturaObiektId = @IdStruktury);
							END
						
							IF @@ROWCOUNT > 0
								SET @Usunieto = 1;
							
							FETCH NEXT FROM cur INTO @IdStruktury
						END
						CLOSE cur
						DEALLOCATE cur									
											
						COMMIT TRAN T1_Struc_Delete_Rel	
					END
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Structures_DeleteAssignedRelations', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Structures_DeleteAssignedRelations', @Wiadomosc = @ERRMSG OUTPUT
		END
				
	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN T1_Struc_Delete_Rel
		END
	END CATCH
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Structures_DeleteAssignedRelations"';
	
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
