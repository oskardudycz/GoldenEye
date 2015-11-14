-- =============================================
-- Author:		DK
-- Create date: 2012-03-16
-- Last modified on: 2013-02-12
-- Description:	Pobiera dane z tabeli Uzytkownicy z uwzglednieniem filrów.
--•	filtr
--•	sortowanie
--•	stronicowanie

-- XML wejsciowy w postaci:

	--<Request RequestType="Users_Get" GetFullColumnsData="true" UserId="1" AppDate="2012-09-09T11:34:67" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
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
	--<Response ResponseType="UnitsOfMeasure_Get" AppDate="2012-02-09" xsi:noNamespaceSchemaLocation="10.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	       
	--<!-- przy <Request .. GetFullColumnsData="true" ..  ExpandNestedValues="true" ../> -->
	--	<UnitOfMeasure Id="1" Name="centymetr" ShortName="cm" Comment="??" IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
	--		<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--		<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1"/>
	--		<Conversions>
				--<UnitsOfMeasureConversion UOMId="1" Ratio="100" />
				--<UnitsOfMeasureConversion UOMId="6" Ratio="22.645646" />
	--		</Conversions>
	--	</UnitOfMeasure>
		
	--<!-- przy <Request .. GetFullColumnsData="false" ..  ExpandNestedValues="true" ../> -->
	--	<UnitOfMeasure Id="2" Name="metr" ShortName="m" Comment="??" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--		<Conversions>
				--<UnitsOfMeasureConversion UOMId="6" Ratio="22.645646" />
	--		</Conversions>
	--	</UnitOfMeasure>
		
	--<!-- przy <Request .. GetFullColumnsData="false" ..  ExpandNestedValues="false" ../> -->
	--	<UnitOfMeasure Id="2" Name="metr" ShortName="m" Comment="??" LastModifiedOn="2012-02-09T12:12:12.121Z"/>
		
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[UnitsOfMeasure_Get]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @query nvarchar(max) = '',
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
		@OrderByClause nvarchar(255),
		@IloscRekordow int,
		@xml_data xml,
		@xmlOk bit = 0,
		@ERRMSG nvarchar(255),
		@xmlResponse xml,
		@RozwijajPodwezly bit = 0,
		@MaUprawnienia bit = 0,
		@StandardWhere nvarchar(300) = '',
		@AppDate datetime,
		@StatusS int,
		@StatusW int,
		@StatusP int,
		@DateFromColumnName nvarchar(100)
		
		--usuwanie tabel tymczasowych, jesli istnieja		
		IF OBJECT_ID('tempdb..#Jednostki') IS NOT NULL
			DROP TABLE #Jednostki;
			
		IF OBJECT_ID('tempdb..#JednostkiFinal') IS NOT NULL
			DROP TABLE #JednostkiFinal;
		
		IF OBJECT_ID('tempdb..#Przeliczniki') IS NOT NULL
			DROP TABLE #Przeliczniki;
			
		CREATE TABLE #JednostkiFinal (Id int);
		CREATE TABLE #Jednostki (Id int);
		CREATE TABLE #Przeliczniki (Id int);
		
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
		
			IF @RequestType = 'UnitsOfMeasure_Get'
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
						SET @OrderByClause = 'ISNULL(IdArch, Id) ASC';
						
					IF SUBSTRING(@OrderByClause, 1, 2) = 'Id'
						SET @OrderByClause = REPLACE(@OrderByClause, 'Id', 'ISNULL(IdArch, Id)');
						
					--pobranie danych Id pasujacych jednostek miary do tabeli tymczasowej							
					SET @Query = '
							INSERT INTO #Jednostki (Id)
							SELECT allData.Id FROM
							(
								SELECT jm.Id, ROW_NUMBER() OVER(PARTITION BY ISNULL(jm.IdArch, jm.Id) ORDER BY jm.Id ASC) AS Rn
								FROM [dbo].[JednostkiMiary] jm
								INNER JOIN
								(
									SELECT ISNULL(jm2.IdArch, jm2.Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, jm2.' + @DateFromColumnName + ' AS MaxDate
									FROM [dbo].[JednostkiMiary] jm2								 
									INNER JOIN 
									(
										SELECT ISNULL(jm3.IdArch, jm3.Id) AS RowID, MAX(jm3.' + @DateFromColumnName + ') AS MaxDate
										FROM [dbo].[JednostkiMiary] jm3
										WHERE 1=1' + @StandardWhere	;								
									
					IF @WhereClause IS NOT NULL
						SET @Query += [THB].PrepareSafeQuery(@WhereClause);	 
									
					SET @Query += '
										GROUP BY ISNULL(jm3.IdArch, jm3.Id)
									) latest
									ON ISNULL(jm2.IdArch, jm2.Id) = latest.RowID AND jm2.' + @DateFromColumnName + ' = latest.MaxDate
									GROUP BY ISNULL(jm2.IdArch, jm2.Id), jm2.' + @DateFromColumnName + '					
								) latestWithMaxDate
								ON  ISNULL(jm.IdArch, jm.Id) = latestWithMaxDate.RowID AND jm.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND jm.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
							) allData
							WHERE allData.Rn = 1'
		
					--PRINT @Query;
					EXECUTE sp_executesql @Query;																	
------											
					--wybranie jednostek pasujacych do stronicowania i sortowania
					SET @Query = 'INSERT INTO #JednostkiFinal (Id)
					SELECT Id FROM
					(
						SELECT Id, ROW_NUMBER() OVER(ORDER BY ' + @OrderByClause + ') Rn							
						FROM [JednostkiMiary] 
						WHERE Id IN (SELECT Id FROM #Jednostki)
					) X
					WHERE 1=1'
								
					IF @stronicowanieWl = 1
						SET @query += ' AND Rn > ' + CAST(@from as varchar) + ' AND Rn <= ' + CAST(@to as varchar);

					--PRINT @query;
					EXECUTE sp_executesql @Query
					

					--pobranie danych Id pasujacych przelicznikow jednostek miary do tabeli tymczasowej							
					SET @Query = '
							INSERT INTO #Przeliczniki (Id)
							SELECT allData.Id FROM
							(
								SELECT jmp.Id, ROW_NUMBER() OVER(PARTITION BY ISNULL(jmp.IdArch, jmp.Id) ORDER BY jmp.Id ASC) AS Rn
								FROM [dbo].[JednostkiMiary_Przeliczniki] jmp
								INNER JOIN
								(
									SELECT ISNULL(jmp2.IdArch, jmp2.Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, jmp2.' + @DateFromColumnName + ' AS MaxDate
									FROM [dbo].[JednostkiMiary_Przeliczniki] jmp2								 
									INNER JOIN 
									(
										SELECT ISNULL(jmp3.IdArch, jmp3.Id) AS RowID, MAX(jmp3.' + @DateFromColumnName + ') AS MaxDate
										FROM [dbo].[JednostkiMiary_Przeliczniki] jmp3
										WHERE IdFrom IN (SELECT ISNULL(IdArch, Id) FROM JednostkiMiary WHERE Id IN (SELECT Id FROM #JednostkiFinal))' + @StandardWhere	;								 
									
					SET @Query += '
										GROUP BY ISNULL(jmp3.IdArch, jmp3.Id)
									) latest
									ON ISNULL(jmp2.IdArch, jmp2.Id) = latest.RowID AND jmp2.' + @DateFromColumnName + ' = latest.MaxDate
									GROUP BY ISNULL(jmp2.IdArch, jmp2.Id), jmp2.' + @DateFromColumnName + '					
								) latestWithMaxDate
								ON  ISNULL(jmp.IdArch, jmp.Id) = latestWithMaxDate.RowID AND jmp.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND jmp.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
							) allData
							WHERE allData.Rn = 1'
		
					--PRINT @Query;
					EXECUTE sp_executesql @Query;
				  
-----			
					SET @Query = 'SET @xmlTemp = (';
					
					IF @PobierzWszystieDane = 0 OR @PobierzWszystieDane IS NULL
					BEGIN
						SET @query += 'SELECT ISNULL(jm.IdArch, jm.[Id]) AS "@Id"
										,jm.[Nazwa] AS "@Name"
										,jm.[NazwaSkrocona] AS "@ShortName"
										,jm.[Uwagi] AS "@Comment"
										,ISNULL(jm.[LastModifiedOn], jm.[CreatedOn]) AS "@LastModifiedOn"'
									
						--pobieranie danych podwezlow			
						IF @RozwijajPodwezly = 1
						BEGIN
							SET @query += ', (SELECT jmp.[IdTo] AS "@UOMId"
												,jmp.[Przelicznik] AS "@Ratio"
												--,CONVERT(varchar, convert(decimal(20,2), jmp.[Przelicznik])) AS "Conversion"
												FROM [JednostkiMiary_Przeliczniki] jmp
												WHERE (jmp.[IdFrom] = jm.[Id] OR jmp.[IdFrom] = jm.[IdArch]) AND jmp.Id IN (SELECT Id FROM #Przeliczniki)
												ORDER BY jmp.[IdTo]
												FOR XML PATH(''UnitsOfMeasureConversion''), ROOT(''Conversions''), TYPE
												)'					
						END																		
					END
					ELSE
					BEGIN
						SET @query += 'SELECT ISNULL(jm.[IdArch], jm.[Id]) AS "@Id"
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
									  ,jm.[ObowiazujeDo] AS "History/@EffectiveTo"';
									  
						--pobieranie danych podwezlow			
						IF @RozwijajPodwezly = 1
						BEGIN
							SET @Query += ', (SELECT jmp.[IdTo] AS "@UOMId"
												,jmp.[Przelicznik] AS "@Ratio"
												--,CONVERT(varchar, convert(decimal(20,2), jmp.[Przelicznik])) AS "Conversion"
												FROM [JednostkiMiary_Przeliczniki] jmp
												WHERE (jmp.[IdFrom] = jm.[Id] OR jmp.[IdFrom] = jm.[IdArch]) AND jmp.Id IN (SELECT Id FROM #Przeliczniki)
												ORDER BY jmp.[IdTo]	
												FOR XML PATH(''UnitsOfMeasureConversion''), ROOT(''Conversions''), TYPE
											)'					
						END			  				  
					END	
					
					--jesli domyslne sortowanie po Id to podmiana na indeks - wymagane dla rekordow historycznych			
					IF SUBSTRING(@OrderByClause, 1, 18) = 'ISNULL(IdArch, Id)'
						SET @OrderByClause = REPLACE(@OrderByClause, 'ISNULL(IdArch, Id)', '1');
			
					SET @query += ' FROM [JednostkiMiary] jm
									WHERE Id IN (SELECT ID FROM #JednostkiFinal)
									ORDER BY ' + @OrderByClause + ' FOR XML PATH(''UnitOfMeasure''))';

					--PRINT @query;
					EXECUTE sp_executesql @query, N'@xmlTemp xml OUTPUT', @xmlTemp = @xmlResponse OUTPUT
					
					IF @stronicowanieWl = 1
					BEGIN
						--pobranie ilosci wszystkich rekordow i obliczenie ilosci stron
						SELECT @IloscRekordow = COUNT(1) FROM #Jednostki;
					END

				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'UnitsOfMeasure_Get', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'UnitsOfMeasure_Get', @Wiadomosc = @ERRMSG OUTPUT
				
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH	
		END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="UnitsOfMeasure_Get"'
	
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
	
	--usuwanie tabel tymczasowych, jesli istnieja	
	IF OBJECT_ID('tempdb..#Jednostki') IS NOT NULL
		DROP TABLE #Jednostki;
		
	IF OBJECT_ID('tempdb..#JednostkiFinal') IS NOT NULL
		DROP TABLE #JednostkiFinal;
	
	IF OBJECT_ID('tempdb..#Przeliczniki') IS NOT NULL
		DROP TABLE #Przeliczniki;
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut

END
