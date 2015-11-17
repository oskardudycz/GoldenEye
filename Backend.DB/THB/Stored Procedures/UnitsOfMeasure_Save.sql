-- =============================================
-- Author:		DK
-- Create date: 2012-03-16
-- Last modified on: 2013-02-20
-- Description:	Zapisuje dane jednostek miary. Aktualizuje istniejacy lub wstawia nowy rekord.

-- XML wejsciowy w postaci:

	--<Request RequestType="UnitsOfMeasure_Save" UserId="1" AppDate="2012-02-09T11:45:23" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<UnitOfMeasure Id="1" Name="centymetr" ShortName="cm" Comment="??" IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--		<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--		<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusS="1" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="1" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="0" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1"/>
	--		<Conversions>
				--<UnitsOfMeasureConversion UOMId="1" Ratio="100" />
				--<UnitsOfMeasureConversion UOMId="6" Ratio="22.645646" />
	--		</Conversions>
	--	</UnitOfMeasure>
		
	--	<UnitOfMeasure Id="2" Name="metr" ShortName="m" Comment="??" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--		<Conversions>
				--<UnitsOfMeasureConversion UOMId="2" Ratio="100" />
				--<UnitsOfMeasureConversion UOMId="6" Ratio="22.645646" />
	--		</Conversions>
	--	</UnitOfMeasure>
	--</Request>
	
