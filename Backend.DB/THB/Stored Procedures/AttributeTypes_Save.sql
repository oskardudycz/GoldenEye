-- =============================================
-- Author:		DK
-- Create date: 2012-06-05
-- Last modified on: 2013-02-25
-- Description:	Zapisuje dane cech (tabela Cechy, Branze_Cechy). Aktualizuje istniejacy lub wstawia nowy rekord.

-- XML wejsciowy w postaci:

	--<Request RequestType="AttributeTypes_Save" UserId="1" AppDate="2012-02-09T11:34:18">
	    
	--	<AttributeType Id="1" Name="Ilosc" ShortName="2121" Hint="2" Description="21" TypeId="1" IsDictionary="false" IsRequired="0" IsEmpty="0" IsQuantifiable="0" IsProcessed="0" IsFiltered="0" IsPersonalData="0"
	--		IsUserAttribute="0" IsTraced="false"
	--		IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--		<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false" />
	--		<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1" />
	--		<LinkedBranches>
	--			<Ref Id="3" />
	--		</LinkedBranches>
	--	</AttributeType>
	    
	--	<AttributeType Id="2" Name="Rozmiar" ShortName="2121" Hint="2" Description="21" TypeId="1" IsDictionary="true" IsRequired="0" IsEmpty="0" IsQuantifiable="0" IsProcessed="0" IsFiltered="0" IsPersonalData="0"
	--		IsUserAttribute="0" IsTraced="false"
	--		IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--		<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false" />
	--		<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1" />
	--		<LinkedBranches>
	--			<Ref Id="3" />
	--		</LinkedBranches>
	--	</AttributeType>
	    
	--</Request>
	
