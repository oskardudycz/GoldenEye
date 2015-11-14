-- =============================================
-- Author:		DK
-- Create date: 2012-04-04
-- Last modified on: 2013-02-18
-- Description:	Zwraca historie cech dla obiektow, relacji o podanych ID (dowolnego typu) wraz z cechami.
-- Wynik zwrocony do interfejsu w formie XML'a

-- XML wejsciowy:

	--<Request RequestType="Attributes_GetHistory" UserId="1" AppDate="2012-02-09T11:23:11" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<ObjectRef Id="1" TypeId="4" EntityType="Relation" />
	--	<ObjectRef Id="8" TypeId="78" EntityType="Unit" />
	--</Request>

-- XML wyjsciowy:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="Units_GetHistory" AppDate="2012-02-09Z" xsi:noNamespaceSchemaLocation="16.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

	--<!-- 
	--	ATTRYBUTY:
	--	 <Request .. GetFullColumnsData="true" ..  ExpandNestedValues="true" ../>	 
	--	 NIE MAJA ZNACZENIA
	-- -->
	 
	-- <HistoryOfAttribute Id="1" TypeId="20" EntityType="Relation">
	 	
	--	 <Attribute Id="1" TypeId="12" Priority="1" UIOrder="2"
	--			IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--			<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false" />
	--			<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1" />
	--			<ValDictionary Id="12">
	--				15
	--				<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsMainHistFlow="false" />                
	--			</ValDictionary>
	--		</Attribute>
	--		<Attribute Id="2" TypeId="45" Priority="0" UIOrder="1"
	--			IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--			<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false" />
	--			<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1" />
	--			<ValDecimal>
	--				45.89
	--				<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsMainHistFlow="false" />
	--			</ValDecimal>
	--		</Attribute>
	--		<Attribute Id="1" TypeId="12" Priority="1" UIOrder="2"
	--			IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--			<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false" />
	--			<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1" />
	--			<ValDictionary Id="12">
	--				15
	--				<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsMainHistFlow="false" />                
	--			</ValDictionary>
	--		</Attribute>
	--		<Attribute Id="2" TypeId="45" Priority="0" UIOrder="1"
	--			IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--			<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false" />
	--			<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1" />
	--			<ValDecimal>
	--				45.89
	--				<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsMainHistFlow="false" />
	--			</ValDecimal>
	--		</Attribute>	    
	-- </HistoryOfAttribute>	 
	 
	-- <HistoryOfAttribute Id="1" TypeId="20" EntityType="Unit"> 	
	--		<Attribute Id="1" TypeId="12" Priority="1" UIOrder="2"
	--			IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--			<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false" />
	--			<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1" />
	--			<ValDictionary Id="12">
	--				15
	--				<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsMainHistFlow="false" />                
	--			</ValDictionary>
	--		</Attribute>
	--		<Attribute Id="2" TypeId="45" Priority="0" UIOrder="1"
	--			IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--			<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false" />
	--			<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1" />
	--			<ValDecimal>
	--				45.89
	--				<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsMainHistFlow="false" />
	--			</ValDecimal>
	--		</Attribute>
	--		<Attribute Id="2" TypeId="45" Priority="0" UIOrder="1"
	--			IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--			<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false" />
	--			<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1" />
	--			<ValDecimal>
	--				45.89
	--				<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsMainHistFlow="false" />
	--			</ValDecimal>
	--		</Attribute>	    
	-- </HistoryOfAttribute> 
	--</Response>