-- XML wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="UnitsOfMeasure_Save" AppDate="2012-02-09" xsi:noNamespaceSchemaLocation="10.2.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Result>
	--		<Value>
	--			<Ref Id="1" EntityType="UnitOfMeasure" />
	--			<Ref Id="2" EntityType="UnitOfMeasure" />
	--			<Ref Id="3" EntityType="UnitOfMeasure" />
	--		</Value>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[UnitsOfMeasure_Save]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @_typ nvarchar(50),
		@DataProgramu datetime,
		@RequestType nvarchar(100),
		@UzytkownikID int,
		@xmlOk bit,
		@xml_data xml,
		@BranzaID int,
		@Id int,
		@Nazwa nvarchar(200),
		@Index int,
		@IdJednostkiRef int,
		@Przelicznik float,
		@LastModifiedOn datetime,
		@Uwagi nvarchar(MAX),
		@ERRMSG nvarchar(255),
		@IsArchive bit,
		@xmlResponse xml,
		@PrzetwarzanaJednostkaId int,
		@IsAlternativeHistory bit,
		@IsMainHistFlow bit,
		@DataObowiazywaniaOd datetime,
		@DataObowiazywaniaDo datetime,
		@NazwaSkrocona nvarchar(10),
		@Skip bit = 0,
		@TypId int,
		@IsStatus bit,
		@UpdateId int,
		@MaUprawnienia bit = 0,
		@StatusP int = NULL,
		@StatusS int = NULL,
		@StatusW int = NULL,
		@Commit bit = 1,
		@Query nvarchar(MAX) = '',
		@xmlErrorConcurrency nvarchar(MAX) = '',
		@xmlErrorConcurrencyXML xml,
		@xmlErrorsUnique nvarchar(MAX) = '',
		@xmlErrorsUniqueXML xml,
		@IstniejacaJednostkaId int,
		@ZmianaOd datetime,
		@ZmianaDo datetime,
		@DataModyfikacji datetime = GETDATE(),
		@DataModyfikacjiApp datetime	

	BEGIN TRY
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_UnitsOfMeasure_Save', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
		
		IF @xmlOk = 0
		BEGIN
			--co zrobic na skutek zlej walidacji?
			SET @ERRMSG = @ERRMSG;
		END
		ELSE
		BEGIN	
			SET @xml_data = CAST(@XMLDataIn AS xml);
				
			--usuwanie tabel tymczasowych, jesli istnieja
			IF OBJECT_ID('tempdb..#JednostkiMiary') IS NOT NULL
				DROP TABLE #JednostkiMiary
				
			IF OBJECT_ID('tempdb..#Przeliczniki') IS NOT NULL
				DROP TABLE #Przeliczniki
				
			IF OBJECT_ID('tempdb..#Historia') IS NOT NULL
				DROP TABLE #Historia
			
			IF OBJECT_ID('tempdb..#Statusy') IS NOT NULL
				DROP TABLE #Statusy
				
			IF OBJECT_ID('tempdb..#IDZmienionych') IS NOT NULL
				DROP TABLE #IDZmienionych
				
			IF OBJECT_ID('tempdb..#IDZmienionychPrzelicznikow') IS NOT NULL
				DROP TABLE #IDZmienionychPrzelicznikow
				
			IF OBJECT_ID('tempdb..#JednostkiKonfliktowe') IS NOT NULL
				DROP TABLE #JednostkiKonfliktowe
				
			IF OBJECT_ID('tempdb..#JednostkiNieUnikalne') IS NOT NULL
				DROP TABLE #JednostkiNieUnikalne
				
			CREATE TABLE #JednostkiKonfliktowe(ID int);	
			CREATE TABLE #JednostkiNieUnikalne(ID int);
				
			CREATE TABLE #IDZmienionych (ID int);
			CREATE TABLE #IDZmienionychPrzelicznikow(ID int, RootID int);

			--wyciaganie daty, uzytkownika, typu zadania i nazwy slownika
			SELECT @DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
					,@UzytkownikID = C.value('./@UserId', 'int')
					,@BranzaID = C.value('./@BranchId', 'int')
			FROM @xml_data.nodes('/Request') T(C);
		
			--odczytywanie danych jendostki miary
			WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < (SELECT @xml_data.value('count(/Request/UnitOfMeasure)','int') )
			)
			SELECT 	j AS 'Index'
				   ,x.value('./@Id', 'int') AS Id
				   ,x.value('./@Name', 'nvarchar(256)') AS Nazwa
				   ,x.value('./@ShortName', 'nvarchar(10)') AS NazwaSkrocona
				   ,x.value('./@Comment', 'nvarchar(MAX)') AS Uwagi
				   ,x.value('./@IsArchive', 'bit') AS IsArchive
				   ,x.value('./@IsArchivedFrom', 'datetime') AS IsArchivedFrom
				   ,x.value('./@IsArchivedBy', 'int') AS IsArchivedBy
				   ,x.value('./@LastModifiedOn', 'datetime') AS LastModifiedOn
				   ,x.value('./@LastModifiedBy', 'int') AS LastModifiedBy
				   --,x.value('./@IsDeleted', 'bit') AS IsDeleted
				   --,x.value('./@DeletedFrom', 'datetime') AS DeletedFrom
				   --,x.value('./@DeletedBy', 'int') AS DeletedBy
				   --,x.value('./@CreatedOn', 'datetime') AS CreatedOn
				   --,x.value('./@CreatedBy', 'int') AS CreatedBy
			INTO #JednostkiMiary
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/UnitOfMeasure[position()=sql:column("j")]')  e(x);
				
			--odczytywanie danych wpisow przelicznikow dla jednostek	
			WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < (SELECT @xml_data.value('count(/Request/UnitOfMeasure)','int') )
			)
			SELECT j AS 'RootIndex'
				,x.value('./@UOMId','int') AS Id
				,x.value('./@Ratio', 'float') AS Przelicznik
				--,x.value('./@LastModifiedOn', 'datetime') AS LastModifiedOn
			INTO #Przeliczniki
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/UnitOfMeasure[position()=sql:column("j")]/Conversions/UnitsOfMeasureConversion')  e(x);
			
			--odczytywanie statusow
			WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < (SELECT @xml_data.value('count(/Request/UnitOfMeasure)','int') )
			)
			SELECT j AS 'RootIndex'
				,x.value('../@Id','int') AS Id
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
			CROSS APPLY @xml_data.nodes('/Request/UnitOfMeasure[position()=sql:column("j")]/Statuses')  e(x);
			
			--odczytywanie historii
			WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < (SELECT @xml_data.value('count(/Request/UnitOfMeasure)','int') )
			)
			SELECT j AS 'RootIndex'
				,x.value('../@Id','int') AS Id
				,x.value('./@ChangeFrom', 'datetime') AS ZmianaOd 
				,x.value('./@ChangeTo', 'datetime') AS ZmianaDo
				,x.value('./@EffectiveFrom', 'datetime') AS DataObowiazywaniaOd
				,x.value('./@EffectiveTo', 'datetime') AS DataObowiazywaniaDo
				,x.value('./@IsAlternativeHistory', 'bit') AS IsAlternativeHistory
				,x.value('./@IsMainHistFlow', 'bit') AS IsMainHistFlow
			INTO #Historia 
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/UnitOfMeasure[position()=sql:column("j")]/History')  e(x);			
			
			--SELECT * FROM #JednostkiMiary;
			--SELECT * FROM #Przeliczniki;
			--SELECT * FROM #Statusy;
			--SELECT * FROM #Historia;
			--SELECT @DataProgramu, @UzytkownikID, @RequestType

			IF @RequestType = 'UnitsOfMeasure_Save'
			BEGIN 
				
				-- pobranie daty modyfikacji na podstawie przekazanego AppDate
				SELECT @DataModyfikacjiApp = THB.PrepareAppDate(@DataProgramu);
				
				--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji select
				EXEC [THB].[CheckUserPermission]
					@Operation = N'SAVE',
					@UserId = @UzytkownikID,
					@BranchId = @BranzaId,
					@Result = @MaUprawnienia OUTPUT
				
				IF @MaUprawnienia = 1
				BEGIN
				
					BEGIN TRAN T1
					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','cur') > 0 
					BEGIN
						 CLOSE cur
						 DEALLOCATE cur
					END
					
					DECLARE cur CURSOR LOCAL FOR 
						SELECT [Index], Id, Nazwa, NazwaSkrocona, Uwagi, LastModifiedOn FROM #JednostkiMiary
					OPEN cur
					FETCH NEXT FROM cur INTO @Index, @Id, @Nazwa, @NazwaSkrocona, @Uwagi, @LastModifiedOn
					WHILE @@FETCH_STATUS = 0
					BEGIN
						SET @Skip = 0;
						SET @IstniejacaJednostkaId = (SELECT Id FROM dbo.[JednostkiMiary] WHERE Id <> @Id AND Nazwa = @Nazwa AND NazwaSkrocona = @NazwaSkrocona AND IdArch IS NULL AND IsValid = 1 AND IsDeleted = 0);
						
						--pobranie danych historii
						SELECT @ZmianaOd = ZmianaOd, @ZmianaDo = ZmianaDo, @DataObowiazywaniaOd = DataObowiazywaniaOd,
						@DataObowiazywaniaDo = DataObowiazywaniaDo, @IsAlternativeHistory = IsAlternativeHistory, @IsMainHistFlow = IsMainHistFlow
						FROM #Historia WHERE RootIndex = @Index 	
						
						--pobranie danych statusow
						SELECT @IsStatus = IsStatus, @StatusP = StatusP, @StatusS = StatusS, @StatusW = StatusW
						FROM #Statusy WHERE RootIndex = @Index 

