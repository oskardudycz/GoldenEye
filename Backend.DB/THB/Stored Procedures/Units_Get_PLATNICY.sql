-- =============================================
-- Author:		DK
-- Create date: 2013-04-27
-- Last modified on: -
-- Description:	Zwraca liste obiektow o podanych ID (dowolnego typu) wraz z cechami.
-- Wynik zwrocony do interfejsu w formie XML'a

-- XML wejsciowy:

	--<Request RequestType="Units_GetOfType" TypeId="3" UserId="1" AppDate="2012-09-26T12:43:22" GetFullColumnsData="true" ExpandNestedValues="true"
	--	xsi:noNamespaceSchemaLocation="1.Request.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<CompositeFilterDescriptor LogicalOperator="AND">
	--		<FilterDescriptor AttributeTypeId="12" Operator="IsGreaterThanOrEqualTo" Value="12" />
	--		<FilterDescriptor AttributeTypeId="33" Operator="IsEqualTo" Value="4" />
	--		<CompositeFilterDescriptor LogicalOperator="OR">
	--			<FilterDescriptor AttributeTypeId="40" Operator="IsLessThan" Value="200" />
	--			<CompositeFilterDescriptor LogicalOperator="AND">
	--				<FilterDescriptor AttributeTypeId="15" Operator="IsLessThan" Value="1" />
	--			</CompositeFilterDescriptor>
	--		</CompositeFilterDescriptor>
	--	</CompositeFilterDescriptor>
	--</Request>

-- =============================================
CREATE PROCEDURE [THB].[Units_Get_PLATNICY]
(	
	@XMLDataIn nvarchar(MAX),
	@RecordsCount int OUTPUT,
	@ErrorMessage nvarchar(500) OUTPUT
)
AS
BEGIN

	DECLARE @Query nvarchar(max) = '',
		@RequestType nvarchar(100),
		@tableName nvarchar(100) = 'PLATNICY',
		@xml_data xml,
		@xmlOk bit = 0,
		@xmlOut xml,
		@StatusS int,
		@StatusP int,
		@StatusW int,
		@DataProgramu datetime,
		@UzytkownikID int = NULL,
		@BranzaID int,
		@TypObiektuId int,		
		@NazwaTypuObiektu nvarchar(500),		
		@ObiektId int,
		@MaUprawnienia bit = 0,
		@RozwijajPodwezly bit = 0,
		@PobierzWszystieDane bit = 0,
		@NumerStrony int = NULL,
		@RozmiarStrony int = NULL,
		@WhereClause nvarchar(MAX),
		@OrderByClause nvarchar(500),
		@stronicowanieWl bit = 0,
		@from int,
		@to int,
		@AppDate datetime,
		@DateFromColumnName nvarchar(100),
		@StatusesForFilters nvarchar(500)		
	
	--walidacja poprawnosci XMLa
	EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Units_GetOfType', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ErrorMessage OUTPUT

	IF @xmlOk = 0
	BEGIN
		-- co zrobic jak nie poprawna walidacja XML
		SET @ErrorMessage = @ErrorMessage;
	END
	ELSE
	BEGIN
		
		--usuwanie tabel tymczasowych, jesli istnieja				
		IF OBJECT_ID('tempdb..#ObiektyMain') IS NOT NULL
			DROP TABLE #ObiektyMain
			
		IF OBJECT_ID('tempdb..#ObiektyMainFinal') IS NOT NULL
			DROP TABLE #ObiektyMainFinal
				
		CREATE TABLE #ObiektyMain (Id int PRIMARY KEY, IdArch int);	
		CREATE TABLE #ObiektyMainFinal (Id int, IdArch int, Rn int);	

		--poprawny XML wejsciowy
		SET @xml_data = CAST(@XMLDataIn AS xml);
		
		--wyciaganie daty i typu zadania
		SELECT	@DataProgramu = C.value('./@AppDate', 'datetime')
				,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
				,@BranzaId = C.value('./@BranchId', 'int')
				,@TypObiektuId = C.value('./@TypeId', 'int')
				,@NazwaTypuObiektu = C.value('./@Name', 'nvarchar(300)')
				,@RozwijajPodwezly = C.value('./@ExpandNestedValues', 'bit')
				,@PobierzWszystieDane = C.value('./@GetFullColumnsData', 'bit')
				,@UzytkownikID = C.value('./@UserId', 'int')
				,@StatusS =  C.value('./@StatusS','int') 
				,@StatusP = C.value('./@StatusP','int') 
				,@StatusW = C.value('./@StatusW','int') 
		FROM @xml_data.nodes('/Request') T(C) 
	
		IF @RequestType = 'Units_GetOfType'
		BEGIN
			BEGIN TRY
			
			-- pobranie daty na podstawie przekazanego AppDate
			SELECT @AppDate = THB.PrepareAppDate(@DataProgramu);

			--pobranie nazwy kolumny po ktorej filtrowane sa daty
			SET @DateFromColumnName = [THB].[GetDateFromFilterColumn]();
			
			--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji select
			EXEC [THB].[CheckUserPermission]
				@Operation = N'GET',
				@UserId = @UzytkownikID,
				@BranchId = @BranzaId,
				@Result = @MaUprawnienia OUTPUT
			
			IF @MaUprawnienia = 1
			BEGIN
			
				SET @StatusesForFilters = [THB].[PrepareStatusesPhrase] ('ch', @StatusS, @StatusP, @StatusW);			
	
				--pobranie danych filtrow, sortowania, stronicowania
				EXEC [THB].[PrepareFilters_UnitsGetOfType]
					@XMLDataIn = @XMLDataIn,
					@ObjectTypeId = @TypObiektuId,
					@ObjectType = @tableName,
					@AppDate = @AppDate,
					@IsTable = 1,
					@StatusesClause = @StatusesForFilters,
					@WhereClause = @WhereClause OUTPUT,
					@OrderByClause = @OrderByClause OUTPUT,
					@PageSize = @RozmiarStrony OUTPUT,
					@PageIndex = @NumerStrony OUTPUT,
					@ERRMSG = @ErrorMessage OUTPUT
	
				IF @NumerStrony IS NOT NULL AND @NumerStrony > 0 AND @RozmiarStrony IS NOT NULL AND @RozmiarStrony > 0
				BEGIN
					SET @from = ((@NumerStrony - 1) * @RozmiarStrony);		
					SET @to = ((@NumerStrony) * @RozmiarStrony);			
					SET @stronicowanieWl = 1;
				END
				
