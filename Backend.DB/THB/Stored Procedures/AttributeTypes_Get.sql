-- =============================================
-- Author:		DK
-- Create date: 2012-03-13
-- Last modified on: 2013-02-25
-- Description:	Pobiera dane z tabeli Cechy z uwzglednieniem filtrów.
--•	filtr
--•	sortowanie
--•	stronicowanie

-- XML wejsciowy w postaci:

	--<Request RequestType="AttributeTypes_Get" GetFullColumnsData="true" UserId="1" StatusS="" AppDate="2012-09-09T11:45:23" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<CompositeFilterDescriptor LogicalOperator="AND" xsi:noNamespaceSchemaLocation="GenericFilter.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--		<FilterDescriptor PropertyName="Id" Operator="IsGreaterThanOrEqualTo" Value="1" />
	--	</CompositeFilterDescriptor>
	--	<SortDescriptors>
	--		<SortDescriptor PropertyName="Nazwa" Direction="Descending"></SortDescriptor>
	--	</SortDescriptors>
	--	<Paging PageSize="5" PageIndex="1" />
	--</Request>

-- XM wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="AttributeTypes_Get" AppDate="2012-02-09Z" xsi:noNamespaceSchemaLocation="7.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> 

	--	<!-- przy <Request .. GetFullColumnsData="true" ..  ExpandNestedValues="true" ../> -->	
	--	<AttributeType Id="1" Name="?" ShortName="2121" Hint="2" Description="21" TypeId="1" IsDictionary="false" IsRequired="0" IsEmpty="0" IsQuantifiable="0" IsProcessed="0" IsFiltered="0" IsPersonalData="0"
	--		IsUserAttribute="0" TimeIntervalId="2" TemporaryValue="true"
	--		IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--		<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false" />
	--		<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1" />
	--		<DataType Id="1" Name="rfqrq" SQLName="efrer" UIName="werew" IsUserAttribute="0" LastModifiedOn="2012-02-09T12:12:12.121Z" />
			--<LinkedBranches>
			--	<Ref Id="1" />
			--	<Ref Id="2" />
			--</LinkedBranches>
	--	</AttributeType>    
	    
	--	<!-- przy <Request .. GetFullColumnsData="false" ..  ExpandNestedValues="true" ../> -->
	--	<AttributeType Id="1" Name="?" ShortName="2121" Hint="2" Description="21" TypeId="1" IsDictionary="false" IsRequired="0" IsEmpty="0" IsQuantifiable="0" IsProcessed="0" IsFiltered="0" IsPersonalData="0"
	--		IsUserAttribute="0" LastModifiedOn="2012-02-09T12:12:12.121Z" TimeIntervalId="4" TemporaryValue="true">
 --       		<DataType Id="1" Name="rfqrq" SQLName="efrer" UIName="werew" IsUserAttribute="0" LastModifiedOn="2012-02-09T12:12:12.121Z" />
 				--<LinkedBranches>
				--	<Ref Id="1" />
				--	<Ref Id="2" />
				--</LinkedBranches>
	--		</AttributeType>    
	    
	--	<!-- przy <Request .. GetFullColumnsData="false" ..  ExpandNestedValues="false" ../> -->
	--	<AttributeType Id="1" Name="?" ShortName="2121" Hint="2" Description="21" TypeId="1" IsDictionary="false" IsRequired="0" IsEmpty="0" IsQuantifiable="0" IsProcessed="0" IsFiltered="0" IsPersonalData="0"
	--		IsUserAttribute="0" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	    
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[AttributeTypes_Get]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Query nvarchar(max) = '',
		@stronicowanieWl bit = 0,
		@from int,
		@to int,
		@DataProgramu datetime,
		@RequestType nvarchar(100),
		@UzytkownikID int,
		@BranzaID int,
		@NumerStrony int = NULL,
		@RozmiarStrony int = NULL,
		@PobierzWszystieDane bit = 0,
		@WhereClause nvarchar(MAX),
		@OrderByClause nvarchar(MAX),
		@IloscRekordow int,
		@xml_data xml,
		@xmlOk bit = 0,
		@ERRMSG nvarchar(255),
		@xmlResponse xml,
		@RozwijajPodwezly bit = 0,
		@MaUprawnienia bit = 0,
		@AppDate datetime,
		@StatusS int,
		@StatusW int,
		@StatusP int,
		@DateFromColumnName nvarchar(100),
		@StandardWhere nvarchar(MAX) = ''
		
		--usuwanie tabel tymczasowych, jesli istnieja		
		IF OBJECT_ID('tempdb..#Cechy') IS NOT NULL
			DROP TABLE #Cechy;
			
		IF OBJECT_ID('tempdb..#CechyFinal') IS NOT NULL
			DROP TABLE #CechyFinal;
		
		CREATE TABLE #CechyFinal (Id int);
		CREATE TABLE #Cechy (Id int);
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_StandardRequest', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
	
		IF @xmlOk = 0
		BEGIN
			-- co zrobic jak nie poprawna walidacja XML
			SET @ERRMSG = @ERRMSG;
		END
		ELSE
		BEGIN	
		
			--zamiana w filtrach kolumn Id na TypObiekt_Id
			SET @XMLDataIn = REPLACE(@XMLDataIn, '"Id"', '"Cecha_ID"');
		
			BEGIN TRY
			
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
		
			IF @RequestType = 'AttributeTypes_Get'
			BEGIN
				
				-- pobranie daty modyfikacji na podstawie przekazanego AppDate
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

					--pobranie danych filtrow, sortowania, stronicowania
					EXEC [THB].[PrepareFilters]
						@XMLDataIn = @XMLDataIn,
						@WhereClause = @WhereClause OUTPUT,
						@OrderByClause = @OrderByClause OUTPUT,
						@PageSize = @RozmiarStrony OUTPUT,
						@PageIndex = @NumerStrony OUTPUT,
						@ERRMSG = @ERRMSG OUTPUT					
						
				--	SELECT 	@WhereClause, @OrderByClause, @RozmiarStrony, @NumerStrony, @ERRMSG			

					IF @NumerStrony IS NOT NULL AND @NumerStrony > 0 AND @RozmiarStrony IS NOT NULL AND @RozmiarStrony > 0
					BEGIN
						SET @from = ((@NumerStrony - 1) * @RozmiarStrony);	
						SET @to = ((@NumerStrony) * @RozmiarStrony);			
						SET @stronicowanieWl = 1;
					END
		
					--ustawienie sortowania dla funkcji rankingowych
					IF @OrderByClause IS NULL OR @OrderByClause = ''
						SET @OrderByClause = 'ISNULL(IdArch, Cecha_ID) ASC';
						
					--jesli domyslne sortowanie po Id to podmiana na funkcje ISNULL - wymagane dla rekordow historycznych			
					IF SUBSTRING(@OrderByClause, 1, 8) = 'Cecha_ID'
						SET @OrderByClause = REPLACE(@OrderByClause, 'Cecha_ID', 'ISNULL(IdArch, Cecha_ID)');			
						
					SET @StandardWhere = [THB].[PrepareStatusesPhrase] (NULL, @StatusS, @StatusP, @StatusW);					
					
					--dodanie frazy na daty
					SET @StandardWhere += [THB].[PrepareDatesPhrase] (NULL, @AppDate);						
