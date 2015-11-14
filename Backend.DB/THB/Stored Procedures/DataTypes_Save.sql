-- =============================================
-- Author:		DK
-- Create date: 2012-03-12
-- Last modified on: 2013-02-12
-- Description:	Zapisuje dane typów cech (tabela Cecha_Typy). Aktualizuje istniejacy lub wstawia nowy rekord.

-- XML wejsciowy w postaci:

	--<Request RequestType="DataTypes_Save" UserId="1" AppDate="2012-02-09T12:45:23"
	--	xsi:noNamespaceSchemaLocation="8.2.Request.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<DataType Id="1" Name="adqwqwe" SQLName="int" UIName="Ilosc2" IsUserAttribute="true" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	--	<DataType Id="2" Name="adqwqwe2" SQLName="int" UIName="Ilosc3" IsUserAttribute="true" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	--	<DataType Id="4" Name="adqwqwe4" SQLName="bit" UIName="JestWojna" IsUserAttribute="true" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	--</Request>
	
-- XML wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="DataTypes_Save" AppDate="2012-02-09" xsi:noNamespaceSchemaLocation="8.2.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Result>
	--		<Value>
	--			<Ref Id="1" EntityType="DataType" />
	--			<Ref Id="2" EntityType="DataType" />
	--			<Ref Id="3" EntityType="DataType" />
	--		</Value>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[DataTypes_Save]