--SELECT @WhereClause, @OrderByClause, @RozmiarStrony, @NumerStrony,  'po filtrach'										

				--ustawienie sortowania dla funkcji rankingowych
				IF @OrderByClause IS NULL OR @OrderByClause = ''
					SET @OrderByClause = 'ISNULL(IdArch, Id) ASC';	

				IF SUBSTRING(@OrderByClause, 1, 2) = 'Id'
					SET @OrderByClause = REPLACE(@OrderByClause, 'Id', 'ISNULL(IdArch, Id)');				
					
				--jesli obiekt tabelaryczny mozmy od razu wstawic dane do tabeli finalnej w rankingiem
				INSERT INTO #ObiektyMain (Id, IdArch)
				SELECT Id, IdArch							
				FROM [dbo].[_PLATNICY]
				WHERE (IsStatus = 0 OR (IsStatus = 1 AND (StatusW <= @StatusW OR StatusW IS NULL) AND (StatusP <= @StatusP OR StatusP IS NULL))) 
				AND (ObowiazujeOd <= @AppDate) AND (IsDeleted = 0 OR (IsDeleted = 1 AND DeletedFrom > @AppDate))									
								
				--IF @WhereClause IS NOT NULL
				--	SET @Query += [THB].PrepareSafeQuery(@WhereClause);
				
				--posortowanie i wybranie przedzialu stronicowego pasujacych branz
				INSERT INTO #ObiektyMainFinal (Id, IdArch, Rn)
				SELECT Id, IdArch, Rn FROM
				(
					SELECT Id, IdArch, ROW_NUMBER() OVER(ORDER BY Id) Rn							
					FROM [dbo].[_PLATNICY]
					WHERE Id IN (SELECT Id FROM #ObiektyMain)
				) X
				WHERE @stronicowanieWl = 0 OR (@stronicowanieWl = 1 AND Rn > @from AND Rn <= @to);
---
--SELECT * FROM #ObiektyMain;	
--SELECT * FROM #ObiektyMainFinal	

				IF @RozwijajPodwezly = 0
				BEGIN
					--pobieranie danych tylko obiektow
					SELECT ob.Id, ob.IdArch, ob.Nazwa, ob.IsStatus, ob.[StatusS], ob.[StatusSFrom], ob.[StatusSTo], ob.[StatusSFromBy],
						ob.[StatusSToBy], ob.[StatusW], ob.[StatusWFrom], ob.[StatusWTo], ob.[StatusWFromBy], ob.[StatusWToBy], ob.[StatusP], ob.[StatusPFrom], ob.[StatusPTo],
						ob.[StatusPFromBy], ob.[StatusPToBy], ob.[ObowiazujeOd], ob.[ObowiazujeDo], ob.[IsValid], ob.[ValidFrom], ob.[ValidTo],
						ob.[IsDeleted], ob.[DeletedFrom], ob.[DeletedBy], ob.[CreatedOn], ob.[CreatedBy], ob.[LastModifiedOn],
						ob.[LastModifiedBy], ob.[IsAlternativeHistory], ob.[IsMainHistFlow]
					FROM [dbo].[_PLATNICY] ob
					JOIN #ObiektyMainFinal omf ON (ob.Id = omf.Id)
					ORDER BY omf.Rn;
				END
				ELSE IF @RozwijajPodwezly = 1
				BEGIN
					--pobranie danych obiektu i cech		
					SELECT ob.Id, ob.IdArch, ob.Nazwa, ob.IsStatus, ob.[StatusS], ob.[StatusSFrom], ob.[StatusSTo], ob.[StatusSFromBy],
						ob.[StatusSToBy], ob.[StatusW], ob.[StatusWFrom], ob.[StatusWTo], ob.[StatusWFromBy], ob.[StatusWToBy], ob.[StatusP], ob.[StatusPFrom], ob.[StatusPTo],
						ob.[StatusPFromBy], ob.[StatusPToBy], ob.[ObowiazujeOd], ob.[ObowiazujeDo], ob.[IsValid], ob.[ValidFrom], ob.[ValidTo],
						ob.[IsDeleted], ob.[DeletedFrom], ob.[DeletedBy], ob.[CreatedOn], ob.[CreatedBy], ob.[LastModifiedOn],
						ob.[LastModifiedBy], ob.[IsAlternativeHistory], ob.[IsMainHistFlow],
						ob.[BILANS_O], ob.[BLOKADA], ob.[BO_KA], ob.[BO_SW], ob.[BO_US], ob.[BO_WO], ob.[BO_ZO], ob.[DATA_U], ob.[DATAPROGN], ob.[DATAWIND], ob.[GROB], ob.[IDENTYFIK],
						ob.[IdKontrahenta], ob.[IdMiasta], ob.[IdPoczty], ob.[IdTypuPlatnika], ob.[IdUlicy], ob.[INACZEJ], ob.[KARTOTEKA], ob.[KOD_ADR], ob.[KOD_MIASTA], ob.[KOD_P], 
						ob.[KOD_ULICY], ob.[KONTO], ob.[KORYG], ob.[KOSZT], ob.[KOSZT_BO], ob.[KOSZTNAR], ob.[KOSZTNARS], ob.[KOSZTS], ob.[KOSZTS_BO], ob.[KSIEG], ob.[MAIL], ob.[MC01],
						ob.[MC02], ob.[MC03], ob.[MC04], ob.[MC05], ob.[MC06], ob.[MC07], ob.[MC08], ob.[MC09], ob.[MC10], ob.[MC11], ob.[MC12], ob.[MIASTO], ob.[NABYWCA], ob.[NAODS],
						ob.[NIP], ob.[NOTATKA], ob.[NOTY_S], ob.[NOTY_W], ob.[NR_RACH], ob.[NRNOTYODS], ob.[NUMER_DOMU], ob.[NUMER_MIE], ob.[ODSETKI], ob.[ODSETKI_BO], ob.[ODSETKINAR],
						ob.[OSW_O], ob.[P1], ob.[P2], ob.[P3], ob.[PALMTOP], ob.[Pesel], ob.[PLATNIK], ob.[PROGNOZA], ob.[TELEFON], ob.[TERMIN], ob.[TYP_PLAT], ob.[UMORZENIA], ob.[UMOWA],
						ob.[VAT], ob.[WINDYK], ob.[WPLATY], ob.[WYL_ULICE], ob.[ZAKLAD], ob.[ZMARLY], ob.[ZN], ob.[ZN01], ob.[ZN02], ob.[ZN03], ob.[ZN04], ob.[ZN05], ob.[ZN99]
					FROM [dbo].[_PLATNICY] ob
					JOIN #ObiektyMainFinal omf ON (ob.Id = omf.Id)
					ORDER BY omf.Rn;
					
					SELECT @RecordsCount = COUNT(Id) FROM #ObiektyMain;	
				END				
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'UNIT_TYPE_NOT_EXISTS', @Grupa = N'PROC_RESULT', @Val1 = @TypObiektuId, @Wiadomosc = @ErrorMessage OUTPUT 			
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Units_GetOfType', @Wiadomosc = @ErrorMessage OUTPUT 
		
			END TRY
			BEGIN CATCH
				SET @ErrorMessage = @@ERROR;
				SET @ErrorMessage += ' ';
				SET @ErrorMessage += ERROR_MESSAGE();
				
			END CATCH		
		END
		ELSE
			EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Units_GetOfType', @Wiadomosc = @ErrorMessage OUTPUT 
	END
	
	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

	--usuwanie tabel tymczasowych, jesli istnieja	
	IF OBJECT_ID('tempdb..#Obiekty') IS NOT NULL
		DROP TABLE #Obiekty
		
	IF OBJECT_ID('tempdb..#ObiektyMain') IS NOT NULL
		DROP TABLE #ObiektyMain
		
	IF OBJECT_ID('tempdb..#ObiektyMainFinal') IS NOT NULL
		DROP TABLE #ObiektyMainFinal

END
