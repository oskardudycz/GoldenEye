-- =============================================
-- Author:		DK
-- Create date: 2012-03-09
-- Last modified on: 2013-02-12
-- Description:	Pobiera dane z tabeli TypStruktury_Obiekt z uwzglednieniem filrów.
--•	filtr
--•	sortowanie
--•	stronicowanie

-- XML wejsciowy w postaci:

	--<Request RequestType="StructureTypes_Get" GetFullColumnsData="true" UserId="1" AppDate="2012-010-09T11:45:33" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
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
	--<Response ResponseType="StructureTypes_Get" AppDate="2012-02-09" xsi:noNamespaceSchemaLocation="5.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

	--	<!-- przy <Request .. GetFullColumnsData="true" ..  ExpandNestedValues="true" ../> -->
	--	<StructureType Id="1" Name="?" RootObjectTypeId="1"
	--		IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--		<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false" />
	--		<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1" />
	        
	--		<CouplerStructureType Id="1" LObjectTypeId="12" RObjectTypeId="50" RelationTypeId="33" IsTree="false"         IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
 --       		<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false" />
 --       		<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1" />   
	--		</CouplerStructureType>
	--		<CouplerStructureType Id="2" LObjectTypeId="12" RObjectTypeId="51" RelationTypeId="33" IsTree="false"         IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1" >
 --       		<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false" />
 --       		<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1" />
	--		</CouplerStructureType>        
	--	</StructureType>
	    
	--	<!-- przy <Request .. GetFullColumnsData="false" ..  ExpandNestedValues="true" ../> -->
	--		<StructureType Id="1" Name="?" RootObjectTypeId="2" LastModifiedOn="2012-02-09T12:12:12.121Z" >
 --    						<CouplerStructureType Id="1" LObjectTypeId="12" RObjectTypeId="50" RelationTypeId="33" IsTree="false" LastModifiedOn="2012-02-09T12:12:12.121Z" />
 --   						<CouplerStructureType Id="1" LObjectTypeId="12" RObjectTypeId="50" RelationTypeId="33" IsTree="false" LastModifiedOn="2012-02-09T12:12:12.121Z" />	    
	--		</StructureType>
	    
	--	<!-- przy <Request .. GetFullColumnsData="false" ..  ExpandNestedValues="false" ../> -->
	--	<StructureType Id="1" Name="?" RootObjectTypeId="2" LastModifiedOn="2012-02-09T12:12:12.121Z" />    
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[StructureTypes_Get]
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
		@StandardWhere nvarchar(MAX) = '',
		@AppDate datetime,
		@StatusS int,
		@StatusW int,
		@StatusP int,
		@DateFromColumnName nvarchar(100)
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_StandardRequest', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
	
		IF @xmlOk = 0
		BEGIN
			-- co zrobic jak nie poprawna walidacja XML
			SET @ERRMSG = @ERRMSG;
		END
		ELSE
		BEGIN	
			BEGIN TRY
			
			--usuniecie tabel roboczych			
			IF OBJECT_ID('tempdb..#TypyStruktur') IS NOT NULL
				DROP TABLE #TypyStruktur
			
			IF OBJECT_ID('tempdb..#TypyStrukturFinal') IS NOT NULL
				DROP TABLE #TypyStrukturFinal
				
			IF OBJECT_ID('tempdb..#TypyStrukturDane') IS NOT NULL
				DROP TABLE #TypyStrukturDane
					
			CREATE TABLE #TypyStruktur (Id int);
			CREATE TABLE #TypyStrukturFinal (Id int);
			CREATE TABLE #TypyStrukturDane (Id int);
			
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
		
			IF @RequestType = 'StructureTypes_Get'
			BEGIN
				
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
				
					--pobranie danych filtrow, sortowania, stronicowania
					EXEC [THB].[PrepareFilters]
						@XMLDataIn = @XMLDataIn,
						@WhereClause = @WhereClause OUTPUT,
						@OrderByClause = @OrderByClause OUTPUT,
						@PageSize = @RozmiarStrony OUTPUT,
						@PageIndex = @NumerStrony OUTPUT,
						@ERRMSG = @ERRMSG OUTPUT
						
					--dodanie frazy statusow na filtracje jesli trzeba
					SET @StandardWhere += [THB].[PrepareStatusesPhrase] (NULL, @StatusS, @StatusP, @StatusW);
					
					--dodanie frazy na daty
					SET @StandardWhere += [THB].[PrepareDatesPhrase] (NULL, @AppDate);					
						
				--	SELECT 	@WhereClause, @OrderByClause, @RozmiarStrony, @NumerStrony, @ERRMSG			

					IF @NumerStrony IS NOT NULL AND @NumerStrony > 0 AND @RozmiarStrony IS NOT NULL AND @RozmiarStrony > 0
					BEGIN
						SET @from = ((@NumerStrony - 1) * @RozmiarStrony);		
						SET @to = ((@NumerStrony) * @RozmiarStrony);			
						SET @stronicowanieWl = 1;
					END
			
					--ustawienie sortowania dla funkcji rankingowych
					IF @OrderByClause IS NULL OR @OrderByClause = ''
						SET @OrderByClause = 'Id ASC';	---  

					--pobranie danych Id pasujacych typow struktury do tabeli tymczasowej							
					SET @Query = '
							INSERT INTO #TypyStruktur (Id)
							SELECT allData.Id FROM
							(
								SELECT tso.Id, ROW_NUMBER() OVER(PARTITION BY ISNULL(tso.IdArch, tso.Id) ORDER BY tso.Id ASC) AS Rn
								FROM [dbo].[TypStruktury_Obiekt] tso
								INNER JOIN
								(
									SELECT ISNULL(tso2.IdArch, tso2.Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, tso2.' + @DateFromColumnName + ' AS MaxDate
									FROM [dbo].[TypStruktury_Obiekt] tso2								 
									INNER JOIN 
									(
										SELECT ISNULL(tso3.IdArch, tso3.Id) AS RowID, MAX(tso3.' + @DateFromColumnName + ') AS MaxDate
										FROM [dbo].[TypStruktury_Obiekt] tso3
										WHERE 1=1'
										
					--dodanie frazy statusow i dat na filtracje jesli trzeba
					SET @Query += @StandardWhere;
					
					IF @WhereClause IS NOT NULL
						SET @Query += [THB].PrepareSafeQuery(@WhereClause);								
									
					SET @Query += '
										GROUP BY ISNULL(tso3.IdArch, tso3.Id)
									) latest
									ON ISNULL(tso2.IdArch, tso2.Id) = latest.RowID AND tso2.' + @DateFromColumnName + ' = latest.MaxDate
									GROUP BY ISNULL(tso2.IdArch, tso2.Id), tso2.' + @DateFromColumnName + '					
								) latestWithMaxDate
								ON  ISNULL(tso.IdArch, tso.Id) = latestWithMaxDate.RowID AND tso.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND tso.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
							) allData
							WHERE allData.Rn = 1'
		
					--PRINT @Query;
					EXECUTE sp_executesql @Query;
					
					--posortowanie i wybranie przedzialu stronicowego pasujacych branz
					SET @Query = 'INSERT INTO #TypyStrukturFinal (Id)
						SELECT Id FROM
						(
							SELECT Id, ROW_NUMBER() OVER(ORDER BY ' + @OrderByClause + ') Rn							
							FROM [TypStruktury_Obiekt] 
							WHERE Id IN (SELECT Id FROM #TypyStruktur)
						) X
						WHERE 1=1'
								
					IF @stronicowanieWl = 1
						SET @query += ' AND Rn > ' + CAST(@from as varchar) + ' AND Rn <= ' + CAST(@to as varchar);
					
					--PRINT @query;
					EXECUTE sp_executesql @query
					
					--jesli pobieranie podwezlow to pobieray dodatkowe dane		
					IF @RozwijajPodwezly = 1
					BEGIN
						--pobranie danych Id pasujacych struktur do tabeli tymczasowej							
						SET @Query = '
								INSERT INTO #TypyStrukturDane (Id)
								SELECT allData.Id FROM
								(
									SELECT ts.Id, ROW_NUMBER() OVER(PARTITION BY ISNULL(ts.IdArch, ts.Id) ORDER BY ts.Id ASC) AS Rn
									FROM [dbo].[TypStruktury] ts
									INNER JOIN
									(
										SELECT ISNULL(ts2.IdArch, ts2.Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, ts2.' + @DateFromColumnName + ' AS MaxDate
										FROM [dbo].[TypStruktury] ts2								 
										INNER JOIN 
										(
											SELECT ISNULL(ts3.IdArch, ts3.Id) AS RowID, MAX(ts3.' + @DateFromColumnName + ') AS MaxDate
											FROM [dbo].[TypStruktury] ts3
											WHERE TypStruktury_Obiekt_Id IN (SELECT ISNULL(IdArch, Id) FROM #TypyStrukturFinal) ' + @StandardWhere;							
										
						SET @Query += '
											GROUP BY ISNULL(ts3.IdArch, ts3.Id)
										) latest
										ON ISNULL(ts2.IdArch, ts2.Id) = latest.RowID AND ts2.' + @DateFromColumnName + ' = latest.MaxDate
										GROUP BY ISNULL(ts2.IdArch, ts2.Id), ts2.' + @DateFromColumnName + '					
									) latestWithMaxDate
									ON  ISNULL(ts.IdArch, ts.Id) = latestWithMaxDate.RowID AND ts.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND ts.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
								) allData
								WHERE allData.Rn = 1'
			
						--PRINT @Query;
						EXECUTE sp_executesql @Query;
					END
---					
					--zapytanie z wynikami do XMLa
					SET @Query = 'SET @xmlTemp = (';
					
					IF @PobierzWszystieDane = 0 OR @PobierzWszystieDane IS NULL
					BEGIN
						SET @Query += 'SELECT ISNULL(tso.[IdArch], tso.[Id]) AS "@Id"
										,tso.[Nazwa] AS "@Name"
										,ISNULL(tso.[LastModifiedOn], tso.[CreatedOn]) AS "@LastModifiedOn"
										,tso.[TypObiektuIdRoot] AS "@RootObjectTypeId"
										,tso.[StructureKind] AS "@StructureKind"'
					
						--pobieranie danych podwezlow			
						IF @RozwijajPodwezly = 1
						BEGIN
							SET @Query += ', (SELECT ISNULL(ts.[IdArch], ts.[Id]) AS "@Id"
												,ts.[TypObiektuId_L] AS "@LObjectTypeId"
												,ts.[TypObiektuId_R] AS "@RObjectTypeId"
												,ts.[TypRelacjiId] AS "@RelationTypeId"
												,ts.[IsStructure] AS "@IsTree"
												,ISNULL(ts.[LastModifiedOn], ts.[CreatedOn]) AS "@LastModifiedOn"
												FROM [TypStruktury] ts
												WHERE (ts.[TypStruktury_Obiekt_Id] = tso.[Id] OR ts.[TypStruktury_Obiekt_Id] = tso.[IdArch])
												AND ts.Id IN (SELECT Id FROM #TypyStrukturDane)
												FOR XML PATH(''CouplerStructureType''), TYPE
												)'					
						END													
					END
					ELSE -- pobranie wszystkich danych
					BEGIN
						SET @Query += 'SELECT ISNULL(tso.[IdArch], tso.[Id]) AS "@Id"
									  ,tso.[Nazwa] AS "@Name"
									  ,tso.[TypObiektuIdRoot] AS "@RootObjectTypeId"
									  ,tso.[StructureKind] AS "@StructureKind"
									  ,tso.[IsDeleted] AS "@IsDeleted"
									  ,tso.[DeletedFrom] AS "@DeletedFrom"
									  ,tso.[DeletedBy] AS "@DeletedBy"
									  ,tso.[CreatedOn] AS "@CreatedOn"
									  ,tso.[CreatedBy] AS "@CreatedBy"
									  ,ISNULL(tso.[LastModifiedOn], tso.[CreatedOn]) AS "@LastModifiedOn"
									  ,tso.[LastModifiedBy] AS "@LastModifiedBy"
									  ,tso.[ObowiazujeOd] AS "History/@EffectiveFrom"
									  ,tso.[ObowiazujeDo] AS "History/@EffectiveTo"
									  ,tso.[IsAlternativeHistory] AS "History/@IsAlternativeHistory"
									  ,tso.[IsMainHistFlow] AS "History/@IsMainHistFlow"
									  ,tso.[IsStatus] AS "Statuses/@IsStatus"
									  ,tso.[StatusS] AS "Statuses/@StatusS"
									  ,tso.[StatusSFrom] AS "Statuses/@StatusSFrom"
									  ,tso.[StatusSTo] AS "Statuses/@StatusSTo"
									  ,tso.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
									  ,tso.[StatusSToBy] AS "Statuses/@StatusSToBy"
									  ,tso.[StatusW] AS "Statuses/@StatusW"
									  ,tso.[StatusWFrom] AS "Statuses/@StatusWFrom"
									  ,tso.[StatusWTo] AS "Statuses/@StatusWTo"
									  ,tso.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
									  ,tso.[StatusWToBy] AS "Statuses/@StatusWToBy"
									  ,tso.[StatusP] AS "Statuses/@StatusP"
									  ,tso.[StatusPFrom] AS "Statuses/@StatusPFrom"
									  ,tso.[StatusPTo] AS "Statuses/@StatusPTo"
									  ,tso.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
									  ,tso.[StatusPToBy] AS "Statuses/@StatusPToBy"';
									  
						--pobieranie danych podwezlow			
						IF @RozwijajPodwezly = 1
						BEGIN
							SET @Query += ', (SELECT ISNULL(ts.[IdArch], ts.[Id]) AS "@Id"
									,ts.[TypObiektuId_L] AS "@LObjectTypeId"
									,ts.[TypObiektuId_R] AS "@RObjectTypeId"
									,ts.[TypRelacjiId] AS "@RelationTypeId"
									,ts.[IsStructure] AS "@IsTree"
									,ts.[IsDeleted] AS "@IsDeleted"
									,ts.[DeletedFrom] AS "@DeletedFrom"
									,ts.[DeletedBy] AS "@DeletedBy"
									,ts.[CreatedOn] AS "@CreatedOn"
									,ts.[CreatedBy] AS "@CreatedBy"
									,ISNULL(ts.[LastModifiedOn], ts.[CreatedOn]) AS "@LastModifiedOn"
									,ts.[LastModifiedBy] AS "@LastModifiedBy"
									,ts.[ObowiazujeOd] AS "History/@EffectiveFrom"
									,ts.[ObowiazujeDo] AS "History/@EffectiveTo"
									,ts.[IsAlternativeHistory] AS "History/@IsAlternativeHistory"
									,ts.[IsMainHistFlow] AS "History/@IsMainHistFlow"
									,ts.[IsStatus] AS "Statuses/@IsStatus"
									,ts.[StatusS] AS "Statuses/@StatusS"
									,ts.[StatusSFrom] AS "Statuses/@StatusSFrom"
									,ts.[StatusSTo] AS "Statuses/@StatusSTo"
									,ts.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
									,ts.[StatusSToBy] AS "Statuses/@StatusSToBy"
									,ts.[StatusW] AS "Statuses/@StatusW"
									,ts.[StatusWFrom] AS "Statuses/@StatusWFrom"
									,ts.[StatusWTo] AS "Statuses/@StatusWTo"
									,ts.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
									,ts.[StatusWToBy] AS "Statuses/@StatusWToBy"
									,ts.[StatusP] AS "Statuses/@StatusP"
									,ts.[StatusPFrom] AS "Statuses/@StatusPFrom"
									,ts.[StatusPTo] AS "Statuses/@StatusPTo"
									,ts.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
									,ts.[StatusPToBy] AS "Statuses/@StatusPToBy"
									FROM [TypStruktury] ts
									WHERE (ts.[TypStruktury_Obiekt_Id] = tso.[Id] OR ts.[TypStruktury_Obiekt_Id] = tso.[IdArch])
									AND ts.Id IN (SELECT Id FROM #TypyStrukturDane)
									FOR XML PATH(''CouplerStructureType''), TYPE
									)'					
						END									  
									  
					END
					
					--jesli domyslne sortowanie po Id to podmiana na indeks - wymagane dla rekordow historycznych			
					IF SUBSTRING(@OrderByClause, 1, 2) = 'Id'
						SET @OrderByClause = REPLACE(@OrderByClause, 'Id', '1');
					
					SET @Query += ' FROM [TypStruktury_Obiekt] tso
									WHERE Id IN (SELECT Id FROM #TypyStrukturFinal)
									ORDER BY ' + @OrderByClause + ' FOR XML PATH(''StructureType'') )'

					--PRINT @query;
					EXECUTE sp_executesql @Query, N'@xmlTemp xml OUTPUT', @xmlTemp = @xmlResponse OUTPUT
					
					--pobranie ilosci wszystkich rekordow i obliczenie ilosci stron
					SELECT @IloscRekordow = COUNT(1) FROM #TypyStruktur;

				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'StructureTypes_Get', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'StructureTypes_Get', @Wiadomosc = @ERRMSG OUTPUT			
		
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' '
				SET @ERRMSG +=ERROR_MESSAGE();
			END CATCH
		END
	
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="StructureTypes_Get"'
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
	
	SET @XMLDataOut += '>';
	
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
	
	--usuniecie tabel roboczych	
	IF OBJECT_ID('tempdb..#TypyStruktur') IS NOT NULL
		DROP TABLE #TypyStruktur
		
	IF OBJECT_ID('tempdb..#TypyStrukturFinal') IS NOT NULL
		DROP TABLE #TypyStrukturFinal
		
	IF OBJECT_ID('tempdb..#TypyStrukturDane') IS NOT NULL
		DROP TABLE #TypyStrukturDane
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut 

END
