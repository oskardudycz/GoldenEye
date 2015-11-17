-- =============================================
-- Author:		DK
-- Create date: 2012-06-20
-- Last modified on: 2013-02-22
-- Description:	Usuwa powiazanie - grupy uzytkownikow -> role

-- Przyjmuje XML wejsciowy w postaci:

	--<Request RequestType="UserGroups_DeleteAssignedRoles" UserId="1" AppDate="2012-02-09T12:34:55" IsSoftDelete="true"
	-- xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Ref Id="15" EntityType="UserGroup">
	--		<Ref Id="4" EntityType="Role"/>
	--		<Ref Id="5" EntityType="Role"/>		
	--	</Ref>
	--</Request>
	
-- Zwraca XML w postaci:

	--<Response ResponseType="UserGroups_DeleteAssignedRoles" AppDate="2012-02-09">
	--	<Result>
	--		<Value>true</Value>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[UserGroups_DeleteAssignedRoles]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DataProgramu datetime,
		@Query nvarchar(MAX),
		@RequestType nvarchar(100),
		@UzytkownikID int,
		@BranzaID int = NULL,
		@UsuwanieMiekkie bit = 1,
		@ERRMSG nvarchar(255),
		@xmlOk bit = 0,
		@xml_data xml,
		@Usunieto bit = 0,
		@MaUprawnienia bit = 0,
		@IdGrupy int,
		@DataUsuniecia datetime = GETDATE(),
		@DataUsunieciaApp datetime,
		@DeleteHardCondition varchar(100),
		@DeleteSoftCondition varchar(100),
		@MoznaUsuwacNaTwardo bit = 0

	BEGIN TRY
		SET @ERRMSG = '';
		
		--usuniecie tabel tymczasowych			
		IF OBJECT_ID('tempdb..#DoUsuniecia') IS NOT NULL
			DROP TABLE #DoUsuniecia
			
		CREATE TABLE #DoUsuniecia(IdGrupy int, IdRoli int);
		
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
			INSERT INTO #DoUsuniecia (IdGrupy, IdRoli)
			SELECT C.value('../@Id', 'int')
			, C.value('./@Id', 'int') 
			FROM @xml_data.nodes('/Request/Ref/Ref') T(C)
			WHERE C.value('../@EntityType', 'nvarchar(30)') = 'UserGroup' AND C.value('./@EntityType', 'nvarchar(30)') = 'Role'		
			
			--SELECT @DataProgramu, @RequestType, @UzytkownikID, @UsuwanieMiekkie			
			--SELECT * FROM #DoUsuniecia;

			IF @RequestType = 'UserGroups_DeleteAssignedRoles'
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
					
					
					BEGIN TRAN T1_DEL_ROLES
					
					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','cur') > 0 
					BEGIN
						 CLOSE cur
						 DEALLOCATE cur
					END
							
					DECLARE cur CURSOR LOCAL FOR 
						SELECT DISTINCT IdGrupy FROM #DoUsuniecia
					OPEN cur
					FETCH NEXT FROM cur INTO @IdGrupy
					WHILE @@FETCH_STATUS = 0
					BEGIN
					
						--sprawdzenie czy mozemy usuwac na twardo
						SET @Query = '
							IF EXISTS (SELECT Id FROM dbo.GrupyUzytkownikow WHERE Id = ' + CAST(@IdGrupy AS varchar) + @DeleteHardCondition + ')
								SET @MoznaUsuwacNaTwardo = 1;
							ELSE
								SET @MoznaUsuwacNaTwardo = 0;'
								
						EXEC sp_executesql @Query, N'@MoznaUsuwacNaTwardo bit OUTPUT', @MoznaUsuwacNaTwardo = @MoznaUsuwacNaTwardo OUTPUT						
					
						IF @UsuwanieMiekkie = 0 AND @MoznaUsuwacNaTwardo = 1
						BEGIN									
							--trwale usuwanie danych z bazy							
							DELETE FROM dbo.[RolaGrupaUzytkownikow]
							WHERE GrupaUzytkownikow = @IdGrupy AND Rola IN (SELECT IdRoli FROM #DoUsuniecia WHERE IdGrupy = @IdGrupy);
						END
						ELSE
						BEGIN
							--ustawienie odpowiednich flag
							UPDATE dbo.[RolaGrupaUzytkownikow] SET
							IsValid = 0,
							IsDeleted = 1,
							DeletedBy = @UzytkownikID,
							DeletedFrom = @DataUsunieciaApp,
							ValidTo = @DataUsunieciaApp,
							RealDeletedFrom = @DataUsuniecia
							WHERE GrupaUzytkownikow = @IdGrupy AND Rola IN (SELECT IdRoli FROM #DoUsuniecia WHERE IdGrupy = @IdGrupy) AND IsValid = 1 AND IsDeleted = 0;
						END
						
						IF @@ROWCOUNT > 0
							SET @Usunieto = 1;
						
						FETCH NEXT FROM cur INTO @IdGrupy
					END
					CLOSE cur
					DEALLOCATE cur									
										
					COMMIT TRAN T1_DEL_ROLES	
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'UserGroups_DeleteAssignedRoles', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'UserGroups_DeleteAssignedRoles', @Wiadomosc = @ERRMSG OUTPUT
		END
				
	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN T1_DEL_ROLES
		END
	END CATCH
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="UserGroups_DeleteAssignedRoles"';
	
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