-- =============================================
CREATE PROCEDURE [THB].[Attributes_GetHistory]
(	
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN

	DECLARE @Query nvarchar(max) = '',
		@tableName nvarchar(256),
		@RequestType nvarchar(100),
		@xml_data xml,
		@xmlOk bit = 0,
		@xmlOut xml,
		@StatusS int,
		@StatusP int,
		@StatusW int,
		@DataProgramu datetime,
		@UzytkownikID int = NULL,
		@BranzaID int,
		@xmlVar nvarchar(MAX) = '',
		@TypObiektuId int,
		@ObiektId int,
		@MaUprawnienia bit = 0,
		@ERRMSG nvarchar(255),
		@RozwijajPodwezly bit = 0,
		@PobierzWszystieDane bit = 0,
		@CzySlownik bit,
		@XmlSparse xml,
		@CechaTyp varchar(30),
		@CechaTypId int,
		@WartoscString nvarchar(MAX),
		@CechaWartosc nvarchar(200),
		@CechaObiektuId int,
		@CechaId int,
		@CechaHasAlternativeHistory bit = 0,
		@RelacjaId int,
		@TypRelacjiId int,
		@IdCechy int,
		@IdCechyZHistorii int,
		@AppDate datetime,
		@CzyTabela bit,
		@UnitTypeColumns nvarchar(2000),
		@TypKolumny varchar(100),
		@NazwaKolumny nvarchar(150),
		@CechaIdKolumny int,
		@CzyTabelaCounter int = 0,
		@ObiektIdDlaCechy int,
		@WartoscCechy nvarchar(MAX),
		@WartoscCechyString nvarchar(MAX),
		@WartoscCechyXml nvarchar(MAX)
	
	--usuwanie tabel tymczasowych, jesli istnieja		
	IF OBJECT_ID('tempdb..#Obiekty') IS NOT NULL
		DROP TABLE #Obiekty
		
	IF OBJECT_ID('tempdb..#Relacje') IS NOT NULL
		DROP TABLE #Relacje
		
	IF OBJECT_ID('tempdb..#CechyObiektu') IS NOT NULL
		DROP TABLE #CechyObiektu
		
	IF OBJECT_ID('tempdb..#CechyRelacji') IS NOT NULL
		DROP TABLE #CechyRelacji
		
	IF OBJECT_ID('tempdb..#DaneCech') IS NOT NULL
		DROP TABLE #DaneCech
		
	IF OBJECT_ID('tempdb..#DoPobrania') IS NOT NULL
		DROP TABLE #DoPobrania
		
	IF OBJECT_ID('tempdb..#KolumnyTypuObiektu') IS NOT NULL
		DROP TABLE #KolumnyTypuObiektu
	
	CREATE TABLE #KolumnyTypuObiektu(CechaId int, NazwaKolumny nvarchar(150), TypKolumny varchar(50));
	CREATE TABLE #DoPobrania(Id int, TypId int, EntityType varchar(30), CechaId int);
	CREATE TABLE #Obiekty(Id int, TypObiektuId int, CechaId int);
	CREATE TABLE #Relacje(Id int, TypRelacjiId int, CechaId int);
	
	CREATE TABLE #DaneCech(TypObiektuId int, ObiektId int, Id int, CechaId int, TypCechyId int, IdArch int, CzySlownik bit, SparceValue xml, ValString nvarchar(MAX), [IsStatus] bit,[StatusS] int,[StatusSFrom] datetime,[StatusSTo] datetime,
		[StatusSFromBy] int,[StatusSToBy] int,[StatusW] int,[StatusWFrom] datetime,[StatusWTo] datetime,[StatusWFromBy] int,[StatusWToBy] int,[StatusP] int,[StatusPFrom] datetime,
		[StatusPTo] datetime,[StatusPFromBy] int,[StatusPToBy] int,[ObowiazujeOd] datetime,[ObowiazujeDo] datetime,[IsValid] bit,
		[ValidFrom] datetime,[ValidTo] datetime,[IsDeleted] bit,[DeletedFrom] datetime,[DeletedBy] int,[CreatedOn] datetime,
		[CreatedBy] int,[LastModifiedOn] datetime,[LastModifiedBy] int,[Priority] smallint,[UIOrder] smallint,[IsAlternativeHistory] bit,[IsMainHistFlow] bit);
	
	CREATE TABLE #CechyObiektu(TypObiektuId int, ObiektId int, Id int, CechaId int, TypCechyId int, IdArch int, CzySlownik bit, SparceValue xml, ValString nvarchar(MAX), [IsStatus] bit,[StatusS] int,[StatusSFrom] datetime,[StatusSTo] datetime,
		[StatusSFromBy] int,[StatusSToBy] int,[StatusW] int,[StatusWFrom] datetime,[StatusWTo] datetime,[StatusWFromBy] int,[StatusWToBy] int,[StatusP] int,[StatusPFrom] datetime,
		[StatusPTo] datetime,[StatusPFromBy] int,[StatusPToBy] int,[ObowiazujeOd] datetime,[ObowiazujeDo] datetime,[IsValid] bit,
		[ValidFrom] datetime,[ValidTo] datetime,[IsDeleted] bit,[DeletedFrom] datetime,[DeletedBy] int,[CreatedOn] datetime,
		[CreatedBy] int,[LastModifiedOn] datetime,[LastModifiedBy] int,[Priority] smallint,[UIOrder] smallint,[IsAlternativeHistory] bit,[IsMainHistFlow] bit);
		
	CREATE TABLE #CechyRelacji(TypRelacjiId int, RelacjaId int, Id int, CechaId int, TypCechyId int, IdArch int, CzySlownik bit, SparceValue xml, ValString nvarchar(MAX), [IsStatus] bit,[StatusS] int,[StatusSFrom] datetime,[StatusSTo] datetime,
		[StatusSFromBy] int,[StatusSToBy] int,[StatusW] int,[StatusWFrom] datetime,[StatusWTo] datetime,[StatusWFromBy] int,[StatusWToBy] int,[StatusP] int,[StatusPFrom] datetime,
		[StatusPTo] datetime,[StatusPFromBy] int,[StatusPToBy] int,[ObowiazujeOd] datetime,[ObowiazujeDo] datetime,[IsValid] bit,
		[ValidFrom] datetime,[ValidTo] datetime,[IsDeleted] bit,[DeletedFrom] datetime,[DeletedBy] int,[CreatedOn] datetime,
		[CreatedBy] int,[LastModifiedOn] datetime,[LastModifiedBy] int,[Priority] smallint,[UIOrder] smallint,[IsAlternativeHistory] bit,[IsMainHistFlow] bit);
	
	--walidacja poprawnosci XMLa
	EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Attribute_GetHistory', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT

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
		SELECT	@DataProgramu = C.value('./@AppDate', 'datetime')
				,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
				,@BranzaId = C.value('./@BranchId', 'int')
				,@RozwijajPodwezly = C.value('./@ExpandNestedValues', 'bit')
				,@PobierzWszystieDane = C.value('./@GetFullColumnsData', 'bit')
				,@UzytkownikID = C.value('./@UserId', 'int')
				,@StatusS = C.value('./@StatusS', 'int')
				,@StatusP = C.value('./@StatusP', 'int')
				,@StatusW = C.value('./@StatusW', 'int')
		FROM @xml_data.nodes('/Request') T(C)
		
		SET @RozwijajPodwezly = 1;
		SET @PobierzWszystieDane = 1; 
	
		--wyciaganie danych obiektow do pobrania
		INSERT INTO #Obiekty(Id, TypObiektuId, CechaId)
		SELECT	C.value('./@Id', 'int')
			,C.value('./@TypeId', 'int')
			,NULL
		FROM @xml_data.nodes('/Request/ObjectRef') T(C)
		WHERE C.value('./@EntityType', 'nvarchar(50)') = 'Unit'
		
		INSERT INTO #Relacje(Id, TypRelacjiId, CechaId)
		SELECT	C.value('./@Id', 'int')
			,C.value('./@TypeId', 'int')
			,NULL
		FROM @xml_data.nodes('/Request/ObjectRef') T(C)
		WHERE C.value('./@EntityType', 'nvarchar(50)') = 'Relation'
		
		INSERT INTO #Obiekty(Id, TypObiektuId, CechaId)
		SELECT	C.value('./@Id', 'int')
			,C.value('./@TypeId', 'int')
			,C.value('./@AttributeId', 'int')
		FROM @xml_data.nodes('/Request/AttributeRef') T(C)
		WHERE C.value('./@EntityType', 'nvarchar(50)') = 'Unit'
		
		INSERT INTO #Relacje(Id, TypRelacjiId, CechaId)
		SELECT	C.value('./@Id', 'int')
			,C.value('./@TypeId', 'int')
			,C.value('./@AttributeId', 'int')
		FROM @xml_data.nodes('/Request/AttributeRef') T(C)
		WHERE C.value('./@EntityType', 'nvarchar(50)') = 'Relation'	
		
		--SELECT * FROM #Obiekty;
		--SELECT DISTINCT Id, TypObiektuId, CechaId FROM #Obiekty
		--SELECT * FROM #Relacje;

		IF @RequestType = 'Attributes_GetHistory'
		BEGIN
	--		BEGIN TRY
			
			-- pobranie daty na podstawie przekazanego AppDate
			SELECT @AppDate = THB.PrepareAppDate(@DataProgramu);
			
			--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji select
			EXEC [THB].[CheckUserPermission]
				@Operation = N'GET',
				@UserId = @UzytkownikID,
				@BranchId = @BranzaId,
				@Result = @MaUprawnienia OUTPUT
			
			IF @MaUprawnienia = 1
			BEGIN
				--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
				IF Cursor_Status('local','cur') > 0 
				BEGIN
					 CLOSE cur
					 DEALLOCATE cur
				END
			
				--pobieranie cech obiektow do tabel tymczasowych
				DECLARE cur CURSOR LOCAL FOR 
					SELECT DISTINCT TypObiektuId FROM #Obiekty
				OPEN cur
				FETCH NEXT FROM cur INTO @TypObiektuId
				WHILE @@FETCH_STATUS = 0
				BEGIN
					--pobranie nazwy typu obiektu po Id typu
					SELECT @tableName = t.Nazwa, @CzyTabela = t.Tabela 
					FROM dbo.TypObiektu t 
					WHERE t.TypObiekt_ID = @TypObiektuId
				
					--obiekt zwykly
					IF @CzyTabela = 0
					BEGIN
						--pobieranie cech obiektow to tabel tymczasowych						
						SET @Query = N' IF OBJECT_ID (N''[_' + @tableName + '_Cechy_Hist]'', N''U'') IS NOT NULL
						BEGIN
							INSERT INTO #CechyObiektu(TypObiektuId, ObiektId, Id, CechaId, TypCechyId, IdArch, CzySlownik, SparceValue, ValString, [IsStatus],[StatusS],[StatusSFrom],[StatusSTo],
								[StatusSFromBy],[StatusSToBy],[StatusW],[StatusWFrom],[StatusWTo],[StatusWFromBy],[StatusWToBy],[StatusP],[StatusPFrom],
								[StatusPTo],[StatusPFromBy],[StatusPToBy],[ObowiazujeOd],[ObowiazujeDo],[IsValid],
								[ValidFrom],[ValidTo],[IsDeleted],[DeletedFrom],[DeletedBy],[CreatedOn],
								[CreatedBy],[LastModifiedOn],[LastModifiedBy],[Priority],[UIOrder],[IsAlternativeHistory],[IsMainHistFlow])
							SELECT ' + CAST(@TypObiektuId AS varchar) + ', ch.ObiektId, ch.Id, ch.CechaID, c.TypID, ch.IdArch, c.CzySlownik, THB.GetAttributeValueFromSparseXML(ch.ColumnsSet), ch.ValString, ch.[IsStatus], ch.[StatusS], ch.[StatusSFrom],
								ch.[StatusSTo], ch.[StatusSFromBy], ch.[StatusSToBy], ch.[StatusW], ch.[StatusWFrom], ch.[StatusWTo], ch.[StatusWFromBy], ch.[StatusWToBy], ch.[StatusP],
								ch.[StatusPFrom], ch.[StatusPTo], ch.[StatusPFromBy], ch.[StatusPToBy], ch.[ObowiazujeOd], ch.[ObowiazujeDo], ch.[IsValid],
								ch.[ValidFrom], ch.[ValidTo], ch.[IsDeleted], ch.[DeletedFrom], ch.[DeletedBy], ch.[CreatedOn],
								ch.[CreatedBy], ch.[LastModifiedOn], ch.[LastModifiedBy], ch.[Priority], ch.[UIOrder], ch.[IsAlternativeHistory], ch.[IsMainHistFlow]
							FROM [dbo].[_' + @tableName + '_Cechy_Hist] ch
							JOIN dbo.[Cechy] c ON (c.Cecha_ID = ch.CechaID)
							WHERE ch.ObiektId IN (SELECT Id FROM #Obiekty WHERE TypObiektuId = ' + CAST(@TypObiektuId AS varchar) + ')'			
						
						--dodanie frazy statusow na filtracje jesli trzeba
						SET @Query += [THB].[PrepareStatusesPhrase] ('c', @StatusS, @StatusP, @StatusW);
						SET @Query += [THB].[PrepareStatusesPhrase] ('ch', @StatusS, @StatusP, @StatusW);
						
						--dodanie frazy na daty
						SET @Query += [THB].[PrepareDatesPhraseForHistory] ('c', @AppDate);
						SET @Query += [THB].[PrepareDatesPhraseForHistory] ('ch', @AppDate);
					
						SET @Query += '
						END'
										
						--PRINT @query
						EXECUTE sp_executesql @Query;
					END
					ELSE
					BEGIN --obiekt tabelaryczny
							--SET @CzyTabelaCounter = 0;
						SET @UnitTypeColumns = '';
					
						DELETE FROM #KolumnyTypuObiektu;
					
						--pobranie nazw i typow kolumn/cech
						INSERT INTO #KolumnyTypuObiektu (NazwaKolumny, TypKolumny, CechaId)
						SELECT DISTINCT c.Nazwa, ct.NazwaSql, c.Cecha_Id
						FROM dbo.TypObiektu_Cechy toc
						JOIN dbo.Cechy c ON (c.Cecha_Id = toc.Cecha_Id)
						JOIN dbo.Cecha_Typy ct ON (c.TypId = ct.Id)
						WHERE toc.TypObiektu_ID = @TypObiektuId AND toc.IsDeleted = 0;
						
						--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
						IF Cursor_Status('local','curColumns') > 0 
						BEGIN
							 CLOSE curColumns
							 DEALLOCATE curColumns
						END
					
						DECLARE curColumns CURSOR LOCAL FOR 
							SELECT CechaId, NazwaKolumny, TypKolumny FROM #KolumnyTypuObiektu
						OPEN curColumns
						FETCH NEXT FROM curColumns INTO @CechaIdKolumny, @NazwaKolumny, @TypKolumny
						WHILE @@FETCH_STATUS = 0
						BEGIN
								
							IF @NazwaKolumny <> 'Id' --AND @NazwaKolumny <> 'Nazwa'
								SET @UnitTypeColumns += ', [' + @NazwaKolumny + ']';
	
							FETCH NEXT FROM curColumns INTO @CechaIdKolumny, @NazwaKolumny, @TypKolumny
						END
						CLOSE curColumns;
						DEALLOCATE curColumns;
							
						SET @Query = '
									IF OBJECT_ID(''tempdb..##CechyTabelaryczne'') IS NOT NULL
										DROP TABLE ##CechyTabelaryczne;

									SELECT Id' + @UnitTypeColumns + '
									INTO ##CechyTabelaryczne
									FROM [_' + @TableName + '] ob
									WHERE (ob.Id IN (SELECT Id FROM #Obiekty WHERE TypObiektuId = ' + CAST(@TypObiektuId AS varchar) + ') OR ob.IdArch IN (SELECT Id FROM #Obiekty WHERE TypObiektuId = ' + CAST(@TypObiektuId AS varchar) + '))' 
									  
						--PRINT @Query
						EXECUTE sp_executesql @Query;
--select * from ##CechyTabelaryczne			
						--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
						IF Cursor_Status('local','curObjects') > 0 
						BEGIN
							 CLOSE curObjects
							 DEALLOCATE curObjects
						END	
							
						DECLARE curObjects CURSOR LOCAL FOR 
							SELECT Id FROM ##CechyTabelaryczne;
						OPEN curObjects
						FETCH NEXT FROM curObjects INTO @ObiektIdDlaCechy
						WHILE @@FETCH_STATUS = 0
						BEGIN				
						
							--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
							IF Cursor_Status('local','curColumns') > 0 
							BEGIN
								 CLOSE curColumns
								 DEALLOCATE curColumns
							END
							
							DECLARE curColumns CURSOR LOCAL FOR 
								SELECT CechaId, NazwaKolumny, TypKolumny FROM #KolumnyTypuObiektu
							OPEN curColumns
							FETCH NEXT FROM curColumns INTO @CechaIdKolumny, @NazwaKolumny, @TypKolumny
							WHILE @@FETCH_STATUS = 0
							BEGIN
						
								SET @Query = '
									SELECT @WartoscCechy = [' + @NazwaKolumny + ']
									FROM ##CechyTabelaryczne
									WHERE Id = ' + CAST(@ObiektIdDlaCechy AS varchar);
								
								--PRINT @Query;
								EXECUTE sp_executesql @Query, N'@WartoscCechy nvarchar(MAX) OUTPUT', @WartoscCechy = @WartoscCechy OUTPUT

								--pobranie danych cechy
								EXEC [THB].[PrepareTableAttributeValues]
									@DataType = @TypKolumny,
									@DataValue = @WartoscCechy,
									@StringValue = @WartoscCechyString OUTPUT,
									@XmlValue = @WartoscCechyXml OUTPUT		

								SET @Query = '
									INSERT INTO #CechyObiektu(TypObiektuId, ObiektId, Id, IdArch, CechaId, TypCechyId, CzySlownik, SparceValue, ValString,[ObowiazujeOd],[ObowiazujeDo],[IsValid],
										[ValidFrom],[ValidTo],[IsDeleted],[DeletedFrom],[DeletedBy],[CreatedOn],
										[CreatedBy],[LastModifiedOn],[LastModifiedBy],[Priority],[UIOrder],[IsAlternativeHistory],[IsMainHistFlow])
									SELECT ' + CAST(@TypObiektuId AS varchar) + ', ISNULL(ch.IdArch, ch.Id), ' + CAST(@CzyTabelaCounter AS varchar) + ', ch.Id, c.Cecha_ID, c.TypID, c.CzySlownik, ' + @WartoscCechyXml + ', ''' + @WartoscCechyString + ''', ch.[ObowiazujeOd], ch.[ObowiazujeDo], ch.[IsValid],
										ch.[ValidFrom], ch.[ValidTo], ch.[IsDeleted], ch.[DeletedFrom], ch.[DeletedBy], ch.[CreatedOn],
										ch.[CreatedBy], ch.[LastModifiedOn], ch.[LastModifiedBy], 
										CASE 
											WHEN tobc.ID IS NULL THEN 2
											ELSE ISNULL(tobc.[Priority], 0)
										END AS [Priority],
										CASE 
											WHEN tobc.ID IS NULL THEN 100
											ELSE ISNULL(tobc.[UIOrder], 0)
										END AS [UIOrder],
										ch.[IsAlternativeHistory], ch.[IsMainHistFlow]
									FROM [dbo].[_' + @tableName + '] ch
									JOIN dbo.[Cechy] c ON (c.Cecha_ID = ' + CAST(@CechaIdKolumny AS varchar) + ')
									LEFT OUTER JOIN dbo.[TypObiektu_Cechy] tobc ON (tobc.Cecha_ID = c.Cecha_ID AND tobc.TypObiektu_ID = ' + CAST(@TypObiektuId AS varchar) + ')
									WHERE tobc.IdArch IS NULL AND tobc.IsDeleted = 0 AND ch.Id = ' + CAST(@ObiektIdDlaCechy AS varchar)
									
								--dodanie frazy statusow na filtracje jesli trzeba
								SET @Query += [THB].[PrepareStatusesPhrase] ('c', @StatusS, @StatusP, @StatusW);
								SET @Query += [THB].[PrepareStatusesPhrase] ('ch', @StatusS, @StatusP, @StatusW);
								
								--dodanie frazy na daty
								SET @Query += [THB].[PrepareDatesPhraseForHistory] ('c', @AppDate);
								SET @Query += [THB].[PrepareDatesPhraseForHistory] ('ch', @AppDate);
									
								SET @CzyTabelaCounter -= 1;
								
								--jesli maja byc rozne wartosci cech zwracane		
								IF NOT EXISTS(SELECT Id FROM #CechyObiektu WHERE TypObiektuId = @TypObiektuId AND CechaId = @CechaIdKolumny AND ValString = @WartoscCechyString)
								BEGIN
									--PRINT @Query;
									EXECUTE sp_executesql @Query;
								END
		
								FETCH NEXT FROM curColumns INTO @CechaIdKolumny, @NazwaKolumny, @TypKolumny
							END
							CLOSE curColumns;
							DEALLOCATE curColumns;
						
							FETCH NEXT FROM curObjects INTO @ObiektIdDlaCechy
						END					
						CLOSE curObjects;
						DEALLOCATE curObjects;
					END	 

					FETCH NEXT FROM cur INTO @TypObiektuId
				END
				CLOSE cur;
				DEALLOCATE cur;
				
--SELECT * FROM #CechyObiektu		
		
				----pobieranie cech relacji to tabel tymczasowych						
				SET @Query = N'
					INSERT INTO #CechyRelacji(TypRelacjiId, RelacjaId, Id, CechaId, TypCechyId, IdArch, CzySlownik, SparceValue, ValString, [IsStatus],[StatusS],[StatusSFrom],[StatusSTo],
						[StatusSFromBy],[StatusSToBy],[StatusW],[StatusWFrom],[StatusWTo],[StatusWFromBy],[StatusWToBy],[StatusP],[StatusPFrom],
						[StatusPTo],[StatusPFromBy],[StatusPToBy],[ObowiazujeOd],[ObowiazujeDo],[IsValid],
						[ValidFrom],[ValidTo],[IsDeleted],[DeletedFrom],[DeletedBy],[CreatedOn],
						[CreatedBy],[LastModifiedOn],[LastModifiedBy],[Priority],[UIOrder],[IsAlternativeHistory],[IsMainHistFlow])
					SELECT r.TypRelacji_ID, ch.RelacjaId, ch.Id, ch.CechaID, c.TypID, ch.IdArch, c.CzySlownik, THB.GetAttributeValueFromSparseXML(ch.ColumnsSet), ch.ValString, ch.[IsStatus], ch.[StatusS], ch.[StatusSFrom], ch.[StatusSTo], 
						ch.[StatusSFromBy], ch.[StatusSToBy], ch.[StatusW], ch.[StatusWFrom], ch.[StatusWTo], ch.[StatusWFromBy], ch.[StatusWToBy], ch.[StatusP],
						ch.[StatusPFrom], ch.[StatusPTo], ch.[StatusPFromBy], ch.[StatusPToBy], ch.[ObowiazujeOd], ch.[ObowiazujeDo], ch.[IsValid],
						ch.[ValidFrom], ch.[ValidTo], ch.[IsDeleted], ch.[DeletedFrom], ch.[DeletedBy], ch.[CreatedOn],
						ch.[CreatedBy], ch.[LastModifiedOn], ch.[LastModifiedBy], ch.[Priority], ch.[UIOrder], ch.[IsAlternativeHistory], ch.[IsMainHistFlow]
					FROM [dbo].[Relacja_Cecha_Hist] ch
					JOIN [dbo].[Relacje] r ON (ch.RelacjaID = r.Id)
					JOIN dbo.[Cechy] c ON (c.Cecha_ID = ch.CechaID)
					--WHERE ch.RelacjaId IN (SELECT DISTINCT Id FROM #Relacje)'
					
				--dodanie frazy statusow na filtracje jesli trzeba
				SET @Query += [THB].[PrepareStatusesPhrase] ('c', @StatusS, @StatusP, @StatusW);
				SET @Query += [THB].[PrepareStatusesPhrase] ('ch', @StatusS, @StatusP, @StatusW);	
				SET @Query += [THB].[PrepareStatusesPhrase] ('r', @StatusS, @StatusP, @StatusW);
				
				--dodanie frazy na daty
				SET @Query += [THB].[PrepareDatesPhraseForHistory] ('c', @AppDate);
				SET @Query += [THB].[PrepareDatesPhraseForHistory] ('ch', @AppDate);
				SET @Query += [THB].[PrepareDatesPhraseForHistory] ('r', @AppDate);
					
				--PRINT @query
				EXECUTE sp_executesql @Query; 
			
				--SELECT * FROM #CechyRelacji
				--SELECT * FROM #CechyObiektu
				
				--przetwarzanie cech obiektow
				IF Cursor_Status('local','cur2') > 0 
				BEGIN
					 CLOSE cur2
					 DEALLOCATE cur2
				END
				
				DECLARE cur2 CURSOR LOCAL FOR 
					SELECT DISTINCT Id, TypObiektuId, CechaId FROM #Obiekty
				OPEN cur2
				FETCH NEXT FROM cur2 INTO @ObiektId, @TypObiektuId, @IdCechy
				WHILE @@FETCH_STATUS = 0
				BEGIN		
					--IF (SELECT COUNT(1) FROM #CechyObiektu WHERE ObiektId = @ObiektId AND TypObiektuId = @TypObiektuId) > 0
					--BEGIN
					
					--jesli pobieranie wszystkich cech obiektu
					SET @Query = N'
						INSERT INTO #DaneCech(TypObiektuId, ObiektId, Id, CechaId, TypCechyId, IdArch, CzySlownik, SparceValue, ValString, [IsStatus],[StatusS],[StatusSFrom],[StatusSTo],
							[StatusSFromBy],[StatusSToBy],[StatusW],[StatusWFrom],[StatusWTo],[StatusWFromBy],[StatusWToBy],[StatusP],[StatusPFrom],
							[StatusPTo],[StatusPFromBy],[StatusPToBy],[ObowiazujeOd],[ObowiazujeDo],[IsValid],
							[ValidFrom],[ValidTo],[IsDeleted],[DeletedFrom],[DeletedBy],[CreatedOn],
							[CreatedBy],[LastModifiedOn],[LastModifiedBy],[Priority],[UIOrder],[IsAlternativeHistory],[IsMainHistFlow])
						SELECT TypObiektuId, ObiektId, Id, CechaId, TypCechyId, IdArch, CzySlownik, SparceValue, ValString, [IsStatus],[StatusS],[StatusSFrom],[StatusSTo],
							[StatusSFromBy],[StatusSToBy],[StatusW],[StatusWFrom],[StatusWTo],[StatusWFromBy],[StatusWToBy],[StatusP],[StatusPFrom],
							[StatusPTo],[StatusPFromBy],[StatusPToBy],[ObowiazujeOd],[ObowiazujeDo],[IsValid],
							[ValidFrom],[ValidTo],[IsDeleted],[DeletedFrom],[DeletedBy],[CreatedOn],
							[CreatedBy],[LastModifiedOn],[LastModifiedBy],[Priority],[UIOrder],[IsAlternativeHistory],[IsMainHistFlow]
						FROM #CechyObiektu'
						
					IF @IdCechy IS NOT NULL AND @IdCechy > 0
					BEGIN
					
						SELECT @CzyTabela = t.Tabela 
						FROM dbo.TypObiektu t 
						WHERE t.TypObiekt_ID = @TypObiektuId
						
						IF @CzyTabela = 0
							SET @Query += '
								WHERE Id = ' + CAST(@IdCechy AS varchar) + ' OR IdArch = ' + CAST(@IdCechy AS varchar);
						ELSE
							SET @Query += '
								WHERE ObiektId = ' + CAST(@IdCechy AS varchar)
						
						--SET @Query += ' WHERE CechaId = ' + CAST(@IdCechy AS varchar)

					END
					
					PRINT @Query;
					EXECUTE sp_executesql @Query;
--------------
--SELECT * FROM #DaneCech

					SET @IdCechyZHistorii = (SELECT Id FROM #DaneCech WHERE Id = @IdCechy AND IdArch IS NULL);
					
					SET @Query = N' SET @xmlOutVar = (';
					
					IF @PobierzWszystieDane = 0 OR @PobierzWszystieDane IS NULL
					BEGIN
						SET @Query += 'SELECT ' + CAST(@ObiektId AS varchar) + ' AS "@Id"
									, ' + CAST(@TypObiektuId AS varchar) + ' AS "@TypeId"
									, ''Unit'' AS "@EntityType"'

--SELECT @IdCechy AS IdCechy		
					
						IF @IdCechy IS NOT NULL --AND @IdCechyZHistorii IS NOT NULL 
							SET @Query += '
								, ' + CAST(@IdCechy AS varchar) + ' AS "@AttributeId"'
						
						IF @RozwijajPodwezly = 1
						BEGIN
						
							IF Cursor_Status('local','cur3') > 0 
							BEGIN
								 CLOSE cur3
								 DEALLOCATE cur3
							END
					
							--pobieranie danych podwezlow, cech obiektu
							DECLARE cur3 CURSOR LOCAL FOR 
								SELECT Id, SparceValue, ValString, CzySlownik, TypCechyId, CechaId, IsAlternativeHistory FROM #DaneCech WHERE TypObiektuId = @TypObiektuId AND ObiektId = @ObiektId
							OPEN cur3
							FETCH NEXT FROM cur3 INTO @CechaObiektuId, @XmlSparse, @WartoscString, @CzySlownik, @CechaTypId, @CechaId, @CechaHasAlternativeHistory 
							WHILE @@FETCH_STATUS = 0
							BEGIN
									
								SET @CechaTyp = NULL;
								SET @CechaWartosc = NULL;
								
								--IF @IdCechy IS NOT NULL
								--	SET @query += '
								--, (SELECT ' + CAST(@IdCechy AS varchar) + ' AS "@Id"'
								--ELSE
								--	SET @query += '
								--, (SELECT c.[Id] AS "@Id"'
								
								SET @query += '
								, (SELECT ISNULL(c.[IdArch], c.[Id]) AS "@Id"  --c.[Id]
									,c.[CechaID] AS "@TypeId"
									,ISNULL(c.[Priority], 0) AS "@Priority"
									,ISNULL(c.[UIOrder], 0) AS "@UIOrder"
									,ISNULL(c.[LastModifiedBy], c.[CreatedBy]) AS "@LastModifiedBy"
									,ISNULL(c.[LastModifiedOn], c.[CreatedOn]) AS "@LastModifiedOn"'
									
								-- przygotowanie danych/wasrtosci cechy
								IF @XmlSparse IS NOT NULL
								BEGIN								
									SELECT	@CechaTyp = C.value('local-name(.)', 'varchar(max)')
									,@CechaWartosc = C.value('text()[1]', 'nvarchar(200)')
									FROM @XmlSparse.nodes('/*') AS t(c)
								END
								ELSE
								BEGIN
									IF @WartoscString IS NOT NULL
									BEGIN
										SET @CechaWartosc = @WartoscString;
										SET @CechaTyp = 'ValString';
									END								
								END
								
								IF @CechaWartosc IS NOT NULL AND @CechaTyp IS NOT NULL
								BEGIN
									
									IF @CzySlownik = 0
									BEGIN
										IF @CechaHasAlternativeHistory = 0 OR @CechaHasAlternativeHistory IS NULL
										BEGIN
											SET @query += ', ''' + @CechaWartosc + ''' AS "' + @CechaTyp + '/@Value"'
										END
										ELSE
										BEGIN
										
											SET @query += ', ( SELECT ''' + @CechaWartosc + ''' AS "@Value"
														,( SELECT TOP 1 c2.[ZmianaOd] AS "@ChangeFrom"
															,c2.[ZmianaDo] AS "@ChangeTo"
															,c2.[ObowiazujeOd] AS "@EffectiveFrom"
															,c2.[ObowiazujeDo] AS "@EffectiveTo"
															,ISNULL(c2.[IsMainHistFlow], 0) AS "@IsMainHistFlow"
															FROM #DaneCech c2 --#CechyObiektu c2
															WHERE c2.[Id] <> ' + CAST(@CechaObiektuId AS varchar) + ' AND c2.TypObiektuId = ' + CAST(@TypObiektuId AS varchar) 
																+ ' AND c2.ZmianaOd IS NOT NULL AND c2.ObowiazujeOd IS NOT NULL AND c2.IsAlternativeHistory = 0 AND c2.ObiektId = ' + CAST(@ObiektId AS varchar) + '  --@ObiektId
															FOR XML PATH(''History''), TYPE)
														FOR XML PATH(''' + @CechaTyp + '''), TYPE)'
										END										
									END
									ELSE
									BEGIN
										
										IF @CechaHasAlternativeHistory = 0 OR @CechaHasAlternativeHistory IS NULL
										BEGIN
											SET @query += ', ' + CAST(@CechaId AS varchar) + ' AS "ValDictionary/@ElementId"
													, ' + CAST(@CechaTypId AS varchar) + ' AS "ValDictionary/@Id"';
										END
										ELSE
										BEGIN
											SET @query += ', ( SELECT' + CAST(@CechaId AS varchar) + ' AS "@ElementId"
														, ' + CAST(@CechaTypId AS varchar) + ' AS "@Id"
														, (SELECT TOP 1 c2.[ZmianaOd] AS "@ChangeFrom"
															,c2.[ZmianaDo] AS "@ChangeTo"
															,c2.[ObowiazujeOd] AS "@EffectiveFrom"
															,c2.[ObowiazujeDo] AS "@EffectiveTo"
															,ISNULL(c2.[IsMainHistFlow], 0) AS "@IsMainHistFlow"
															FROM #DaneCech c2 --#CechyObiektu c2
																WHERE c2.[Id] <> ' + CAST(@CechaObiektuId AS varchar) + ' AND c2.TypObiektuId = ' + CAST(@TypObiektuId AS varchar) 
																+ ' AND c2.ZmianaOd IS NOT NULL AND c2.ObowiazujeOd IS NOT NULL AND c2.IsAlternativeHistory = 0 AND c2.ObiektId = ' + CAST(@ObiektId AS varchar) + ' --@ObiektId
															FOR XML PATH(''History''), TYPE)
														)
														FOR XML PATH(''ValDictionary''), TYPE)'								
										END
									END																		
								END								
								
								SET @query += '	
									FROM #DaneCech c 
									WHERE c.[Id] = ' + CAST(@CechaObiektuId AS varchar) + '
									FOR XML PATH(''Attribute''), TYPE
									)'
								
								FETCH NEXT FROM cur3 INTO @CechaObiektuId, @XmlSparse, @WartoscString, @CzySlownik, @CechaTypId, @CechaId, @CechaHasAlternativeHistory								
							END
							CLOSE cur3;
							DEALLOCATE cur3;																						
						END
					END -- pobranie wszystkich danych
					ELSE
					BEGIN
					
						SET @query += 'SELECT ' + CAST(@ObiektId AS varchar) + ' AS "@Id"   --@ObiektId
									, ' + CAST(@TypObiektuId AS varchar) + ' AS "@TypeId"
									, ''Unit'' AS "@EntityType"'
									
						IF @IdCechy IS NOT NULL
							SET @query += '
								, ' + CAST(@IdCechy AS varchar) + ' AS "@AttributeId"'												
							
						IF @RozwijajPodwezly = 1
						BEGIN
						
							IF Cursor_Status('local','cur3') > 0 
							BEGIN
								 CLOSE cur3
								 DEALLOCATE cur3
							END
							
							--pobieranie danych podwezlow, cech obiektu
							DECLARE cur3 CURSOR LOCAL FOR 
								SELECT Id, SparceValue, ValString, CzySlownik, TypCechyId, CechaId, IsAlternativeHistory  FROM #DaneCech WHERE TypObiektuId = @TypObiektuId AND ObiektId = @ObiektId --@ObiektId
							OPEN cur3
							FETCH NEXT FROM cur3 INTO @CechaObiektuId, @XmlSparse, @WartoscString, @CzySlownik, @CechaTypId, @CechaId, @CechaHasAlternativeHistory 
							WHILE @@FETCH_STATUS = 0
							BEGIN
											
								--IF @IdCechy IS NOT NULL
								--	SET @query += '
								--, (SELECT ' + CAST(@IdCechy AS varchar) + ' AS "@Id"'
								--ELSE
								--	SET @query += '
								--, (SELECT c.[Id] AS "@Id"'
							
								SET @query += '
								, (SELECT ISNULL(c.[IdArch], c.[Id]) AS "@Id"
										,c.[CechaID] AS "@TypeId"
										,ISNULL(c.[Priority], 0) AS "@Priority"
										,ISNULL(c.[UIOrder], 0) AS "@UIOrder"								
										,c.[IsDeleted] AS "@IsDeleted"
										,c.[DeletedFrom] AS "@DeletedFrom"
										,c.[DeletedBy] AS "@DeletedBy"
										,c.[CreatedOn] AS "@CreatedOn"
										,c.[CreatedBy] AS "@CreatedBy"
										,ISNULL(c.[LastModifiedBy], c.[CreatedBy]) AS "@LastModifiedBy"
										,ISNULL(c.[LastModifiedOn], c.[CreatedOn]) AS "@LastModifiedOn"
										,c.[ObowiazujeOd] AS "History/@EffectiveFrom"
										,c.[ObowiazujeDo] AS "History/@EffectiveTo"
										,c.[IsStatus] AS "Statuses/@IsStatus"
										,c.[StatusS] AS "Statuses/@StatusS"
										,c.[StatusSFrom] AS "Statuses/@StatusSFrom"
										,c.[StatusSTo] AS "Statuses/@StatusSTo"
										,c.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
										,c.[StatusSToBy] AS "Statuses/@StatusSToBy"
										,c.[StatusW] AS "Statuses/@StatusW"
										,c.[StatusWFrom] AS "Statuses/@StatusWFrom"
										,c.[StatusWTo] AS "Statuses/@StatusWTo"
										,c.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
										,c.[StatusWToBy] AS "Statuses/@StatusWToBy"
										,c.[StatusP] AS "Statuses/@StatusP"
										,c.[StatusPFrom] AS "Statuses/@StatusPFrom"
										,c.[StatusPTo] AS "Statuses/@StatusPTo"
										,c.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
										,c.[StatusPToBy] AS "Statuses/@StatusPToBy"'
									
								SET @CechaTyp = NULL;
								SET @CechaWartosc = NULL;
									
								-- przygotowanie danych/wasrtosci cechy
								IF @XmlSparse IS NOT NULL
								BEGIN								
									SELECT	@CechaTyp = C.value('local-name(.)', 'varchar(max)')
									,@CechaWartosc = C.value('text()[1]', 'nvarchar(200)')
									FROM @XmlSparse.nodes('/*') AS t(c)
								END
								ELSE
								BEGIN
									IF @WartoscString IS NOT NULL
									BEGIN
										SET @CechaWartosc = @WartoscString;
										SET @CechaTyp = 'ValString';
									END								
								END								
								
								IF @CechaWartosc IS NOT NULL AND @CechaTyp IS NOT NULL
								BEGIN
									
									IF @CzySlownik = 0
									BEGIN
										IF @CechaHasAlternativeHistory = 0 OR @CechaHasAlternativeHistory IS NULL
											SET @Query += ', ''' + @CechaWartosc + ''' AS "' + @CechaTyp + '/@Value"'
										ELSE
										BEGIN
										
											SET @Query += ', ( SELECT ''' + @CechaWartosc + ''' AS "@Value"
														,( SELECT TOP 1 c2.[ZmianaOd] AS "@ChangeFrom"
															,c2.[ZmianaDo] AS "@ChangeTo"
															,c2.[ObowiazujeOd] AS "@EffectiveFrom"
															,c2.[ObowiazujeDo] AS "@EffectiveTo"
															,ISNULL(c2.[IsMainHistFlow], 0) AS "@IsMainHistFlow"
															FROM #DaneCech c2 --#CechyObiektu c2
															WHERE c2.[Id] <> ' + CAST(@CechaObiektuId AS varchar) + ' AND c2.TypObiektuId = ' + CAST(@TypObiektuId AS varchar) 
																+ ' AND c2.ZmianaOd IS NOT NULL AND c2.ObowiazujeOd IS NOT NULL AND c2.IsALternativeHistory = 0 AND c2.ObiektId = ' + CAST(@ObiektId AS varchar) + ' --@ObiektId
															FOR XML PATH(''History''), TYPE)
														FOR XML PATH(''' + @CechaTyp + '''), TYPE)'
										END										
									END
									ELSE
									BEGIN
										
										IF @CechaHasAlternativeHistory = 0 OR @CechaHasAlternativeHistory IS NULL
											SET @Query += ', ' + CAST(@CechaId AS varchar) + ' AS "ValDictionary/@ElementId"
													, ' + CAST(@CechaTypId AS varchar) + ' AS "ValDictionary/@Id"';
										ELSE
										BEGIN
											SET @Query += ', ( SELECT' + CAST(@CechaId AS varchar) + ' AS "@ElementId"
														, ' + CAST(@CechaTypId AS varchar) + ' AS "@Id"
														, (SELECT TOP 1 c2.[ZmianaOd] AS "@ChangeFrom"
															,c2.[ZmianaDo] AS "@ChangeTo"
															,c2.[ObowiazujeOd] AS "@EffectiveFrom"
															,c2.[ObowiazujeDo] AS "@EffectiveTo"
															,ISNULL(c2.[IsMainHistFlow], 0) AS "@IsMainHistFlow"
															FROM #DaneCech c2 --#CechyObiektu c2
																WHERE c2.[Id] <> ' + CAST(@CechaObiektuId AS varchar) + ' AND c2.TypObiektuId = ' + CAST(@TypObiektuId AS varchar) 
																+ ' AND c2.ZmianaOd IS NOT NULL AND c2.ObowiazujeOd IS NOT NULL AND c2.IsAlternativeHistory = 0 AND c2.ObiektId = ' + CAST(@ObiektId AS varchar) + '  --@ObiektId
															FOR XML PATH(''History''), TYPE)
														)
														FOR XML PATH(''ValDictionary''), TYPE)'											
										END
									END																								
								END								
						-- koniec wartosci cech	
								SET @query += '	
									FROM #DaneCech c --#CechyObiektu c
									WHERE c.[Id] = ' + CAST(@CechaObiektuId AS varchar) + '
									FOR XML PATH(''Attribute''), TYPE
									)
								'
									
								FETCH NEXT FROM cur3 INTO @CechaObiektuId, @XmlSparse, @WartoscString, @CzySlownik, @CechaTypId, @CechaId, @CechaHasAlternativeHistory								
							END
							CLOSE cur3;
							DEALLOCATE cur3;							
						
						END		
					END
					
					SET @Query += ' 
						FOR XML PATH(''HistoryOfAttributes''))' 
					
					--PRINT @query
					EXECUTE sp_executesql @query, N'@xmlOutVar xml OUTPUT', @xmlOutVar = @xmlOut OUTPUT
				
					SET @xmlVar += ISNULL(CAST(@xmlOut AS nvarchar(MAX)), '');
					SET @xmlOut = NULL;
					--END			
					
					DELETE FROM #DaneCech;
					
					FETCH NEXT FROM cur2 INTO @ObiektId, @TypObiektuId, @IdCechy
				END
				CLOSE cur2;
				DEALLOCATE cur2;				
				
		--przetwarzanie cech relacji
		
				IF Cursor_Status('local','cur2') > 0 
				BEGIN
					 CLOSE cur2
					 DEALLOCATE cur2
				END
				
				DECLARE cur2 CURSOR LOCAL FOR 
					SELECT DISTINCT Id, CechaId FROM #Relacje
				OPEN cur2
				FETCH NEXT FROM cur2 INTO @RelacjaId, @IdCechy
				WHILE @@FETCH_STATUS = 0
				BEGIN
		
					DELETE FROM #DaneCech;
		
					SET @query = N'
						INSERT INTO #DaneCech(TypObiektuId, ObiektId, Id, CechaId, TypCechyId, IdArch, CzySlownik, SparceValue, ValString, [IsStatus],[StatusS],[StatusSFrom],[StatusSTo],
							[StatusSFromBy],[StatusSToBy],[StatusW],[StatusWFrom],[StatusWTo],[StatusWFromBy],[StatusWToBy],[StatusP],[StatusPFrom],
							[StatusPTo],[StatusPFromBy],[StatusPToBy],[ObowiazujeOd],[ObowiazujeDo],[IsValid],
							[ValidFrom],[ValidTo],[IsDeleted],[DeletedFrom],[DeletedBy],[CreatedOn],
							[CreatedBy],[LastModifiedOn],[LastModifiedBy],[Priority],[UIOrder],[IsAlternativeHistory],[IsMainHistFlow])
						SELECT TypRelacjiId, RelacjaId, Id, CechaId, TypCechyId, IdArch, CzySlownik, SparceValue, ValString, [IsStatus],[StatusS],[StatusSFrom],[StatusSTo],
							[StatusSFromBy],[StatusSToBy],[StatusW],[StatusWFrom],[StatusWTo],[StatusWFromBy],[StatusWToBy],[StatusP],[StatusPFrom],
							[StatusPTo],[StatusPFromBy],[StatusPToBy],[ObowiazujeOd],[ObowiazujeDo],[IsValid],
							[ValidFrom],[ValidTo],[IsDeleted],[DeletedFrom],[DeletedBy],[CreatedOn],
							[CreatedBy],[LastModifiedOn],[LastModifiedBy],[Priority],[UIOrder],[IsAlternativeHistory],[IsMainHistFlow]
						FROM #CechyRelacji'
						
					IF @IdCechy IS NOT NULL AND @IdCechy > 0
					BEGIN
						--SET @query += '
						--	WHERE Id = ' + CAST(@IdCechy AS varchar) + ' OR IdArch = ' + CAST(@IdCechy AS varchar);
						SET @Query += '
							WHERE CechaId = ' + CAST(@IdCechy AS varchar);				
					END
					
					PRINT @Query;
					EXECUTE sp_executesql @Query;
			
					--IF (SELECT COUNT(1) FROM #CechyRelacji WHERE RelacjaId = @RelacjaId) > 0
					--BEGIN
					
					SET @TypRelacjiId = (SELECT TypRelacji_ID FROM Relacje WHERE Id = @RelacjaId);
					SET @IdCechyZHistorii = (SELECT Id FROM #DaneCech WHERE Id = @IdCechy AND IdArch IS NULL);
					
					SET @query = N' SET @xmlOutVar = (';
					
					IF @PobierzWszystieDane = 0 OR @PobierzWszystieDane IS NULL
					BEGIN
						SET @Query += 'SELECT ' + CAST(@RelacjaId AS varchar) + ' AS "@Id"
									, ' + CAST(@TypRelacjiId AS varchar) + ' AS "@TypeId"
									, ''Relation'' AS "@EntityType"'
									
						IF @IdCechy IS NOT NULL AND @IdCechyZHistorii IS NOT NULL
							SET @query += '
								, ' + CAST(@IdCechyZHistorii AS varchar) + ' AS "@AttributeId"'		
						
						IF @RozwijajPodwezly = 1
						BEGIN
						
							IF Cursor_Status('local','cur3') > 0 
							BEGIN
								 CLOSE cur3
								 DEALLOCATE cur3
							END
							
							--pobieranie danych podwezlow, cech relacji
							DECLARE cur3 CURSOR LOCAL FOR 
								SELECT Id, SparceValue, ValString, CzySlownik, TypCechyId, CechaId, IsAlternativeHistory FROM #DaneCech WHERE RelacjaId = @RelacjaId
							OPEN cur3
							FETCH NEXT FROM cur3 INTO @CechaObiektuId, @XmlSparse, @WartoscString, @CzySlownik, @CechaTypId, @CechaId, @CechaHasAlternativeHistory 
							WHILE @@FETCH_STATUS = 0
							BEGIN
								
								SET @CechaTyp = NULL;
								SET @CechaWartosc = NULL;
								
								SET @Query += '
								, (SELECT ISNULL(c.IdArch, c.[Id]) AS "@Id"
									,c.[CechaID] AS "@TypeId"
									,ISNULL(c.[Priority], 0) AS "@Priority"
									,ISNULL(c.[UIOrder], 0) AS "@UIOrder"
									,ISNULL(c.[LastModifiedBy], c.[CreatedBy]) AS "@LastModifiedBy"
									,ISNULL(c.[LastModifiedOn], c.[CreatedOn]) AS "@LastModifiedOn"'
									
								-- przygotowanie danych/wasrtosci cechy
								IF @XmlSparse IS NOT NULL
								BEGIN								
									SELECT @CechaTyp = C.value('local-name(.)', 'varchar(max)')
									,@CechaWartosc = C.value('text()[1]', 'nvarchar(200)')
									FROM @XmlSparse.nodes('/*') AS t(c)
								END
								ELSE
								BEGIN
									IF @WartoscString IS NOT NULL
									BEGIN
										SET @CechaWartosc = @WartoscString;
										SET @CechaTyp = 'ValString';
									END								
								END
								
								IF @CechaWartosc IS NOT NULL AND @CechaTyp IS NOT NULL
								BEGIN
									
									IF @CzySlownik = 0
									BEGIN
										IF @CechaHasAlternativeHistory = 0 OR @CechaHasAlternativeHistory IS NULL
										BEGIN
											SET @Query += ', ''' + @CechaWartosc + ''' AS "' + @CechaTyp + '/@Value"'
										END
										ELSE
										BEGIN
										
											SET @Query += ', ( SELECT ''' + @CechaWartosc + ''' AS "@Value"
														,( SELECT TOP 1 c2.[ZmianaOd] AS "@ChangeFrom"
															,c2.[ZmianaDo] AS "@ChangeTo"
															,c2.[ObowiazujeOd] AS "@EffectiveFrom"
															,c2.[ObowiazujeDo] AS "@EffectiveTo"
															,ISNULL(c2.[IsMainHistFlow], 0) AS "@IsMainHistFlow"
															FROM #DaneCech c2 --#CechyRelacji c2
															WHERE c2.[Id] <> ' + CAST(@CechaObiektuId AS varchar) + 
															' AND c2.ZmianaOd IS NOT NULL AND c2.ObowiazujeOd IS NOT NULL AND c2.IsAlternativeHistory = 0 AND c2.RelacjaId = ' + CAST(@RelacjaId AS varchar) + '  
															FOR XML PATH(''History''), TYPE)
														FOR XML PATH(''' + @CechaTyp + '''), TYPE)'
										END										
									END
									ELSE
									BEGIN
										
										IF @CechaHasAlternativeHistory = 0 OR @CechaHasAlternativeHistory IS NULL
										BEGIN
											SET @Query += ', ' + CAST(@CechaId AS varchar) + ' AS "ValDictionary/@ElementId"
													, ' + CAST(@CechaTypId AS varchar) + ' AS "ValDictionary/@Id"';
										END
										ELSE
										BEGIN
											SET @Query += ', ( SELECT' + CAST(@CechaId AS varchar) + ' AS "@ElementId"
														, ' + CAST(@CechaTypId AS varchar) + ' AS "@Id"
														, (SELECT TOP 1 c2.[ZmianaOd] AS "@ChangeFrom"
															,c2.[ZmianaDo] AS "@ChangeTo"
															,c2.[ObowiazujeOd] AS "@EffectiveFrom"
															,c2.[ObowiazujeDo] AS "@EffectiveTo"
															,ISNULL(c2.[IsMainHistFlow], 0) AS "@IsMainHistFlow"
															FROM #DaneCech c2 --#CechyRelacji c2
																WHERE c2.[Id] <> ' + CAST(@CechaObiektuId AS varchar) +
																' AND c2.ZmianaOd IS NOT NULL AND c2.ObowiazujeOd IS NOT NULL AND c2.IsAlternativeHistory = 0 AND c2.ORelacjaId = ' + CAST(@RelacjaId AS varchar) + '
															FOR XML PATH(''History''), TYPE)
														)
														FOR XML PATH(''ValDictionary''), TYPE)'								
										END
									END																		
								END								
								
								SET @query += '	
									FROM #DaneCech c --#CechyRelacji c
									WHERE c.[Id] = ' + CAST(@CechaObiektuId AS varchar) + '
									ORDER BY c.[IdArch]
									FOR XML PATH(''Attribute''), TYPE
									)'
									
								FETCH NEXT FROM cur3 INTO @CechaObiektuId, @XmlSparse, @WartoscString, @CzySlownik, @CechaTypId, @CechaId, @CechaHasAlternativeHistory								
							END
							CLOSE cur3;
							DEALLOCATE cur3;																						
						END
					END -- pobranie wszystkich danych
					ELSE
					BEGIN
						SET @Query += 'SELECT ' + CAST(@RelacjaId AS varchar) + ' AS "@Id"   
									, ' + CAST(@TypRelacjiId AS varchar) + ' AS "@TypeId"
									, ''Relation'' AS "@EntityType"'
									
						IF @IdCechy IS NOT NULL AND @IdCechyZHistorii IS NOT NULL 
							SET @Query += '
								, ' + CAST(@IdCechyZHistorii AS varchar) + ' AS "@AttributeId"'												
							
						IF @RozwijajPodwezly = 1
						BEGIN
						
							IF Cursor_Status('local','cur3') > 0 
							BEGIN
								 CLOSE cur3
								 DEALLOCATE cur3
							END
							
							--pobieranie danych podwezlow, cech relacji
							DECLARE cur3 CURSOR LOCAL FOR 
								SELECT Id, SparceValue, ValString, CzySlownik, TypCechyId, CechaId, IsAlternativeHistory  FROM #CechyRelacji WHERE RelacjaId = @RelacjaId 
							OPEN cur3
							FETCH NEXT FROM cur3 INTO @CechaObiektuId, @XmlSparse, @WartoscString, @CzySlownik, @CechaTypId, @CechaId, @CechaHasAlternativeHistory 
							WHILE @@FETCH_STATUS = 0
							BEGIN
								
								SET @query += '
									, (SELECT ISNULL(c.IdArch, c.[Id]) AS "@Id"
										,c.[CechaID] AS "@TypeId"
										,ISNULL(c.[Priority], 0) AS "@Priority"
										,ISNULL(c.[UIOrder], 0) AS "@UIOrder"								
										,c.[IsDeleted] AS "@IsDeleted"
										,c.[DeletedFrom] AS "@DeletedFrom"
										,c.[DeletedBy] AS "@DeletedBy"
										,c.[CreatedOn] AS "@CreatedOn"
										,c.[CreatedBy] AS "@CreatedBy"
										,ISNULL(c.[LastModifiedBy], c.[CreatedBy]) AS "@LastModifiedBy"
										,ISNULL(c.[LastModifiedOn], c.[CreatedOn]) AS "@LastModifiedOn"
										,c.[ObowiazujeOd] AS "History/@EffectiveFrom"
										,c.[ObowiazujeDo] AS "History/@EffectiveTo"
										,c.[IsStatus] AS "Statuses/@IsStatus"
										,c.[StatusS] AS "Statuses/@StatusS"
										,c.[StatusSFrom] AS "Statuses/@StatusSFrom"
										,c.[StatusSTo] AS "Statuses/@StatusSTo"
										,c.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
										,c.[StatusSToBy] AS "Statuses/@StatusSToBy"
										,c.[StatusW] AS "Statuses/@StatusW"
										,c.[StatusWFrom] AS "Statuses/@StatusWFrom"
										,c.[StatusWTo] AS "Statuses/@StatusWTo"
										,c.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
										,c.[StatusWToBy] AS "Statuses/@StatusWToBy"
										,c.[StatusP] AS "Statuses/@StatusP"
										,c.[StatusPFrom] AS "Statuses/@StatusPFrom"
										,c.[StatusPTo] AS "Statuses/@StatusPTo"
										,c.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
										,c.[StatusPToBy] AS "Statuses/@StatusPToBy"'
									
								SET @CechaTyp = NULL;
								SET @CechaWartosc = NULL;
									
								-- przygotowanie danych/wasrtosci cechy
								IF @XmlSparse IS NOT NULL
								BEGIN								
									SELECT	@CechaTyp = C.value('local-name(.)', 'varchar(max)')
									,@CechaWartosc = C.value('text()[1]', 'nvarchar(200)')
									FROM @XmlSparse.nodes('/*') AS t(c)
								END
								ELSE
								BEGIN
									IF @WartoscString IS NOT NULL
									BEGIN
										SET @CechaWartosc = @WartoscString;
										SET @CechaTyp = 'ValString';
									END								
								END								
								
								IF @CechaWartosc IS NOT NULL AND @CechaTyp IS NOT NULL
								BEGIN
									
									IF @CzySlownik = 0
									BEGIN
										IF @CechaHasAlternativeHistory = 0 OR @CechaHasAlternativeHistory IS NULL
											SET @query += ', ''' + @CechaWartosc + ''' AS "' + @CechaTyp + '/@Value"'
										ELSE
										BEGIN
										
											SET @query += ', ( SELECT ''' + @CechaWartosc + ''' AS "@Value"
														,( SELECT TOP 1 c2.[ZmianaOd] AS "@ChangeFrom"
															,c2.[ZmianaDo] AS "@ChangeTo"
															,c2.[ObowiazujeOd] AS "@EffectiveFrom"
															,c2.[ObowiazujeDo] AS "@EffectiveTo"
															,ISNULL(c2.[IsMainHistFlow], 0) AS "@IsMainHistFlow"
															FROM #DaneCech c2 --#CechyRelacji c2
															WHERE c2.[Id] <> ' + CAST(@CechaObiektuId AS varchar) + 
																' AND c2.ZmianaOd IS NOT NULL AND c2.ObowiazujeOd IS NOT NULL AND c2.IsALternativeHistory = 0 AND c2.RelacjaId = ' + CAST(@RelacjaId AS varchar) + '
															FOR XML PATH(''History''), TYPE)
														FOR XML PATH(''' + @CechaTyp + '''), TYPE)'
										END										
									END
									ELSE
									BEGIN
										
										IF @CechaHasAlternativeHistory = 0 OR @CechaHasAlternativeHistory IS NULL
											SET @Query += ', ' + CAST(@CechaId AS varchar) + ' AS "ValDictionary/@ElementId"
													, ' + CAST(@CechaTypId AS varchar) + ' AS "ValDictionary/@Id"';
										ELSE
										BEGIN
											SET @Query += ', ( SELECT' + CAST(@CechaId AS varchar) + ' AS "@ElementId"
														, ' + CAST(@CechaTypId AS varchar) + ' AS "@Id"
														, (SELECT TOP 1 c2.[ZmianaOd] AS "@ChangeFrom"
															,c2.[ZmianaDo] AS "@ChangeTo"
															,c2.[ObowiazujeOd] AS "@EffectiveFrom"
															,c2.[ObowiazujeDo] AS "@EffectiveTo"
															,ISNULL(c2.[IsMainHistFlow], 0) AS "@IsMainHistFlow"
															FROM #DaneCech c2 --#CechyRelacji c2
																WHERE c2.[Id] <> ' + CAST(@CechaObiektuId AS varchar) +
																' AND c2.ZmianaOd IS NOT NULL AND c2.ObowiazujeOd IS NOT NULL AND c2.IsAlternativeHistory = 0 AND c2.RelacjaId = ' + CAST(@RelacjaId AS varchar) + '
															FOR XML PATH(''History''), TYPE)
														)
														FOR XML PATH(''ValDictionary''), TYPE)'											
										END
									END																								
								END								
						-- koniec wartosci cech	
								SET @Query += '	
									FROM #DaneCech c --#CechyRelacji c
									WHERE c.[Id] = ' + CAST(@CechaObiektuId AS varchar) + '
									ORDER BY c.[IdArch]
									FOR XML PATH(''Attribute''), TYPE
									)
								'
									
								FETCH NEXT FROM cur3 INTO @CechaObiektuId, @XmlSparse, @WartoscString, @CzySlownik, @CechaTypId, @CechaId, @CechaHasAlternativeHistory								
							END
							CLOSE cur3;
							DEALLOCATE cur3;							
						
						END		
					END
					
					SET @Query += ' 
						FOR XML PATH(''HistoryOfAttributes''))' 
					
					--PRINT @query
					EXECUTE sp_executesql @Query, N'@xmlOutVar xml OUTPUT', @xmlOutVar = @xmlOut OUTPUT
	
					--SELECT @xmlOut;					
					SET @xmlVar += ISNULL(CAST(@xmlOut AS nvarchar(MAX)), '');
					SET @xmlOut = NULL;			
					
					FETCH NEXT FROM cur2 INTO @RelacjaId, @IdCechy
				END
				CLOSE cur2;
				DEALLOCATE cur2;					
							
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Attributes_GetHistory', @Wiadomosc = @ERRMSG OUTPUT 
		
			--END TRY
			--BEGIN CATCH
			--	SET @ERRMSG = @@ERROR;
			--	SET @ERRMSG += ' ';
			--	SET @ERRMSG += ERROR_MESSAGE();
			--END CATCH		
		END
		ELSE
			EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Attributes_GetHistory', @Wiadomosc = @ERRMSG OUTPUT 
	END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Attributes_GetHistory"'
	
	IF @DataProgramu IS NOT NULL	
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
	
	SET @XMLDataOut += '>'
	
	IF @ERRMSG IS NULL OR @ERRMSG = ''		
		--SET @XMLDataOut += ISNULL(CAST(@xmlResponse AS nvarchar(MAX)), '');
		SET @XMLDataOut += @xmlVar;
	ELSE
		SET @XMLDataOut += '<Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/>';
	
	SET @XMLDataOut += '</Response>';
		
	--usuwanie tabel tymczasowych, jesli istnieja		
	IF OBJECT_ID('tempdb..#Obiekty') IS NOT NULL
		DROP TABLE #Obiekty
		
	IF OBJECT_ID('tempdb..#Relacje') IS NOT NULL
		DROP TABLE #Relacje
		
	IF OBJECT_ID('tempdb..#CechyObiektu') IS NOT NULL
		DROP TABLE #CechyObiektu
		
	IF OBJECT_ID('tempdb..#CechyRelacji') IS NOT NULL
		DROP TABLE #CechyRelacji
		
	IF OBJECT_ID('tempdb..#DaneCech') IS NOT NULL
		DROP TABLE #DaneCech
		
	IF OBJECT_ID('tempdb..#KolumnyTypuObiektu') IS NOT NULL
		DROP TABLE #KolumnyTypuObiektu
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
	
END
