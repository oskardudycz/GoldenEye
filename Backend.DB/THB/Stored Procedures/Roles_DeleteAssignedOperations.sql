-- =============================================
-- Author:		DK
-- Create date: 2012-07-05
-- Last modified on: 2013-02-19
-- Description:	Usuwa powiazanie - rola - operacja - branza

-- Przyjmuje XML wejsciowy w postaci:

	--<Request RequestType="Roles_DeleteAssignedOperations" UserId="1" AppDate="2012-02-09T15:23:56" IsSoftDelete="false" 
	--	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<CouplerRoleOperation RoleId="1" OperationId="2" BranchId="3" />
	--	<CouplerRoleOperation RoleId="1" OperationId="3" BranchId="3" />
	--	<CouplerRoleOperation RoleId="1" OperationId="4" BranchId="3" />
	--</Request>
	
-- Zwraca XML w postaci:

	--<Response ResponseType="Roles_DeleteAssignedOperations" AppDate="2012-02-09">
	--	<Result>
	--		<Value>true</Value>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Roles_DeleteAssignedOperations]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DataProgramu datetime,
		@RequestType nvarchar(100),
		@UzytkownikID int,
		@BranzaID int = NULL,
		@UsuwanieMiekkie bit = 1,
		@ERRMSG nvarchar(255),
		@xmlOk bit = 0,
		@xml_data xml,
		@Usunieto bit = 0,
		@MaUprawnienia bit = 0,
		@IdRoli int,
		@IdOperacji int,
		@IdBranzy int,
		@DataUsuniecia datetime = GETDATE(),
		@DataUsunieciaApp datetime

	BEGIN TRY
		SET @ERRMSG = '';
		
		--usuniecie tabel tymczasowych			
		IF OBJECT_ID('tempdb..#DoUsuniecia') IS NOT NULL
			DROP TABLE #DoUsuniecia
			
		CREATE TABLE #DoUsuniecia(IdRoli int, IdOperacji int, IdBranzy int);
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Roles_DeleteAssignedOperations', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
	
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
			INSERT INTO #DoUsuniecia (IdRoli, IdOperacji, IdBranzy)
			SELECT C.value('./@RoleId', 'int')
				, C.value('./@OperationId', 'int')
				, C.value('./@BranchId', 'int') 
			FROM @xml_data.nodes('/Request/CouplerRoleOperation') T(C)		
			
			--SELECT @DataProgramu, @RequestType, @UzytkownikID, @UsuwanieMiekkie			
			--SELECT * FROM #DoUsuniecia;

			IF @RequestType = 'Roles_DeleteAssignedOperations'
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
					BEGIN TRAN T1
					
--narazie usuwanie twarde zawsze, gdyz nie ma kolumn na flagi				
SET @UsuwanieMiekkie = 0;
			
					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','cur') > 0 
					BEGIN
						 CLOSE cur
						 DEALLOCATE cur
					END
							
					DECLARE cur CURSOR LOCAL FOR 
						SELECT IdRoli, IdOperacji, IdBranzy FROM #DoUsuniecia
					OPEN cur
					FETCH NEXT FROM cur INTO @IdRoli, @IdOperacji, @IdBranzy
					WHILE @@FETCH_STATUS = 0
					BEGIN
					
						IF @UsuwanieMiekkie = 0
						BEGIN									
							--trwale usuwanie danych z bazy							
							DELETE FROM dbo.[RolaOperacja]
							WHERE Rola = @IdRoli AND Operacja = @IdOperacji AND Branza = @IdBranzy;
						END
						--ELSE
						--BEGIN
						--	--ustawienie odpowiednich flag
						--	UPDATE dbo.[RolaOperacja] SET
						--	IsValid = 0,
						--	IsDeleted = 1,
						--	DeletedBy = @UzytkownikID,
						--	DeletedFrom = @DataUsuniecia,
						--	ValidTo = @DataUsuniecia
						--	--IsArchive = 1,
						--	--ArchivedFrom = @DataUsuniecia,
						--	--ArchivedBy = @UzytkownikID 
						--	WHERE GrupaUzytkownikow = @IdGrupy AND Rola IN (SELECT IdRoli FROM #DoUsuniecia WHERE IdGrupy = @IdGrupy) AND IsValid = 1 AND IsDeleted = 0;
						--END
						
						IF @@ROWCOUNT > 0
							SET @Usunieto = 1;
						
						FETCH NEXT FROM cur INTO @IdRoli, @IdOperacji, @IdBranzy
					END
					CLOSE cur
					DEALLOCATE cur									
										
					COMMIT TRAN T1	
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Roles_DeleteAssignedOperations', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Roles_DeleteAssignedOperations', @Wiadomosc = @ERRMSG OUTPUT
		END
				
	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN T1
		END
	END CATCH
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Roles_DeleteAssignedOperations"';
	
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
	
END