--narazie tu tylko NULL
SET @DataObowiazywaniaDo = NULL;
						
						--sprawdzenie czy jednostka o podanej nazwie i nazwie skrocone juz istnieje
						IF @IstniejacaJednostkaId IS NULL
						BEGIN
							IF EXISTS (SELECT Id FROM dbo.[JednostkiMiary] WHERE Id = @Id)
							BEGIN
								--aktualizacja danych slownika
								UPDATE dbo.[JednostkiMiary] SET
								Nazwa = @Nazwa,
								NazwaSkrocona = @NazwaSkrocona,
								Uwagi = @Uwagi,
								LastModifiedOn = @DataModyfikacjiApp,
								RealLastModifiedOn = @DataModyfikacji,
								LastModifiedBy = @UzytkownikId,
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
								ValidFrom = @DataModyfikacjiApp,
								ObowiazujeOd = ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
								ObowiazujeDo = @DataObowiazywaniaDo
								WHERE Id = @Id AND (LastModifiedOn = @LastModifiedOn OR (LastModifiedOn IS NULL AND CreatedOn = @LastModifiedOn));
								
								IF @@ROWCOUNT > 0
								BEGIN
									SET @PrzetwarzanaJednostkaId = @Id;
									INSERT INTO #IDZmienionych (ID) VALUES(@PrzetwarzanaJednostkaId);
								END
								ELSE
								BEGIN
									--konflikt konkurencyjnosci
									INSERT INTO #JednostkiKonfliktowe(ID)
									VALUES(@Id);
									
									EXEC [THB].[GetErrorMessage] @Nazwa = N'CONCURRENCY_ERROR', @Grupa = N'PROC_RESULT', @Wiadomosc = @ERRMSG OUTPUT
									SET @Commit = 0;
									SET @Skip = 1;
								END
							END
							ELSE
							BEGIN						
								--wstawienie nowej jednostki o ile juz taki nie istnieje
								INSERT INTO dbo.[JednostkiMiary] (Nazwa, NazwaSkrocona, Uwagi, CreatedBy, CreatedOn, ValidFrom, IsStatus, StatusP, 
								StatusPFrom, StatusPFromBy, StatusS, StatusSFrom, StatusSFromBy, 
								StatusW, StatusWFrom, StatusWFromBy, RealCreatedOn, ObowiazujeOd, ObowiazujeDo) 
								VALUES (@Nazwa, @NazwaSkrocona, @Uwagi, @UzytkownikId, @DataModyfikacjiApp, @DataModyfikacjiApp,
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
									@DataModyfikacji,
									ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
									@DataObowiazywaniaDo
								);
								
								IF @@ROWCOUNT > 0
								BEGIN
									SET @PrzetwarzanaJednostkaId = @@IDENTITY;
									INSERT INTO #IDZmienionych (ID) VALUES(@PrzetwarzanaJednostkaId);
								END
								ELSE
								BEGIN
									SET @Skip = 1;
								END
							END
				
							--przetwarzanie danych przelicznikow dla jednostki
							IF @Skip = 0
							BEGIN
								--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
								IF Cursor_Status('local', 'cur2') > 0 
								BEGIN
									 CLOSE cur2
									 DEALLOCATE cur2
								END

								DECLARE cur2 CURSOR LOCAL FOR 
									SELECT Id, Przelicznik FROM #Przeliczniki WHERE RootIndex = @Index
								OPEN cur2
								FETCH NEXT FROM cur2 INTO @IdJednostkiRef, @Przelicznik
								WHILE @@FETCH_STATUS = 0
								BEGIN
								