-- XML wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="AttributeTypes_Save" AppDate="2012-02-09Z" xsi:noNamespaceSchemaLocation="7.2.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<Result>
	--		<Value>
	--			<Ref Id="1" EntityType="AttributeType" />
	--			<Ref Id="2" EntityType="AttributeType" />
	--			<Ref Id="3" EntityType="AttributeType" />
	--		</Value>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[AttributeTypes_Save]
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
		@CechaUzytkownika bit,
		@StatusP int = NULL,
		@StatusS int = NULL,
		@StatusW int = NULL,
		@xmlOk bit = 0,
		@xml_data xml,
		@ERRMSG nvarchar(255),
		@IsArchive bit,
		@IsStatus bit,
		@ZmianaOd datetime,
		@ZmianaDo datetime,
		@DataObowiazywaniaOd datetime,
		@DataObowiazywaniaDo datetime,
		@IsAlternativeHistory bit,
		@IsMainHistFlow bit,
		@CzySlownik bit,		
		@NazwaSkrocona nvarchar(50),
		@Hint nvarchar(50),
		@Opis nvarchar(500),
		@TypID int,
		@xmlResponse xml,
		@MaUprawnienia bit = 0,
		@CzyWymagana bit = NULL,
		@CzyPusta bit,
		@CzyWyliczana bit,
		@CzyPrzetwarzana bit,
		@CzyFiltrowana bit,
		@CzyJestDanaOsobowa bit,
		@Index int,
		@Commit bit = 1,
		@Query nvarchar(MAX) = '',
		@xmlErrorConcurrency nvarchar(MAX) = '',
		@xmlErrorConcurrencyXML xml,
		@xmlErrorsUnique nvarchar(MAX) = '',
		@xmlErrorsUniqueXML xml,
		@IstniejacaCechaId int,
		@PrzetwarzajBranze bit = 0,
		@PrzetwarzanaCechaId int,
		@WartoscDomyslna nvarchar(20),
		@IdJednostkiMiary int, 
		@ControlSize int,
		@Format varchar(50),
		@ListaWartosciDopuszczalnych nvarchar(MAX),
		@DataModyfikacji datetime = GETDATE(),
		@DataModyfikacjiApp datetime,
		@PrzedzialCzasowyId int,
		@CharakterChwilowy bit,
		@Sledzona bit,
		@UnitTypeId int,
		@RelationTypeId int,
		@ZablokowanyDoEdycji bit = 0

		SET @ERRMSG = '';		
		
		--usuwanie tabel tymczasowych, jesli istnieja
		IF OBJECT_ID('tempdb..#Cechy') IS NOT NULL
			DROP TABLE #Cechy
			
		IF OBJECT_ID('tempdb..#Statusy') IS NOT NULL
			DROP TABLE #Statusy
			
		IF OBJECT_ID('tempdb..#Historia') IS NOT NULL
			DROP TABLE #Historia
			
		IF OBJECT_ID('tempdb..#TypCechy') IS NOT NULL
			DROP TABLE #TypCechy
			
		IF OBJECT_ID('tempdb..#IDZmienionych') IS NOT NULL
			DROP TABLE #IDZmienionych	
						
		IF OBJECT_ID('tempdb..#CechyKonfliktowe') IS NOT NULL
			DROP TABLE #CechyKonfliktowe
			
		IF OBJECT_ID('tempdb..#CechyNieUnikalne') IS NOT NULL
			DROP TABLE #CechyNieUnikalne
			
		IF OBJECT_ID('tempdb..#BranzeCechy') IS NOT NULL
			DROP TABLE #BranzeCechy
			
		IF OBJECT_ID('tempdb..#BranzeDoWstawienia') IS NOT NULL
			DROP TABLE #BranzeDoWstawienia
			
		IF OBJECT_ID('tempdb..#BranzeDoUsuniecia') IS NOT NULL
			DROP TABLE #BranzeDoUsuniecia
		
		CREATE TABLE #BranzeDoUsuniecia(ID int);
		CREATE TABLE #BranzeDoWstawienia(ID int);
		CREATE TABLE #CechyKonfliktowe(ID int);	
		CREATE TABLE #CechyNieUnikalne(ID int);
			
		CREATE TABLE #IDZmienionych (ID int);
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_AttributeTypes_Save', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
		
		IF @xmlOk = 0
		BEGIN			
			SET @ERRMSG = @ERRMSG
		END
		ELSE
		BEGIN
		
	BEGIN TRY
			
			SET @xml_data = CAST(@XMLDataIn AS xml);
							
			--wyciaganie daty, uzytkownika, typu zadania i nazwy slownika
			SELECT @DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
					,@UzytkownikID = C.value('./@UserId', 'int')
					,@BranzaID = C.value('./@BranchId', 'int')
					,@StatusP = C.value('./@StatusP', 'int')
					,@StatusS = C.value('./@StatusS', 'int')
					,@StatusW = C.value('./@StatusW', 'int')
			FROM @xml_data.nodes('/Request') T(C);
					
			;WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < (SELECT @xml_data.value('count(/Request/AttributeType)','int') )
			)
			SELECT j AS 'Index'
				,C.value('./@Id','int') AS Id
				,C.value('./@Name', 'nvarchar(50)') AS Nazwa
				,C.value('./@ShortName', 'nvarchar(50)') AS NazwaSkrocona				
				,C.value('./@ListOfLimitValues', 'nvarchar(MAX)') AS ListaWartosciDopuszczalnych				
				,C.value('./@Hint', 'nvarchar(200)') AS Hint
				,C.value('./@Description', 'nvarchar(500)') AS Opis
				,C.value('./@TypeId', 'int') AS TypId
				,C.value('./@IsDictionary', 'bit') AS CzySlownik
				,C.value('./@IsRequired', 'bit') AS CzyWymagana
				,C.value('./@IsEmpty', 'bit') AS CzyPusta
				,C.value('./@IsQuantifiable', 'bit') AS CzyWyliczana
				,C.value('./@IsProcessed', 'bit') AS CzyPrzetwarzana
				,C.value('./@IsFiltered', 'bit') AS CzyFiltrowana
				,C.value('./@IsPersonalData', 'bit') AS CzyJestDanaOsobowa
				,C.value('./@IsUserAttribute', 'bit') AS CzyCechaUzytkownika
				,C.value('./@IsDeleted', 'bit') AS IsDeleted
				,C.value('./@DeletedFrom', 'datetime') AS DeletedFrom
				,C.value('./@DeletedBy', 'int') AS DeletedBy
				,C.value('./@CreatedOn', 'datetime') AS CreatedOn
				,C.value('./@CreatedBy', 'int') AS CreatedBy				
				,C.value('./@LastModifiedOn', 'datetime') AS LastModifiedOn
				,C.value('./@LastModifiedBy', 'int') AS LastModifiedBy
				--,C.value('./@IsArchive', 'bit') AS IsArchive
				,C.value('./@DefaultValue', 'nvarchar(20)') AS WartoscDomyslna
				,C.value('./@ControlSize', 'int') AS ControlSize
				,C.value('./@Format', 'varchar(50)') AS Format
				,C.value('./@UnitOfMeasureId', 'int') AS JednostkaMiary
				,C.value('./@TimeIntervalId', 'int') AS PrzedzialCzasowyId
				,C.value('./@TemporaryValue', 'bit') AS CharakterChwilowy
				,C.value('./@IsTraced', 'bit') AS Sledzona
				,C.value('./@UnitTypeId', 'int') AS UnitTypeId
				,C.value('./@RelationTypeId', 'int') AS RelationTypeId						
			INTO #Cechy
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/AttributeType[position()=sql:column("j")]')  e(C);
		
			WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < (SELECT @xml_data.value('count(/Request/AttributeType)','int') )
			)
			SELECT j AS 'RootIndex'
				,C.value('./@Id', 'int') AS Id
				,C.value('./@Name', 'nvarchar(50)') AS Nazwa 
				,C.value('./@SQLName', 'nvarchar(50)') AS NazwaSQL
				,C.value('./@UIName', 'nvarchar(50)') AS DataObowiazywaniaOd
				,C.value('./@IsUserAttribute', 'bit') AS CzyCechaUzytkownika
				,C.value('./@LastModifiedOn', 'datetime') AS LastModifiedOn
			INTO #CechyObiektu
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/AttributeType[position()=sql:column("j")]/DataType') e(C);
		---
		
		-- powiazanie cech z branzami
			WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < (SELECT @xml_data.value('count(/Request/AttributeType)','int') )
			)
			SELECT j AS 'RootIndex'
				,C.value('./@Id', 'int') AS BranzaId
			INTO #BranzeCechy
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/AttributeType[position()=sql:column("j")]/LinkedBranches/Ref') e(C);	
			
			;WITH Num(i)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT i + 1
			   FROM Num
			   WHERE i < (SELECT @xml_data.value('count(/Request/AttributeType)','int') )
			)
			SELECT i AS 'RootIndex'
				,C.value('../@Id','int') AS Id
				,C.value('./@ChangeFrom', 'datetime') AS ZmianaOd 
				,C.value('./@ChangeTo', 'datetime') AS ZmianaDo
				,C.value('./@EffectiveFrom', 'datetime') AS DataObowiazywaniaOd
				,C.value('./@EffectiveTo', 'datetime') AS DataObowiazywaniaDo
				,C.value('./@IsAlternativeHistory', 'bit') AS IsAlternativeHistory
				,C.value('./@IsMainHistFlow', 'bit') AS IsMainHistFlow
			INTO #Historia
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/AttributeType[position()=sql:column("i")]/History') e(C);
			
			WITH Num(j)
			AS
			(
			   SELECT 1
			   UNION ALL
			   SELECT j + 1
			   FROM Num
			   WHERE j < (SELECT @xml_data.value('count(/Request/AttributeType)','int') )
			)
			SELECT j AS 'RootIndex'
				,C.value('../@Id','int') AS Id
				,C.value('./@IsStatus', 'bit') AS IsStatus
				,C.value('./@StatusP', 'int') AS StatusP  
				,C.value('./@StatusPFrom', 'datetime') AS StatusPFrom 
				,C.value('./@StatusPTo', 'datetime') AS StatusPTo
				,C.value('./@StatusPFromBy', 'int') AS StatusPFromBy
				,C.value('./@StatusPToBy', 'int') AS StatusPToBy
				,C.value('./@StatusS', 'int') AS StatusS
				,C.value('./@StatusSFrom', 'datetime') AS StatusSFrom
				,C.value('./@StatusSTo', 'datetime') AS StatusSTo
				,C.value('./@StatusSFromBy', 'int') AS StatusSFromBy
				,C.value('./@StatusSToBy', 'int') AS StatusSToBy
				,C.value('./@StatusW', 'int') AS StatusW
				,C.value('./@StatusWFrom', 'datetime') AS StatusWFrom 
				,C.value('./@StatusWTo', 'datetime') AS StatusWTo
				,C.value('./@StatusWFromBy', 'int') AS StatusWFromBy
				,C.value('./@StatusWToBy', 'int') AS StatusWToBy
			INTO #Statusy
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/AttributeType[position()=sql:column("j")]/Statuses') e(C);
		
			--SELECT * FROM #Cechy;
			--SELECT * FROM #Historia;
			--SELECT * FROM #TypCechy;
			--SELECT * FROM #Statusy;
			--SELECT * FROM #BranzeCechy;
		
			IF @RequestType = 'AttributeTypes_Save'
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
					BEGIN TRAN T1_AT_Save
				
					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','cur2') > 0 
					BEGIN
						 CLOSE cur2
						 DEALLOCATE cur2
					END					
			
					DECLARE cur2 CURSOR LOCAL FOR 
						SELECT [Index], Id, dbo.Trim(Nazwa), dbo.Trim(NazwaSkrocona), Hint, Opis, TypId, CzySlownik, CzyWymagana, CzyPusta, CzyWyliczana, CzyPrzetwarzana,  
						CzyFiltrowana, CzyJestDanaOsobowa, CzyCechaUzytkownika, LastModifiedOn, WartoscDomyslna, JednostkaMiary, ControlSize, Format, 
						ListaWartosciDopuszczalnych, PrzedzialCzasowyId, CharakterChwilowy, Sledzona, UnitTypeId, RelationTypeId FROM #Cechy
					OPEN cur2
					FETCH NEXT FROM cur2 INTO @Index, @Id, @Nazwa, @NazwaSkrocona, @Hint, @Opis, @TypId, @CzySlownik, @CzyWymagana, @CzyPusta, @CzyWyliczana, 
						@CzyPrzetwarzana, @CzyFiltrowana, @CzyJestDanaOsobowa, @CechaUzytkownika, @LastModifiedOn, @WartoscDomyslna, @IdJednostkiMiary, @ControlSize, @Format, 
						@ListaWartosciDopuszczalnych, @PrzedzialCzasowyId, @CharakterChwilowy, @Sledzona, @UnitTypeId, @RelationTypeId
					WHILE @@FETCH_STATUS = 0
					BEGIN
						SET @PrzetwarzajBranze = 0;
						
						--sprawdzenie czy cecha o podanej nazwie i nazwie skroconej juz istnieje
						SET @IstniejacaCechaId = (SELECT TOP 1 Cecha_ID FROM dbo.Cechy WHERE Cecha_ID <> @Id AND Nazwa = @Nazwa AND NazwaSkrocona = @NazwaSkrocona AND IdArch IS NULL AND IsValid = 1 AND IsDeleted = 0);
						
						--pobranie danych historii
						SELECT @ZmianaOd = ZmianaOd, @ZmianaDo = ZmianaDo, @DataObowiazywaniaOd = DataObowiazywaniaOd,
						@DataObowiazywaniaDo = DataObowiazywaniaDo, @IsAlternativeHistory = IsAlternativeHistory, @IsMainHistFlow = IsMainHistFlow
						FROM #Historia WHERE RootIndex = @Index 
						
						--pobranie danych statusow
						SELECT @IsStatus = IsStatus, @StatusP = StatusP, @StatusS = StatusS, @StatusW = StatusW
						FROM #Statusy WHERE RootIndex = @Index