---										
					--pobranie danych Id pasujacych cech do tabeli tymczasowej							
					SET @Query = '
							INSERT INTO #Cechy (Id)
							SELECT allData.Cecha_Id FROM
							(
								SELECT c.Cecha_Id, ROW_NUMBER() OVER(PARTITION BY ISNULL(c.IdArch, c.Cecha_Id) ORDER BY c.Cecha_Id ASC) AS Rn
								FROM [dbo].[Cechy] c
								INNER JOIN
								(
									SELECT ISNULL(c2.IdArch, c2.Cecha_Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, c2.' + @DateFromColumnName + ' AS MaxDate
									FROM [dbo].[Cechy] c2								 
									INNER JOIN 
									(
										SELECT ISNULL(c3.IdArch, c3.Cecha_Id) AS RowID, MAX(c3.' + @DateFromColumnName + ') AS MaxDate
										FROM [dbo].[Cechy] c3
										WHERE 1=1' + @StandardWhere	;								
									
					IF @WhereClause IS NOT NULL
						SET @Query += [THB].PrepareSafeQuery(@WhereClause);	 
									
					SET @Query += '
										GROUP BY ISNULL(c3.IdArch, c3.Cecha_Id)
									) latest
									ON ISNULL(c2.IdArch, c2.Cecha_Id) = latest.RowID AND c2.' + @DateFromColumnName + ' = latest.MaxDate
									GROUP BY ISNULL(c2.IdArch, c2.Cecha_Id), c2.' + @DateFromColumnName + '					
								) latestWithMaxDate
								ON  ISNULL(c.IdArch, c.Cecha_Id) = latestWithMaxDate.RowID AND c.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND c.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
							) allData
							WHERE allData.Rn = 1'
		
					--PRINT @Query;
					EXECUTE sp_executesql @Query;
					
					--wybranie odpowiednich cech dla podanej strony
					SET @Query = 'INSERT INTO #CechyFinal (Id)
						SELECT Cecha_Id FROM
						(
							SELECT Cecha_Id, ROW_NUMBER() OVER(ORDER BY ' + @OrderByClause + ') Rn							
							FROM [Cechy] 
							WHERE Cecha_Id IN (SELECT Id FROM #Cechy)
						) X
						WHERE 1=1'
								
					IF @stronicowanieWl = 1
						SET @Query += ' AND Rn > ' + CAST(@from as varchar) + ' AND Rn <= ' + CAST(@to as varchar);
					
					--PRINT @query;
					EXECUTE sp_executesql @query

--SELECT * FROM #CechyTmp;
--SELECT * FROM #Cechy;					
--SELECT * FROM #CechyFinal									  
---					
					SET @query = 'SET @xmlTemp = (';
					
					IF @PobierzWszystieDane = 0 OR @PobierzWszystieDane IS NULL
					BEGIN
						SET @query += 'SELECT ISNULL(c.IdArch, c.[Cecha_ID]) AS "@Id"
										,c.[Nazwa] AS "@Name"
										,c.[NazwaSkrocona] AS "@ShortName"
										,c.[IsBlocked] AS "@IsBlocked"
										,c.[Hint] AS "@Hint"
										,c.[Opis] AS "@Description"
										,c.[TypID] AS "@TypeId"
										--,CASE WHEN c.[WartoscSlownika] IS NULL THEN ''false'' ELSE ''true'' END AS "@IsDictionary"
										,c.[CzySlownik] AS "@IsDictionary"
										,c.[CzyWymagana] AS "@IsRequired"
										,c.[CzyPusta] AS "@IsEmpty"
										,c.[CzyWyliczana] AS "@IsQuantifiable"
										,c.[CzyPrzetwarzana] AS "@IsProcessed"
										,c.[CzyFiltrowana] AS "@IsFiltered"
										,c.[CzyJestDanaOsobowa] AS "@IsPersonalData"
										,c.[CzyCechaUzytkownika] AS "@IsUserAttribute"
										,ISNULL(c.[LastModifiedOn], c.[CreatedOn]) AS "@LastModifiedOn"
										,c.[ControlSize] AS "@ControlSize"
									    ,c.[Format] AS "@Format"
									    ,c.[JednostkaMiary] AS "@UnitOfMeasureId"
									    ,c.[WartoscDomyslna] AS "@DefaultValue"
									    ,c.[ListaWartosciDopuszczalnych] AS "@ListOfLimitValues"
									    ,c.[CharakterChwilowy] AS "@TemporaryValue"
										,c.[Sledzona] AS "@IsTraced"
									    ,c.[PrzedzialCzasowyId] AS "@TimeIntervalId"
									    ,c.[UnitTypeId] AS "@UnitTypeId"
									    ,c.[RelationTypeId] AS "@RelationTypeId"'
										
						--pobieranie danych podwezlow			
						IF @RozwijajPodwezly = 1
						BEGIN				
					
							SET @query += '
												, (SELECT ct.[Id] AS "@Id"
												,ct.[Nazwa] AS "@Name"
												,ct.[NazwaSQL] AS "@SQLName"
												,ct.[Nazwa_UI] AS "@UIName"
												,ct.[CzyCechaUzytkownika] AS "@IsUserAttribute"
												,ISNULL(ct.[LastModifiedOn], ct.[CreatedOn]) AS "@LastModifiedOn"
												FROM [Cecha_Typy] ct
												WHERE ct.[Id] = c.[TypID]
												FOR XML PATH(''DataType''), TYPE
												)
												
												, (SELECT jm.[Id] AS "@Id"
												,jm.[Nazwa] AS "@Name"
												,jm.[NazwaSkrocona] AS "@ShortName"
												,jm.[Uwagi] AS "@Comment"
												,ISNULL(jm.[LastModifiedOn], jm.[CreatedOn]) AS "@LastModifiedOn"
												FROM [JednostkiMiary] jm
												WHERE jm.[Id] = c.[JednostkaMiary] 
												FOR XML PATH(''UnitOfMeasure''), TYPE
												)'
												
							SET @Query += '
												, (SELECT bc.[BranzaId] AS "@Id"
												, ''Branch'' AS "@EntityType"
												FROM [Branze_Cechy]	bc
												WHERE (bc.[CechaId] = c.[Cecha_ID] OR bc.[CechaId] = c.[IdArch])' --AND IsDeleted = 0
							
							SET @Query += @StandardWhere
				
							SET @Query += '
												FOR XML PATH(''Ref''), ROOT(''LinkedBranches''), TYPE
												)'
																	
						END																		
					END
					ELSE --pobranie wszystkich danych
					BEGIN
						SET @query += 'SELECT ISNULL(c.IdArch, c.[Cecha_ID]) AS "@Id"
										,c.[Nazwa] AS "@Name"
										,c.[NazwaSkrocona] AS "@ShortName"
										,c.[IsBlocked] AS "@IsBlocked"
										,c.[Hint] AS "@Hint"
										,c.[Opis] AS "@Description"
										,c.[TypID] AS "@TypeId"
										--,CASE WHEN c.[WartoscSlownika] IS NULL THEN ''false'' ELSE ''true'' END AS "@IsDictionary"
										,c.[CzySlownik] AS "@IsDictionary"
										,c.[CzyWymagana] AS "@IsRequired"
										,c.[CzyPusta] AS "@IsEmpty"
										,c.[CzyWyliczana] AS "@IsQuantifiable"
										,c.[CzyPrzetwarzana] AS "@IsProcessed"
										,c.[CzyFiltrowana] AS "@IsFiltered"
										,c.[CzyJestDanaOsobowa] AS "@IsPersonalData"
										,c.[CzyCechaUzytkownika] AS "@IsUserAttribute"
										,c.[IsDeleted] AS "@IsDeleted"
										,c.[DeletedFrom] AS "@DeletedFrom"
										,c.[DeletedBy] AS "@DeletedBy"
										,c.[CreatedOn] AS "@CreatedOn"
										,c.[CreatedBy] AS "@CreatedBy"
										,ISNULL(c.[LastModifiedOn], c.[CreatedOn]) AS "@LastModifiedOn"
										,c.[LastModifiedBy] AS "@LastModifiedBy"									  
										,c.[ControlSize] AS "@ControlSize"
										,c.[Format] AS "@Format"
										,c.[JednostkaMiary] AS "@UnitOfMeasureId"
										,c.[WartoscDomyslna] AS "@DefaultValue"
										,c.[ListaWartosciDopuszczalnych] AS "@ListOfLimitValues"
										,c.[CharakterChwilowy] AS "@TemporaryValue"
										,c.[Sledzona] AS "@IsTraced"
										,c.[PrzedzialCzasowyId] AS "@TimeIntervalId"
										,c.[UnitTypeId] AS "@UnitTypeId"
									    ,c.[RelationTypeId] AS "@RelationTypeId"									  
										,c.[ObowiazujeOd] AS "History/@EffectiveFrom"
										,c.[ObowiazujeDo] AS "History/@EffectiveTo"
										,c.[IsAlternativeHistory] AS "History/@IsAlternativeHistory"
										,c.[IsMainHistFlow] AS "History/@IsMainHistFlow"
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
										,c.[StatusPToBy] AS "Statuses/@StatusPToBy"';
								  
						--pobieranie danych podwezlow			
						IF @RozwijajPodwezly = 1
						BEGIN
							SET @query += ', (SELECT ct.[Id] AS "@Id"
												,ct.[Nazwa] AS "@Name"
												,ct.[NazwaSQL] AS "@SQLName"
												,ct.[Nazwa_UI] AS "@UIName"
												,ct.[CzyCechaUzytkownika] AS "@IsUserAttribute"
												,ct.[IsDeleted] AS "@IsDeleted"
												,ct.[DeletedFrom] AS "@DeletedFrom"
												,ct.[DeletedBy] AS "@DeletedBy"
												,ct.[CreatedOn] AS "@CreatedOn"
												,ct.[CreatedBy] AS "@CreatedBy"
												,ct.[LastModifiedBy] AS "@LastModifiedBy"
												,ISNULL(ct.[LastModifiedOn], ct.[CreatedOn]) AS "@LastModifiedOn"
												,ct.[ObowiazujeOd] AS "History/@EffectiveFrom"
												,ct.[ObowiazujeDo] AS "History/@EffectiveTo"
												,ct.[IsAlternativeHistory] AS "History/@IsAlternativeHistory"
												,ct.[IsMainHistFlow] AS "History/@IsMainHistFlow"
												,ct.[IsStatus] AS "Statuses/@IsStatus"
												,ct.[StatusS] AS "Statuses/@StatusS"
												,ct.[StatusSFrom] AS "Statuses/@StatusSFrom"
												,ct.[StatusSTo] AS "Statuses/@StatusSTo"
												,ct.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
												,ct.[StatusSToBy] AS "Statuses/@StatusSToBy"
												,ct.[StatusW] AS "Statuses/@StatusW"
												,ct.[StatusWFrom] AS "Statuses/@StatusWFrom"
												,ct.[StatusWTo] AS "Statuses/@StatusWTo"
												,ct.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
												,ct.[StatusWToBy] AS "Statuses/@StatusWToBy"
												,ct.[StatusP] AS "Statuses/@StatusP"
												,ct.[StatusPFrom] AS "Statuses/@StatusPFrom"
												,ct.[StatusPTo] AS "Statuses/@StatusPTo"
												,ct.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
												,ct.[StatusPToBy] AS "Statuses/@StatusPToBy"
												FROM [Cecha_Typy] ct
												WHERE ct.[Id] = c.[TypID]
												FOR XML PATH(''DataType''), TYPE
												)'
							SET @query += '					
												,(SELECT jm.[Id] AS "@Id"
												,jm.[Nazwa] AS "@Name"
												,jm.[NazwaSkrocona] AS "@ShortName"
												,jm.[Uwagi] AS "@Comment"
												,jm.[IsDeleted] AS "@IsDeleted"
												,jm.[DeletedFrom] AS "@DeletedFrom"
												,jm.[DeletedBy] AS "@DeletedBy"
												,jm.[CreatedOn] AS "@CreatedOn"
												,jm.[CreatedBy] AS "@CreatedBy"
												,jm.[LastModifiedBy] AS "@LastModifiedBy"	
												,ISNULL(jm.[LastModifiedOn], jm.[CreatedOn]) AS "@LastModifiedOn"
												,jm.[ObowiazujeOd] AS "History/@EffectiveFrom"
												,jm.[ObowiazujeDo] AS "History/@EffectiveTo"
												--,jm.[IsAlternativeHistory] AS "History/@IsAlternativeHistory"
												--,jm.[IsMainHistFlow] AS "History/@IsMainHistFlow"
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
												FROM [JednostkiMiary] jm
												WHERE jm.[Id] = c.[JednostkaMiary] 
												FOR XML PATH(''UnitOfMeasure''), TYPE
												)'
												
							SET @Query += '
												, (SELECT bc.[BranzaId] AS "@Id"
												, ''Branch'' AS "@EntityType"
												FROM [Branze_Cechy]	bc
												WHERE (bc.[CechaId] = c.[Cecha_ID] OR bc.[CechaId] = c.[IdArch])' --AND IsDeleted = 0'
												
							SET @Query += @StandardWhere;
							
							SET @Query += '
												FOR XML PATH(''Ref''), ROOT(''LinkedBranches''), TYPE
												)'					
						END				  					  
					END	
					
					--jesli domyslne sortowanie po Id to podmiana na indeks - wymagane dla rekordow historycznych			
					IF SUBSTRING(@OrderByClause, 1, 24) = 'ISNULL(IdArch, Cecha_ID)'
						SET @OrderByClause = REPLACE(@OrderByClause, 'ISNULL(IdArch, Cecha_ID)', '1');
			
					SET @query += 'FROM [Cechy] c
								   WHERE c.Cecha_ID IN (SELECT Id FROM #CechyFinal)
								   ORDER BY ' + @OrderByClause + '
								   FOR XML PATH(''AttributeType'') )';

					--PRINT @query;
					EXECUTE sp_executesql @query, N'@xmlTemp xml OUTPUT', @xmlTemp = @xmlResponse OUTPUT
	
					IF @stronicowanieWl = 1
					BEGIN
						--pobranie ilosci wszystkich rekordow i obliczenie ilosci stron
						SELECT @IloscRekordow = COUNT(1) FROM #Cechy;
					END
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'AttributeTypes_Get', @Wiadomosc = @ERRMSG OUTPUT 
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'AttributeTypes_Get', @Wiadomosc = @ERRMSG OUTPUT			
		
			END TRY
			BEGIN CATCH
				SET @ERRMSG = CAST(@@ERROR AS varchar);
				SET @ERRMSG += ' '
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH
		END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="AttributeTypes_Get"'
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
	
	SET @XMLDataOut += '>'
	
	--dodanie do odpowiedzi informacji o stronach
	IF @stronicowanieWl = 1
	BEGIN
		SET @XMLDataOut += '<TotalPages PageIndex="' + CAST(@NumerStrony AS varchar) + '" PageSize="' + CAST(@RozmiarStrony AS varchar) + '" ItemCount="' + CAST(ISNULL(@IloscRekordow, 0) AS varchar) + '"/>'; --'" TotalPagesCount="' + CAST(ISNULL(@IloscStron, 0) AS varchar) + '"/>'
	END
	
	IF @ERRMSG iS NULL OR @ERRMSG = ''		
		SET @XMLDataOut += ISNULL(CAST(@xmlResponse AS nvarchar(MAX)), '');
	ELSE
		SET @XMLDataOut += '<Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/>';
	
	SET @XMLDataOut += '</Response>';
	
	--usuwanie tabel tymczasowych, jesli istnieja	
	IF OBJECT_ID('tempdb..#Cechy') IS NOT NULL
		DROP TABLE #Cechy;
		
	IF OBJECT_ID('tempdb..#CechyFinal') IS NOT NULL
		DROP TABLE #CechyFinal;
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
END