(
	@XMLDataIn nvarchar(MAX),
	@XmlDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DataProgramu datetime,
		@RequestType nvarchar(100),
		@LastModifiedOn datetime,
		@UzytkownikID int,
		@BranzaID int,
		@Id int,
		@Nazwa nvarchar(50),
		@NazwaSQL nvarchar(50),
		@NazwaUI nvarchar(50),
		@CechaUzytkownika bit,
		@StatusP int = NULL,
		@StatusS int = NULL,
		@StatusW int = NULL,
		@Index int,
		@xmlOk bit = 0,
		@xml_data xml,
		@ERRMSG nvarchar(255),
		@IsArchive bit,
		@xmlResponse xml,
		@IsStatus bit,
		@ZmianaOd datetime,
		@ZmianaDo datetime,
		@DataObowiazywaniaOd datetime,
		@DataObowiazywaniaDo datetime,
		@IsAlternativeHistory bit,
		@IsMainHistFlow bit,
		@MaUprawnienia bit = 0,
		@Commit bit = 1,
		@Query nvarchar(MAX) = '',
		@xmlErrorConcurrency nvarchar(MAX) = '',
		@xmlErrorConcurrencyXML xml,
		@xmlErrorsUnique nvarchar(MAX) = '',
		@xmlErrorsUniqueXML xml,
		@IstniejacyTypCechyId int,
		@DataModyfikacji datetime = GETDATE(),
		@DataModyfikacjiApp datetime;


		SET @ERRMSG = '';
		
		--usuwanie tabel tymczasowych, jesli istnieja
		IF OBJECT_ID('tempdb..#TypyCech') IS NOT NULL
			DROP TABLE #TypyCech
			
		IF OBJECT_ID('tempdb..#Statusy') IS NOT NULL
			DROP TABLE #Statusy
			
		IF OBJECT_ID('tempdb..#Historia') IS NOT NULL
			DROP TABLE #Historia
			
		IF OBJECT_ID('tempdb..#IDZmienionych') IS NOT NULL
			DROP TABLE #IDZmienionych
			
		IF OBJECT_ID('tempdb..#TypyCechKonfliktowe') IS NOT NULL
			DROP TABLE #TypyCechKonfliktowe
				
		IF OBJECT_ID('tempdb..#TypyCechNieUnikalne') IS NOT NULL
			DROP TABLE #TypyCechNieUnikalne
				
		CREATE TABLE #TypyCechKonfliktowe(ID int);	
		CREATE TABLE #TypyCechNieUnikalne(ID int);
			
		CREATE TABLE #IDZmienionych (ID int);
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_DataTypes_Save', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
		
		IF @xmlOk = 0
		BEGIN
			--co robic na zlej walidacji?			
			SET @ERRMSG = @ERRMSG
		END
		ELSE
		BEGIN	
			SET @xml_data = CAST(@XMLDataIn AS xml);	

			BEGIN TRY
							
			--wyciaganie daty, uzytkownika, typu zadania i nazwy slownika
			SELECT @DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
					,@UzytkownikID = C.value('./@UserId', 'int')
					,@BranzaID = C.value('./@BranchId', 'int')
					,@StatusP = C.value('./@StatusP', 'int')
					,@StatusS = C.value('./@StatusS', 'int')
					,@StatusW = C.value('./@StatusW', 'int')
			FROM @xml_data.nodes('/Request') T(C)
				
			IF @RequestType = 'DataTypes_Save'
			BEGIN
					
				-- pobranie daty modyfikacji na podstawie przekazanego AppDate
				SELECT @DataModyfikacjiApp = THB.PrepareAppDate(@DataProgramu);
			
				--odczytywanie danych typow cech			
				;WITH Num(j)
				AS
				(
				   SELECT 1
				   UNION ALL
				   SELECT j + 1
				   FROM Num
				   WHERE j < (SELECT @xml_data.value('count(/Request/DataType)','int') )
				)
				SELECT 	j AS 'Index'
					,x.value('./@Id','int') AS Id
					,x.value('./@Name', 'nvarchar(50)') AS Nazwa
					,x.value('./@SQLName', 'nvarchar(50)') AS NazwaSQL
					,x.value('./@UIName', 'nvarchar(50)') AS Nazwa_UI
					,x.value('./@IsUserAttribute', 'bit') AS CzyCechaUzytkownika
					,x.value('./@IsArchive', 'bit') AS IsArchive
					,x.value('./@ArchivedFrom', 'datetime') AS AchivedFrom
					,x.value('./@ArchivedBy', 'int') AS ArchivedBy
					,x.value('./@IsDeleted', 'bit') AS IsDeleted
					,x.value('./@DeletedFrom', 'datetime') AS DeletedFrom
					,x.value('./@DeletedBy', 'int') AS DeletedBy
					,x.value('./@CreatedOn', 'datetime') AS CreatedOn
					,x.value('./@CreatedBy', 'int') AS CreatedBy				
					,x.value('./@LastModifiedOn', 'datetime') AS LastModifiedOn
					,x.value('./@LastModifiedBy', 'int') AS LastModifiedBy
				INTO #TypyCech
				FROM Num
				CROSS APPLY @xml_data.nodes('/Request/DataType[position()=sql:column("j")]')  e(x);					
				
				;WITH Num(j)
				AS
				(
				   SELECT 1
				   UNION ALL
				   SELECT j + 1
				   FROM Num
				   WHERE j < (SELECT @xml_data.value('count(/Request/DataType)','int') )
				)
				SELECT 	j AS 'RootIndex'
					,x.value('./@ChangeFrom', 'datetime') AS ZmianaOd 
					,x.value('./@ChangeTo', 'datetime') AS ZmianaDo
					,x.value('./@EffectiveFrom', 'datetime') AS DataObowiazywaniaOd
					,x.value('./@EffectiveTo', 'datetime') AS DataObowiazywaniaDo
					,x.value('./@IsAlternativeHistory', 'bit') AS IsAlternativeHistory
					,x.value('./@IsMainHistFlow', 'bit') AS IsMainHistFlow
				INTO #Historia
				FROM Num
				CROSS APPLY @xml_data.nodes('/Request/DataType[position()=sql:column("j")]/History')  e(x);
					
				;WITH Num(j)
				AS
				(
				   SELECT 1
				   UNION ALL
				   SELECT j + 1
				   FROM Num
				   WHERE j < (SELECT @xml_data.value('count(/Request/DataType)','int') )
				)
				SELECT 	j AS 'RootIndex'
					,x.value('./@IsStatus', 'bit') AS IsStatus
					,x.value('./@StatusP', 'int') AS StatusP  
					,x.value('./@StatusPFrom', 'datetime') AS StatusPFrom 
					,x.value('./@StatusPTo', 'datetime') AS StatusPTo
					,x.value('./@StatusPFromBy', 'int') AS StatusPFromBy
					,x.value('./@StatusPToBy', 'int') AS StatusPToBy
					,x.value('./@StatusS', 'int') AS StatusS
					,x.value('./@StatusSFrom', 'datetime') AS StatusSFrom
					,x.value('./@StatusSTo', 'datetime') AS StatusSTo
					,x.value('./@StatusSFromBy', 'int') AS StatusSFromBy
					,x.value('./@StatusSToBy', 'int') AS StatusSToBy
					,x.value('./@StatusW', 'int') AS StatusW
					,x.value('./@StatusWFrom', 'datetime') AS StatusWFrom 
					,x.value('./@StatusWTo', 'datetime') AS StatusWTo
					,x.value('./@StatusWFromBy', 'int') AS StatusWFromBy
					,x.value('./@StatusWToBy', 'int') AS StatusWToBy
				INTO #Statusy
				FROM Num
				CROSS APPLY @xml_data.nodes('/Request/DataType[position()=sql:column("j")]/Statuses')  e(x);
			
				--SELECT * FROM #TypyCech;
				--SELECT * FROM #Historia
				--SELECT * FROM #Statusy

				--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji select
				EXEC [THB].[CheckUserPermission]
					@Operation = N'SAVE',
					@UserId = @UzytkownikID,
					@BranchId = @BranzaId,
					@Result = @MaUprawnienia OUTPUT
				
				IF @MaUprawnienia = 1
				BEGIN

					BEGIN TRAN T1_DataTypes_Save
					
					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','cur2') > 0 
					BEGIN
						 CLOSE cur2
						 DEALLOCATE cur2
					END
				
					DECLARE cur2 CURSOR LOCAL FOR 
						SELECT [Index], Id, Nazwa, NazwaSQL, Nazwa_UI, CzyCechaUzytkownika, LastModifiedOn FROM #TypyCech
					OPEN cur2
					FETCH NEXT FROM cur2 INTO @Index, @Id, @Nazwa, @NazwaSQL, @NazwaUI, @CechaUzytkownika, @LastModifiedOn
					WHILE @@FETCH_STATUS = 0
					BEGIN
			
						--pobranie danych historii
						SELECT @ZmianaOd = ZmianaOd, @ZmianaDo = ZmianaDo, @DataObowiazywaniaOd = DataObowiazywaniaOd,
						@DataObowiazywaniaDo = DataObowiazywaniaDo, @IsAlternativeHistory = IsAlternativeHistory, @IsMainHistFlow = IsMainHistFlow
						FROM #Historia WHERE RootIndex = @Index;	
						
						--pobranie danych statusow
						SELECT @IsStatus = IsStatus, @StatusP = StatusP, @StatusS = StatusS, @StatusW = StatusW
						FROM #Statusy WHERE RootIndex = @Index

-- pole obecnie nie uzywane		
SET @DataObowiazywaniaDo = NULL;
					
						--NazwaUI ma byc unikalna
						SET @IstniejacyTypCechyId = (SELECT TOP 1 Id FROM [Cecha_Typy] WHERE Id <> @Id AND Nazwa_UI = @NazwaUI AND IdArch IS NULL AND IsValid = 1 AND IsDeleted = 0);
						
						IF @IstniejacyTypCechyId IS NULL
						BEGIN
							--jesli typ cechy o podanym ID juz istnieje to jej aktualizacja
							IF EXISTS (SELECT Id FROM [Cecha_Typy] WHERE Id = @Id)
							BEGIN
								UPDATE [Cecha_Typy] SET
								Nazwa = @Nazwa,
								NazwaSQL = @NazwaSQL,
								Nazwa_UI = @NazwaUI,
								CzyCechaUzytkownika = @CechaUzytkownika,
								StatusP = @StatusP,								
								StatusPFrom = CASE WHEN @StatusP IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusP IS NULL THEN NULL END, 
								StatusPFromBy = CASE WHEN @StatusP IS NOT NULL THEN @UzytkownikID WHEN @StatusP IS NULL THEN NULL END,							
								StatusS = @StatusS,								
								StatusSFrom = CASE WHEN @StatusS IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusS IS NULL THEN NULL END, 
								StatusSFromBy = CASE WHEN @StatusS IS NOT NULL THEN @UzytkownikID WHEN @StatusS IS NULL THEN NULL END,								
								StatusW = @StatusW,
								StatusWFrom = CASE WHEN @StatusW IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusW IS NULL THEN NULL END, 
								StatusWFromBy = CASE WHEN @StatusW IS NOT NULL THEN @UzytkownikID WHEN @StatusW IS NULL THEN NULL END,
								IsStatus = ISNULL(@IsStatus, 0),
								LastModifiedOn = @DataModyfikacjiApp,
								RealLastModifiedOn = @DataModyfikacji,
								LastModifiedBy = @UzytkownikID,
								ObowiazujeOd = ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
								ObowiazujeDo = @DataObowiazywaniaDo
								WHERE Id = @Id AND (LastModifiedOn = @LastModifiedOn OR (LastModifiedOn IS NULL AND CreatedOn = @LastModifiedOn));
								
								IF @@ROWCOUNT > 0
								BEGIN
									INSERT INTO #IDZmienionych
									VALUES(@Id);
								END
								ELSE
								BEGIN
									--wystapil konflikt konkurencji - data ostaniej modyfikacji sie nie zgadza								
									INSERT INTO #TypyCechKonfliktowe(ID)
									VALUES(@Id);
										
									EXEC [THB].[GetErrorMessage] @Nazwa = N'CONCURRENCY_ERROR', @Grupa = N'PROC_RESULT', @Wiadomosc = @ERRMSG OUTPUT
									SET @Commit = 0;
								END
							END
							ELSE
							BEGIN
								INSERT INTO [Cecha_Typy] (Nazwa, NazwaSQL, Nazwa_UI, CzyCechaUzytkownika, IsStatus, StatusP, StatusPFrom, StatusPFromBy, StatusS, StatusSFrom, StatusSFromBy, 
								StatusW, StatusWFrom, StatusWFromBy, CreatedBy, CreatedOn, ValidFrom, IsAlternativeHistory, IsMainHistFlow, RealCreatedOn,
								ObowiazujeOd, ObowiazujeDo)
								VALUES(
									@Nazwa,
									@NazwaSQL,
									@NazwaUI,
									@CechaUzytkownika,
									ISNULL(@IsStatus, 0),															
									@StatusP, 
									CASE WHEN @StatusP IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusP IS NULL THEN NULL END, 
									CASE WHEN @StatusP IS NOT NULL THEN @UzytkownikID WHEN @StatusP IS NULL THEN NULL END, 
									@StatusS,
									CASE WHEN @StatusS IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusS IS NULL THEN NULL END,
									CASE WHEN @StatusS IS NOT NULL THEN @UzytkownikID WHEN @StatusS IS NULL THEN NULL END, 
									@StatusW, 
									CASE WHEN @StatusW IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusW IS NULL THEN NULL END,
									CASE WHEN @StatusW IS NOT NULL THEN @UzytkownikID WHEN @StatusW IS NULL THEN NULL END, 
									@UzytkownikID,
									@DataModyfikacjiApp,
									@DataModyfikacjiApp,
									0, --@IsAlternativeHistory,
									1, --@IsMainHistFlow,
									@DataModyfikacji,
									ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
									@DataObowiazywaniaDo
								);
							
								IF @@ROWCOUNT > 0
								BEGIN
									INSERT INTO #IDZmienionych
									VALUES(@@IDENTITY);
								END
							END
						END
						ELSE
						BEGIN
							--typ cechy o podanej nazwie UI juz istnieje - dodanie danych do wartosci nieunikalnych						
							INSERT INTO #TypyCechNieUnikalne(ID)
							VALUES(@IstniejacyTypCechyId);
								
							EXEC [THB].[GetErrorMessage] @Nazwa = N'RECORD_EXISTS', @Grupa = N'PROC_RESULT', @Val1 = 'Typ cechy' , @Wiadomosc = @ERRMSG OUTPUT
							SET @Commit = 0;
						END
						
						FETCH NEXT FROM cur2 INTO @Index, @Id, @Nazwa, @NazwaSQL, @NazwaUI, @CechaUzytkownika, @LastModifiedOn
					END
					CLOSE cur2
					DEALLOCATE cur2
					
					IF (SELECT COUNT(1) FROM #TypyCechKonfliktowe) > 0
					BEGIN
						SET @xmlErrorConcurrency = ISNULL(CAST((SELECT ct.[Id] AS "@Id"
							,ct.[Nazwa] AS "@Name"
							,ct.[NazwaSQL] AS "@SQLName"
							,ct.[Nazwa_UI] AS "@UIName"
							,ct.[CzyCechaUzytkownika] AS "@IsUserAttribute"
							  ,ct.[CreatedOn] AS "@CreatedOn"
							  ,ct.[CreatedBy] AS "@CreatedBy"
							  ,ISNULL(ct.[LastModifiedOn], ct.[CreatedOn]) AS "@LastModifiedOn"
							  ,ct.[LastModifiedBy] AS "@LastModifiedBy"							
							FROM [Cecha_Typy] ct
							WHERE Id IN (SELECT ID FROM #TypyCechKonfliktowe)
							FOR XML PATH('DataType')
						) AS nvarchar(MAX)), '');
					END
					
					IF (SELECT COUNT(1) FROM #TypyCechNieUnikalne) > 0
					BEGIN
						SET @xmlErrorsUnique = ISNULL(CAST((SELECT ct.[Id] AS "@Id"
							,ct.[Nazwa] AS "@Name"
							,ct.[NazwaSQL] AS "@SQLName"
							,ct.[Nazwa_UI] AS "@UIName"
							,ct.[CzyCechaUzytkownika] AS "@IsUserAttribute"
							  ,ct.[CreatedOn] AS "@CreatedOn"
							  ,ct.[CreatedBy] AS "@CreatedBy"
							  ,ISNULL(ct.[LastModifiedOn], ct.[CreatedOn]) AS "@LastModifiedOn"
							  ,ct.[LastModifiedBy] AS "@LastModifiedBy"								
						FROM [Cecha_Typy] ct
						WHERE Id IN (SELECT ID FROM #TypyCechNieUnikalne)
						FOR XML PATH('DataType')
					) AS nvarchar(MAX)), '');
					END
				
					SET @xmlResponse = (SELECT TOP 1
						(SELECT ID AS '@Id',
						'DataType' AS '@EntityType'
						FROM #IDZmienionych
						FOR XML PATH('Ref'), ROOT('Value'), TYPE
						)
					FROM #IDZmienionych
					FOR XML PATH('Result'))
					
					IF @Commit = 1
						COMMIT TRAN T1_DataTypes_Save
					ELSE
						ROLLBACK TRAN T1_DataTypes_Save;
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'DataTypes_Save', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'DataTypes_Save', @Wiadomosc = @ERRMSG OUTPUT
		
		
		END TRY
		BEGIN CATCH
			SET @ERRMSG = @@ERROR;
			SET @ERRMSG += ' ';
			SET @ERRMSG += ERROR_MESSAGE();
			
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRAN T1_DataTypes_Save
			END
			
			IF Cursor_Status('local','cur2') > 0 
			BEGIN
				 CLOSE cur2
				 DEALLOCATE cur2
			END		
		END CATCH 		
		
	END
			

	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="DataTypes_Save"';
		
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
		
	SET @XMLDataOut += '>';	
	
	IF @ERRMSG IS NULL OR @ERRMSG = '' 	
	BEGIN
		IF @xmlResponse IS NOT NULL
		BEGIN
			SET @XMLDataOut += ISNULL(CAST(@xmlResponse AS nvarchar(MAX)), '');
		END
		ELSE
			SET @XMLDataOut += '<Result><Value/></Result>';
	END
	ELSE
	BEGIN
		SET @XMLDataOut += '<Result><Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '">'

		--dodawanie danych rekordow nie zapisanych z powodu konkurencji
		IF @xmlErrorConcurrency IS NOT NULL AND LEN(@xmlErrorConcurrency) > 3
		BEGIN
			SET @XMLDataOut += '<ConcurrencyConflicts>' + @xmlErrorConcurrency + '</ConcurrencyConflicts>';
		END
		
		--dodawanie danych rekordow nie zapisanych z powodu konfliktow
		IF @xmlErrorsUnique IS NOT NULL AND LEN(@xmlErrorsUnique) > 3
		BEGIN
			SET @XMLDataOut += '<UniquenessConflicts>' + @xmlErrorsUnique + '</UniquenessConflicts>';
		END
		
		SET @XMLDataOut += '</Error></Result>';
	END
	
	SET @XMLDataOut += '</Response>';
	
	--usuwanie tabel tymczasowych, jesli istnieja
	IF OBJECT_ID('tempdb..#TypyCech') IS NOT NULL
		DROP TABLE #TypyCech
		
	IF OBJECT_ID('tempdb..#Statusy') IS NOT NULL
		DROP TABLE #Statusy
		
	IF OBJECT_ID('tempdb..#Historia') IS NOT NULL
		DROP TABLE #Historia
		
	IF OBJECT_ID('tempdb..#IDZmienionych') IS NOT NULL
		DROP TABLE #IDZmienionych
		
	IF OBJECT_ID('tempdb..#TypyCechKonfliktowe') IS NOT NULL
		DROP TABLE #TypyCechKonfliktowe
			
	IF OBJECT_ID('tempdb..#TypyCechNieUnikalne') IS NOT NULL
		DROP TABLE #TypyCechNieUnikalne 
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
END