--Pole narazie nie uzywane
SET @DataObowiazywaniaDo = NULL
SET @DataObowiazywaniaOd = @DataModyfikacjiApp

						SET @ZablokowanyDoEdycji = 0;

						IF @Id > 0
						BEGIN
							SELECT @ZablokowanyDoEdycji = IsBlocked
							FROM dbo.Cechy
							WHERE Cecha_ID = @Id;
						END
						
						--zapisujemy dane tylko jesli cecha nie hest zablokowana do edycji
						IF @ZablokowanyDoEdycji = 0
						BEGIN
				
							IF @IstniejacaCechaId IS NULL 
							BEGIN
								
								--jesli cecha o podanym ID juz istnieje to jej aktualizacja
								IF EXISTS (SELECT Cecha_ID FROM [Cechy] WHERE Cecha_ID = @Id)
								BEGIN									
									UPDATE [Cechy] SET
									Nazwa = @Nazwa,
									NazwaSkrocona = @NazwaSkrocona,
									Hint = @Hint,
									Opis = @Opis,
									TypID = @TypId,
									CzySlownik = @CzySlownik,
									CzyWymagana = @CzyWymagana,
									CzyPusta = @CzyPusta,
									Format = @Format,
									CzyWyliczana = @CzyWyliczana,
									CzyPrzetwarzana = @CzyPrzetwarzana,
									CzyFiltrowana = @CzyFiltrowana,
									CzyJestDanaOsobowa = @CzyJestDanaOsobowa,
									CzyCechaUzytkownika = @CechaUzytkownika,
									ListaWartosciDopuszczalnych = @ListaWartosciDopuszczalnych,
									UnitTypeId = @UnitTypeId, 
									RelationTypeId = @RelationTypeId,	
									WartoscDomyslna = @WartoscDomyslna, 
									ControlSize = @ControlSize, 
									JednostkaMiary = @IdJednostkiMiary,								
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
									RealLastModifiedOn = @DataModyfikacji,
									LastModifiedOn = @DataModyfikacjiApp,
									LastModifiedBy = @UzytkownikID,
									IsAlternativeHistory = @IsAlternativeHistory,
									IsMainHistFlow = @IsMainHistFlow,
									ValidFrom = @DataModyfikacjiApp,
									CharakterChwilowy = @CharakterChwilowy,
									Sledzona = @Sledzona,
									PrzedzialCzasowyId = @PrzedzialCzasowyId, 
									ObowiazujeOd = ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
									ObowiazujeDo = @DataObowiazywaniaDo
									WHERE Cecha_ID = @Id AND (LastModifiedOn = @LastModifiedOn OR (LastModifiedOn IS NULL AND CreatedOn = @LastModifiedOn));
									
									IF @@ROWCOUNT > 0
									BEGIN
										INSERT INTO #IDZmienionych
										VALUES(@Id);
										
										SET @PrzetwarzanaCechaId = @Id;
										SET @PrzetwarzajBranze = 1;
									END
									ELSE
									BEGIN
										--wystapil konflikt konkurencji - data ostaniej modyfikacji sie nie zgadza								
										INSERT INTO #CechyKonfliktowe(ID)
										VALUES(@Id);
											
										EXEC [THB].[GetErrorMessage] @Nazwa = N'CONCURRENCY_ERROR', @Grupa = N'PROC_RESULT', @Wiadomosc = @ERRMSG OUTPUT
										SET @Commit = 0;
									END
								END
								ELSE
								BEGIN
									INSERT INTO [Cechy] (Nazwa, NazwaSkrocona, Hint, Opis, TypID, CzySlownik, CzyWymagana, CzyPusta, CzyWyliczana, CzyPrzetwarzana, CzyFiltrowana,
									CzyJestDanaOsobowa, CzyCechaUzytkownika, WartoscDomyslna, ControlSize, JednostkaMiary, IsStatus, StatusP, StatusPFrom, StatusPFromBy, StatusS, StatusSFrom, StatusSFromBy, 
									StatusW, StatusWFrom, StatusWFromBy, CreatedBy, CreatedOn, IsAlternativeHistory, IsMainHistFlow, ValidFrom, Format, ListaWartosciDopuszczalnych,
									RealCreatedOn, ObowiazujeOd, ObowiazujeDo, PrzedzialCzasowyId, CharakterChwilowy, UnitTypeId, RelationTypeId, Sledzona)
									VALUES(
										@Nazwa,
										@NazwaSkrocona,
										@Hint,
										@Opis,
										@TypID,
										@CzySlownik,
										@CzyWymagana,
										@CzyPusta,
										@CzyWyliczana,
										@CzyPrzetwarzana,
										@CzyFiltrowana,
										@CzyJestDanaOsobowa,
										@CechaUzytkownika,									
										@WartoscDomyslna, 
										@ControlSize,
										@IdJednostkiMiary, 									
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
										0, --@IsAlternativeHistory,
										1, --@IsMainHistFlow,
										@DataModyfikacjiApp,
										@Format,
										@ListaWartosciDopuszczalnych,
										@DataModyfikacji,
										ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp),
										@DataObowiazywaniaDo,
										@PrzedzialCzasowyId, 
										@CharakterChwilowy,
										@UnitTypeId, 
										@RelationTypeId,
										@Sledzona
									);
							
									IF @@ROWCOUNT > 0
									BEGIN
										SET @PrzetwarzanaCechaId = @@IDENTITY;
										
										INSERT INTO #IDZmienionych
										VALUES(@PrzetwarzanaCechaId);
										
										SET @PrzetwarzajBranze = 1;
									END
								END
							END
							ELSE
							BEGIN
								--cecha o podanej nazwie i nazwie skroconej juz istnieje							
								INSERT INTO #CechyNieUnikalne(ID)
								VALUES(@IstniejacaCechaId);
									
								EXEC [THB].[GetErrorMessage] @Nazwa = N'RECORD_EXISTS', @Grupa = N'PROC_RESULT', @Val1 = 'Cecha' , @Wiadomosc = @ERRMSG OUTPUT
								SET @Commit = 0;
							END
						
							-- aktualizacja powiazania cech z branzami
							IF @PrzetwarzajBranze = 1
							BEGIN
								DELETE FROM #BranzeDoUsuniecia;
								DELETE FROM #BranzeDoWstawienia;
								
								-- pobranie Id branz do wstawienia i do usuniecia (na podstawie roznicy zbiorow)
								INSERT INTO #BranzeDoWstawienia(ID)
								SELECT BranzaId FROM #BranzeCechy WHERE RootIndex = @Index AND BranzaId NOT IN (SELECT BranzaId FROM Branze_Cechy WHERE IsValid = 1 AND IdArch IS NULL AND CechaId = @PrzetwarzanaCechaId);
							
								--INSERT INTO #BranzeDoUsuniecia(ID)
								--SELECT BranzaId FROM Branze_Cechy WHERE IsValid = 1 AND IdArch IS NULL AND CechaId = @PrzetwarzanaCechaId AND BranzaId NOT IN (SELECT BranzaId FROM #BranzeCechy WHERE RootIndex = @Index);
			    
								--wstawienie nowych powiazan cech z branzami
								INSERT INTO Branze_Cechy(BranzaId, CechaId, IsValid, CreatedOn, ValidFrom, RealCreatedOn, ObowiazujeOd, ObowiazujeDo, IsAlternativeHistory, IsMainHistFlow,
									IsStatus, StatusP, StatusPFrom, StatusPFromBy, StatusS, StatusSFrom, StatusSFromBy, StatusW, StatusWFrom, StatusWFromBy)
								SELECT bdw.Id, @PrzetwarzanaCechaId, 1, @DataModyfikacjiApp, @DataModyfikacjiApp, @DataModyfikacji, ISNULL(@DataObowiazywaniaOd, @DataModyfikacjiApp), @DataObowiazywaniaDo, 0, 1,
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
								FROM #BranzeDoWstawienia bdw
							    
								-- usuniecie branz z ktorymi cecha juz nie jest zwiazana ?? w trybie twardym czy miekkim
								--DELETE FROM Branze_Cechy
								--WHERE BranzaId IN (SELECT ID FROM #BranzeDoUsuniecia) AND CechaId = @PrzetwarzanaCechaId;
							END
						END
						ELSE
						BEGIN
							SET @ERRMSG = 'Błąd. Nie można zmienić typu cechy zablokowanej do edycji.';
							BREAK;
						END	
						
						FETCH NEXT FROM cur2 INTO @Index, @Id, @Nazwa, @NazwaSkrocona, @Hint, @Opis, @TypId, @CzySlownik, @CzyWymagana, @CzyPusta, @CzyWyliczana, 
							@CzyPrzetwarzana, @CzyFiltrowana, @CzyJestDanaOsobowa, @CechaUzytkownika, @LastModifiedOn, @WartoscDomyslna, @IdJednostkiMiary, @ControlSize, @Format, 
							@ListaWartosciDopuszczalnych, @PrzedzialCzasowyId, @CharakterChwilowy, @Sledzona, @UnitTypeId, @RelationTypeId
					END
					CLOSE cur2
					DEALLOCATE cur2
					
					IF (SELECT COUNT(1) FROM #CechyKonfliktowe) > 0
					BEGIN
						SET @xmlErrorConcurrency = ISNULL(CAST((SELECT c.[Cecha_ID] AS "@Id"
							,c.[Nazwa] AS "@Name"
							,c.[NazwaSkrocona] AS "@ShortName"
							,c.[IsBlocked] AS "@IsBlocked"
							,c.[Hint] AS "@Hint"
							,c.[Opis] AS "@Description"
							,c.[TypID] AS "@TypeId"
							,c.[CzySlownik] AS "@IsDictionary"
							,c.[CzyWymagana] AS "@IsRequired"
							,c.[CzyPusta] AS "@IsEmpty"
							,c.[CzyWyliczana] AS "@IsQuantifiable"
							,c.[CzyPrzetwarzana] AS "@IsProcessed"
							,c.[CzyFiltrowana] AS "@IsFiltered"
							,c.[CzyJestDanaOsobowa] AS "@IsPersonalData"
							,c.[CzyCechaUzytkownika] AS "@IsUserAttribute"
							,ISNULL(c.[LastModifiedOn], c.[CreatedOn]) AS "@LastModifiedOn"
							,c.[LastModifiedBy] AS "@LastModifiedBy"
							,c.[ControlSize] AS "@ControlSize"
							,c.[Format] AS "@Format"
							,c.[UnitTypeId] AS "@UnitTypeId"
							,c.[RelationTypeId] AS "@RelationTypeId"
							,c.[JednostkaMiary] AS "@UnitOfMeasureId"
							, (SELECT ct.[Id] AS "@Id"
								,ct.[Nazwa] AS "@Name"
								,ct.[NazwaSQL] AS "@SQLName"
								,ct.[Nazwa_UI] AS "@UIName"
								,ct.[CzyCechaUzytkownika] AS "@IsUserAttribute"
								,ISNULL(ct.[LastModifiedOn], ct.[CreatedOn]) AS "@LastModifiedOn"
								FROM [Cecha_Typy] ct
								WHERE ct.[Id] = c.[TypID]
								FOR XML PATH('DataType'), TYPE
								)
							FROM [Cechy] c
							WHERE Cecha_ID IN (SELECT Id FROM #CechyKonfliktowe)
							FOR XML PATH('AttributeType')
						) AS nvarchar(MAX)), '');
					END
					
					IF (SELECT COUNT(1) FROM #CechyNieUnikalne) > 0
					BEGIN
						SET @xmlErrorsUnique = ISNULL(CAST((SELECT c.[Cecha_ID] AS "@Id"
							,c.[Nazwa] AS "@Name"
							,c.[NazwaSkrocona] AS "@ShortName"
							,c.[IsBlocked] AS "@IsBlocked"
							,c.[Hint] AS "@Hint"
							,c.[Opis] AS "@Description"
							,c.[TypID] AS "@TypeId"
							,c.[CzySlownik] AS "@IsDictionary"
							,c.[CzyWymagana] AS "@IsRequired"
							,c.[CzyPusta] AS "@IsEmpty"
							,c.[CzyWyliczana] AS "@IsQuantifiable"
							,c.[CzyPrzetwarzana] AS "@IsProcessed"
							,c.[CzyFiltrowana] AS "@IsFiltered"
							,c.[CzyJestDanaOsobowa] AS "@IsPersonalData"
							,c.[CzyCechaUzytkownika] AS "@IsUserAttribute"
							,ISNULL(c.[LastModifiedOn], c.[CreatedOn]) AS "@LastModifiedOn"
							,c.[LastModifiedBy] AS "@LastModifiedBy"
							,c.[ControlSize] AS "@ControlSize"
							,c.[Format] AS "@Format"
							,c.[UnitTypeId] AS "@UnitTypeId"
							,c.[RelationTypeId] AS "@RelationTypeId"
							,c.[JednostkaMiary] AS "@UnitOfMeasureId"
							, (SELECT ct.[Id] AS "@Id"
								,ct.[Nazwa] AS "@Name"
								,ct.[NazwaSQL] AS "@SQLName"
								,ct.[Nazwa_UI] AS "@UIName"
								,ct.[CzyCechaUzytkownika] AS "@IsUserAttribute"
								,ISNULL(ct.[LastModifiedOn], ct.[CreatedOn]) AS "@LastModifiedOn"
								FROM [Cecha_Typy] ct
								WHERE ct.[Id] = c.[TypID]
								FOR XML PATH('DataType'), TYPE
								)
							FROM [Cechy] c
							WHERE Cecha_ID IN (SELECT ID FROM #CechyNieUnikalne)
							FOR XML PATH('AttributeType')
						) AS nvarchar(MAX)), '');
					END	
					
					SET @xmlResponse = (SELECT TOP 1
						(SELECT ID AS '@Id',
						'AttributeType' AS '@EntityType'
						FROM #IDZmienionych
						FOR XML PATH('Ref'), ROOT('Value'), TYPE
						)
					FROM #IDZmienionych
					FOR XML PATH('Result'))
					
					IF @Commit = 1
						COMMIT TRAN T1_AT_Save
					ELSE
						ROLLBACK TRAN T1_AT_Save
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'AttributeTypes_Save', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'AttributeTypes_Save', @Wiadomosc = @ERRMSG OUTPUT
		
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
				
				IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK TRAN T1_AT_Save
				END
				
				IF Cursor_Status('local','cur2') > 0 
				BEGIN
					 CLOSE cur2
					 DEALLOCATE cur2
				END
				
			END CATCH
		
		END 
	
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="AttributeTypes_Save"';
		
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
		
	SET @XMLDataOut += '>';
	
	
	IF @ERRMSG iS NULL OR @ERRMSG = '' 	
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
	IF OBJECT_ID('tempdb..#Cechy') IS NOT NULL
		DROP TABLE #Cechy
		
	IF OBJECT_ID('tempdb..#Statusy') IS NOT NULL
		DROP TABLE #Statusy
		
	IF OBJECT_ID('tempdb..#Historia') IS NOT NULL
		DROP TABLE #Historia
		
	IF OBJECT_ID('tempdb..#TypCechy') IS NOT NULL
		DROP TABLE #TypCechy
		
	IF OBJECT_ID('tempdb..#IDZmienionych') IS NOT NULL
		DROP TABLE #IDZmienionych
		
	IF OBJECT_ID('tempdb..#BranzeCechy') IS NOT NULL
		DROP TABLE #BranzeCechy
		
	IF OBJECT_ID('tempdb..#BranzeDoWstawienia') IS NOT NULL
		DROP TABLE #BranzeDoWstawienia
			
	IF OBJECT_ID('tempdb..#BranzeDoUsuniecia') IS NOT NULL
		DROP TABLE #BranzeDoUsuniecia
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
END