--narazie tu tylko NULL
SET @DataObowiazywaniaDo = NULL;						

									SELECT @UpdateId = Id FROM [JednostkiMiary_Przeliczniki] WHERE IdFrom = @Id AND IdTo = @IdJednostkiRef AND IdArch IS NULL AND IsValid = 1;

									IF @UpdateId IS NOT NULL 
									BEGIN
										UPDATE [JednostkiMiary_Przeliczniki] SET
										Przelicznik = @Przelicznik,
										LastModifiedBy = @UzytkownikId,
										LastModifiedOn = @DataModyfikacjiApp,
										ValidFrom = @DataModyfikacjiApp,
										RealLastModifiedOn = @DataModyfikacji,
										ObowiazujeOd = ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
										ObowiazujeDo = @DataObowiazywaniaDo,
										StatusP = @StatusP,								
										StatusPFrom = CASE WHEN @StatusP IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusP IS NULL THEN NULL END, 
										StatusPFromBy = CASE WHEN @StatusP IS NOT NULL THEN @UzytkownikID WHEN @StatusP IS NULL THEN NULL END,							
										StatusS = @StatusS,								
										StatusSFrom = CASE WHEN @StatusS IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusS IS NULL THEN NULL END, 
										StatusSFromBy = CASE WHEN @StatusS IS NOT NULL THEN @UzytkownikID WHEN @StatusS IS NULL THEN NULL END,								
										StatusW = @StatusW,
										StatusWFrom = CASE WHEN @StatusW IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusW IS NULL THEN NULL END, 
										StatusWFromBy = CASE WHEN @StatusW IS NOT NULL THEN @UzytkownikID WHEN @StatusW IS NULL THEN NULL END,
										IsStatus = ISNULL(@IsStatus, 0)
										WHERE Id = @UpdateId;
										
										IF @@ROWCOUNT > 0
										BEGIN
											INSERT INTO #IDZmienionychPrzelicznikow (Id, RootId) VALUES(@IdJednostkiRef, @PrzetwarzanaJednostkaId);
										END
									END
									ELSE
									BEGIN								
										INSERT INTO [JednostkiMiary_Przeliczniki] (IdFrom, IdTo, Przelicznik, CreatedBy, CreatedOn, ValidFrom, RealCreatedOn,
											ObowiazujeOd, ObowiazujeDo, IsStatus, StatusP, StatusPFrom, StatusPFromBy, StatusS, StatusSFrom, StatusSFromBy, 
											StatusW, StatusWFrom, StatusWFromBy)
										VALUES (@PrzetwarzanaJednostkaId, @IdJednostkiRef, @Przelicznik, @UzytkownikId, @DataModyfikacjiApp, @DataModyfikacjiApp, @DataModyfikacji,
											ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp), @DataObowiazywaniaDo,
											ISNULL(@IsStatus, 0),							
											@StatusP, 
											CASE WHEN @StatusP IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusP IS NULL THEN NULL END, 
											CASE WHEN @StatusP IS NOT NULL THEN @UzytkownikID WHEN @StatusP IS NULL THEN NULL END, 
											@StatusS,
											CASE WHEN @StatusS IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusS IS NULL THEN NULL END,
											CASE WHEN @StatusS IS NOT NULL THEN @UzytkownikID WHEN @StatusS IS NULL THEN NULL END, 
											@StatusW, 
											CASE WHEN @StatusW IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusW IS NULL THEN NULL END,
											CASE WHEN @StatusW IS NOT NULL THEN @UzytkownikID WHEN @StatusW IS NULL THEN NULL END);
											
										IF @@ROWCOUNT > 0
										BEGIN
											INSERT INTO #IDZmienionychPrzelicznikow (Id, RootId) VALUES(@@IDENTITY, @PrzetwarzanaJednostkaId);
										END									
									END
								
									--sprawdzenie czy istnieje wpis konwersji w 'druga strone' i jego ew dodanie/modyfikacja
									SELECT @UpdateId = Id FROM [JednostkiMiary_Przeliczniki] WHERE IdFrom = @IdJednostkiRef AND IdTo = @Id AND IdArch IS NULL AND IsValid = 1;
									
									IF @UpdateId IS NOT NULL
									BEGIN
										UPDATE [JednostkiMiary_Przeliczniki] SET
										Przelicznik = 1.0/@Przelicznik,
										LastModifiedBy = @UzytkownikId,
										LastModifiedOn = @DataModyfikacjiApp,
										ValidFrom = @DataModyfikacjiApp,
										RealLastModifiedOn = @DataModyfikacji,
										ObowiazujeOd = ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
										ObowiazujeDo = @DataObowiazywaniaDo,
										StatusP = @StatusP,								
										StatusPFrom = CASE WHEN @StatusP IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusP IS NULL THEN NULL END, 
										StatusPFromBy = CASE WHEN @StatusP IS NOT NULL THEN @UzytkownikID WHEN @StatusP IS NULL THEN NULL END,							
										StatusS = @StatusS,								
										StatusSFrom = CASE WHEN @StatusS IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusS IS NULL THEN NULL END, 
										StatusSFromBy = CASE WHEN @StatusS IS NOT NULL THEN @UzytkownikID WHEN @StatusS IS NULL THEN NULL END,								
										StatusW = @StatusW,
										StatusWFrom = CASE WHEN @StatusW IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusW IS NULL THEN NULL END, 
										StatusWFromBy = CASE WHEN @StatusW IS NOT NULL THEN @UzytkownikID WHEN @StatusW IS NULL THEN NULL END,
										IsStatus = ISNULL(@IsStatus, 0)
										WHERE Id = @UpdateId
										
										IF @@ROWCOUNT > 0
										BEGIN
											INSERT INTO #IDZmienionychPrzelicznikow (Id, RootId) VALUES(@IdJednostkiRef, @PrzetwarzanaJednostkaId);
										END
									END
									ELSE
									BEGIN								
										INSERT INTO [JednostkiMiary_Przeliczniki] (IdFrom, IdTo, Przelicznik, CreatedBy, CreatedOn, ValidFrom, RealCreatedOn,
										ObowiazujeOd, ObowiazujeDo, IsStatus, StatusP, StatusPFrom, StatusPFromBy, StatusS, StatusSFrom, StatusSFromBy, 
											StatusW, StatusWFrom, StatusWFromBy)
										VALUES (@IdJednostkiRef, @PrzetwarzanaJednostkaId, 1.0/@Przelicznik, @UzytkownikId, @DataModyfikacjiApp, @DataModyfikacjiApp, @DataModyfikacji,
										ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp), @DataObowiazywaniaDo,
										ISNULL(@IsStatus, 0),						
										@StatusP, 
										CASE WHEN @StatusP IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusP IS NULL THEN NULL END, 
										CASE WHEN @StatusP IS NOT NULL THEN @UzytkownikID WHEN @StatusP IS NULL THEN NULL END, 
										@StatusS,
										CASE WHEN @StatusS IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusS IS NULL THEN NULL END,
										CASE WHEN @StatusS IS NOT NULL THEN @UzytkownikID WHEN @StatusS IS NULL THEN NULL END, 
										@StatusW, 
										CASE WHEN @StatusW IS NOT NULL THEN @DataModyfikacjiApp WHEN @StatusW IS NULL THEN NULL END,
										CASE WHEN @StatusW IS NOT NULL THEN @UzytkownikID WHEN @StatusW IS NULL THEN NULL END
										);
										
										IF @@ROWCOUNT > 0
										BEGIN
											INSERT INTO #IDZmienionychPrzelicznikow (Id, RootId) VALUES(@@IDENTITY, @PrzetwarzanaJednostkaId);
										END									
									END							
								
									FETCH NEXT FROM cur2 INTO @IdJednostkiRef, @Przelicznik
								END
								CLOSE cur2
								DEALLOCATE cur2
							END
						END
						ELSE
						BEGIN
							-- jendostka miary o podanych danych juz istnieje, dodanie jego ID do tabeli tymczasowej
							INSERT INTO #JednostkiNieUnikalne(ID)
							VALUES(@IstniejacaJednostkaId);
							
							EXEC [THB].[GetErrorMessage] @Nazwa = N'RECORD_EXISTS', @Grupa = N'PROC_RESULT', @Val1 = 'Jednostka miary' , @Wiadomosc = @ERRMSG OUTPUT
							SET @Commit = 0;
						END
						
						FETCH NEXT FROM cur INTO @Index, @Id, @Nazwa, @NazwaSkrocona, @Uwagi, @LastModifiedOn
					
					END
					CLOSE cur
					DEALLOCATE cur
					
					--SELECT * FROM #IDZmienionych
					--SELECT * FROM #IDZmienionychPrzelicznikow
					
					IF (SELECT COUNT(1) FROM #JednostkiKonfliktowe) > 0
					BEGIN
						SET @xmlErrorConcurrency = ISNULL(CAST((SELECT jm.[Id] AS "@Id"
									  ,jm.[Nazwa] AS "@Name"
									  ,jm.[NazwaSkrocona] AS "@ShortName"
									  ,jm.[Uwagi] AS "@Comment"
									  ,jm.[IsDeleted] AS "@IsDeleted"
									  ,jm.[DeletedFrom] AS "@DeletedFrom"
									  ,jm.[DeletedBy] AS "@DeletedBy"
									  ,jm.[CreatedOn] AS "@CreatedOn"
									  ,jm.[CreatedBy] AS "@CreatedBy"
									  ,ISNULL(jm.[LastModifiedOn], jm.[CreatedOn]) AS "@LastModifiedOn"
									  ,jm.[LastModifiedBy] AS "@LastModifiedBy"
									  ,jm.[IsStatus] AS "Statuses/@IsStatus"
									  ,jm.[StatusS] AS "Statuses/@StatusS"
									  ,jm.[StatusSFrom] AS "Statuses/@StatusSFrom"
									  ,jm.[StatusSTo] AS "Statuses/@StatusSTo"
									  ,jm.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
									  ,jm.[StatusSToBy] AS "Statuses/@StatusSToBy"
									  ,jm.[StatusW] AS "Statuses/@StatusW"
									  ,jm.[StatusWFrom] AS "Statuses/@StatusWFrom"
									  ,jm.[StatusWTo] AS "Statuses/@StatusWTo"
									  ,jm.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
									  ,jm.[StatusWToBy] AS "Statuses/@StatusWToBy"
									  ,jm.[StatusP] AS "Statuses/@StatusP"
									  ,jm.[StatusPFrom] AS "Statuses/@StatusPFrom"
									  ,jm.[StatusPTo] AS "Statuses/@StatusPTo"
									  ,jm.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
									  ,jm.[StatusPToBy] AS "Statuses/@StatusPToBy"
									  ,jm.[ObowiazujeOd] AS "History/@EffectiveFrom"
									  ,jm.[ObowiazujeDo] AS "History/@EffectiveTo"
									  , (SELECT jmp.[IdTo] AS "@UOMId"
												,jmp.[Przelicznik] AS "@Ratio"
												FROM [JednostkiMiary_Przeliczniki] jmp
												WHERE jmp.[IdFrom] = jm.[Id] AND jmp.IdArch IS NULL
												FOR XML PATH('UnitsOfMeasureConversion'), ROOT('Conversions'), TYPE
												)							
							FROM [JednostkiMiary] jm
							WHERE Id IN (SELECT ID FROM #JednostkiKonfliktowe)
							FOR XML PATH('UnitOfMeasure')
						) AS nvarchar(MAX)), '');
					END
					
					IF (SELECT COUNT(1) FROM #JednostkiNieUnikalne) > 0
					BEGIN
						SET @xmlErrorsUnique = ISNULL(CAST((SELECT jm.[Id] AS "@Id"
									  ,jm.[Nazwa] AS "@Name"
									  ,jm.[NazwaSkrocona] AS "@ShortName"
									  ,jm.[Uwagi] AS "@Comment"
									  ,jm.[IsDeleted] AS "@IsDeleted"
									  ,jm.[DeletedFrom] AS "@DeletedFrom"
									  ,jm.[DeletedBy] AS "@DeletedBy"
									  ,jm.[CreatedOn] AS "@CreatedOn"
									  ,jm.[CreatedBy] AS "@CreatedBy"
									  ,ISNULL(jm.[LastModifiedOn], jm.[CreatedOn]) AS "@LastModifiedOn"
									  ,jm.[LastModifiedBy] AS "@LastModifiedBy"
									  ,jm.[IsStatus] AS "Statuses/@IsStatus"
									  ,jm.[StatusS] AS "Statuses/@StatusS"
									  ,jm.[StatusSFrom] AS "Statuses/@StatusSFrom"
									  ,jm.[StatusSTo] AS "Statuses/@StatusSTo"
									  ,jm.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
									  ,jm.[StatusSToBy] AS "Statuses/@StatusSToBy"
									  ,jm.[StatusW] AS "Statuses/@StatusW"
									  ,jm.[StatusWFrom] AS "Statuses/@StatusWFrom"
									  ,jm.[StatusWTo] AS "Statuses/@StatusWTo"
									  ,jm.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
									  ,jm.[StatusWToBy] AS "Statuses/@StatusWToBy"
									  ,jm.[StatusP] AS "Statuses/@StatusP"
									  ,jm.[StatusPFrom] AS "Statuses/@StatusPFrom"
									  ,jm.[StatusPTo] AS "Statuses/@StatusPTo"
									  ,jm.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
									  ,jm.[StatusPToBy] AS "Statuses/@StatusPToBy"
									  ,jm.[ObowiazujeOd] AS "History/@EffectiveFrom"
									  ,jm.[ObowiazujeDo] AS "History/@EffectiveTo"
									  , (SELECT jmp.[IdTo] AS "@UOMId"
												,jmp.[Przelicznik] AS "@Ratio"
												FROM [JednostkiMiary_Przeliczniki] jmp
												WHERE jmp.[IdFrom] = jm.[Id] AND jmp.IdArch IS NULL
												FOR XML PATH('UnitsOfMeasureConversion'), ROOT('Conversions'), TYPE
												)							
										FROM [JednostkiMiary] jm
										WHERE Id IN (SELECT ID FROM #JednostkiNieUnikalne)
										FOR XML PATH('UnitOfMeasure')
									) AS nvarchar(MAX)), '');
					END
					
					SET @xmlResponse = (
							SELECT TOP 1 NULL AS '@Ids'
							, (
								SELECT Id AS '@Id'
								,'UnitOfMeasure' AS '@EntityType'
								FROM #IDZmienionych
								FOR XML PATH('Ref'), ROOT('Value'), TYPE
								)
							FROM #IDZmienionych
							FOR XML PATH('Result')
							)
	
					IF @Commit = 1
						COMMIT TRAN T1;
					ELSE
						ROLLBACK TRAN T1;
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'UnitsOfMeasure_Save', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'UnitsOfMeasure_Save', @Wiadomosc = @ERRMSG OUTPUT
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
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="UnitsOfMeasure_Save"';
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';

	SET @XMLDataOut += '>';
	
	IF @ERRMSG iS NULL OR @ERRMSG = '' 	
	BEGIN
		IF (SELECT COUNT(1) FROM #IdZmienionych) > 0
			SET @XMLDataOut += ISNULL(CAST(@xmlResponse AS nvarchar(MAX)), '');
		ELSE
			SET @XMLDataOut += '<Result><Value/></Result>';
	END
	ELSE
	BEGIN
		SET @XMLDataOut += '<Result><Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '">'

		IF @xmlErrorConcurrency IS NOT NULL AND LEN(@xmlErrorConcurrency) > 3
			SET @XMLDataOut += '<ConcurrencyConflicts>' + @xmlErrorConcurrency + '</ConcurrencyConflicts>';

		IF @xmlErrorsUnique IS NOT NULL AND LEN(@xmlErrorsUnique) > 3
			SET @XMLDataOut += '<UniquenessConflicts>' + @xmlErrorsUnique + '</UniquenessConflicts>';
		
		SET @XMLDataOut += '</Error></Result>';
	END	

	SET @XMLDataOut += '</Response>';	
	
	--usuwanie tabel tymczasowych, jesli istnieja
	IF OBJECT_ID('tempdb..#JednostkiMiary') IS NOT NULL
		DROP TABLE #JednostkiMiary
		
	IF OBJECT_ID('tempdb..#Przeliczniki') IS NOT NULL
		DROP TABLE #Przeliczniki
		
	IF OBJECT_ID('tempdb..#Historia') IS NOT NULL
		DROP TABLE #Historia
	
	IF OBJECT_ID('tempdb..#Statusy') IS NOT NULL
		DROP TABLE #Statusy
		
	IF OBJECT_ID('tempdb..#IDZmienionych') IS NOT NULL
		DROP TABLE #IDZmienionych
		
	IF OBJECT_ID('tempdb..#IDZmienionychPrzelicznikow') IS NOT NULL
		DROP TABLE #IDZmienionychPrzelicznikow
		
	IF OBJECT_ID('tempdb..#JednostkiKonfliktowe') IS NOT NULL
		DROP TABLE #JednostkiKonfliktowe
		
	IF OBJECT_ID('tempdb..#JednostkiNieUnikalne') IS NOT NULL
		DROP TABLE #JednostkiNieUnikalne
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
END
