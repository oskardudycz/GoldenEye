-- =============================================
-- Author:		DK
-- Create date: 2012-03-02
-- Last modifies on: 2013-02-11
-- Description:	Pobiera dane z tabeli Branze z uwzglednieniem filrów.
--•	filtr
--•	sortowanie
--•	stronicowanie

-- XML wejsciowy w postaci:

	--<Request RequestType="Branches_Get" GetFullColumnsData="true" UserId="1" AppDate="2012-09-09T11:45:23" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<CompositeFilterDescriptor LogicalOperator="AND" xsi:noNamespaceSchemaLocation="GenericFilter.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--		<FilterDescriptor PropertyName="Id" Operator="IsGreaterThanOrEqualTo" Value="1" />
	--	</CompositeFilterDescriptor>
	--	<SortDescriptors>
	--		<SortDescriptor PropertyName="Nazwa" Direction="Descending"></SortDescriptor>
	--	</SortDescriptors>
	--	<Paging PageSize="5" PageIndex="1" />
	--</Request>	

-- XML wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>     
	--<Response ResponseType="Branches_Get" AppDate="2012-02-09">    
	--	<TotalPages PageIndex="1" PageSize="5" TotalPagesCount="5"/>
	--	<Branch Id="19" Name="Budowlana" IsStatus="0" IsArchive="0" IsDeleted="0" CreatedOn="2011-08-25T15:31:19.430" LastModifiedOn="1900-01-01T00:00:00"/>
	--	<Branch Id="24" Name="branza moja" IsStatus="0" IsArchive="0" IsDeleted="0" CreatedOn="2011-08-29T09:54:01.167" LastModifiedOn="1900-01-01T00:00:00"/>
	--	<Branch Id="27" Name="KG Budowlana" IsStatus="0" IsArchive="0" IsDeleted="0" CreatedOn="2011-08-31T13:39:12.260" LastModifiedOn="1900-01-01T00:00:00"/>
	--	<Branch Id="28" Name="KG Wodociąg" IsStatus="0" IsArchive="0" IsDeleted="0" CreatedOn="2011-08-31T15:39:53.490" LastModifiedOn="1900-01-01T00:00:00"/>
	--	<Branch Id="29" Name="KG Administracyjna" IsStatus="0" IsArchive="0" IsDeleted="0" CreatedOn="2011-09-01T12:26:19.283" LastModifiedOn="1900-01-01T00:00:00"/>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Branches_Get]
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
		@IloscStron int = 0,
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
		@BranzeZDostepem nvarchar(MAX) = '',
		@AppDate datetime,
		@StatusS int,
		@StatusW int,
		@StatusP int,
		@DateFromColumnName nvarchar(100)
			
		IF OBJECT_ID('tempdb..#BranzeFinal') IS NOT NULL
			DROP TABLE #BranzeFinal
			
		IF OBJECT_ID('tempdb..#Branze') IS NOT NULL
			DROP TABLE #Branze
			
		CREATE TABLE #BranzeFinal (Id int);			
		CREATE TABLE #Branze (Id int);
		
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
					,@PobierzWszystieDane = C.value('./@GetFullColumnsData', 'bit')
					,@RozwijajPodwezly = C.value('./@ExpandNestedValues', 'bit')
					,@UzytkownikID = C.value('./@UserId', 'nvarchar(32)')
					,@StatusS = C.value('./@StatusS', 'int')
					,@StatusP = C.value('./@StatusP', 'int')
					,@StatusW = C.value('./@StatusW', 'int')
			FROM @xml_data.nodes('/Request') T(C) 
		
			IF @RequestType = 'Branches_Get'
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
						
					--SELECT @WhereClause, @OrderByClause, @RozmiarStrony, @NumerStrony, @ERRMSG			

					IF @NumerStrony IS NOT NULL AND @NumerStrony > 0 AND @RozmiarStrony IS NOT NULL AND @RozmiarStrony > 0
					BEGIN
						SET @from = ((@NumerStrony - 1) * @RozmiarStrony);		
						SET @to = ((@NumerStrony) * @RozmiarStrony);			
						SET @stronicowanieWl = 1;
					END
					
					--pobranie Id branz do ktorych uzytkownik ma uprawnienia
					SET @BranzeZDostepem = THB.GetUserBranchesIds(@UzytkownikId, @AppDate);
				
					--SET @StandardWhere += ' AND IdArch IS NULL AND IsValid = 1 AND IsDeleted = 0';
				
					--ustawienie sortowania dla funkcji rankingowych
					IF @OrderByClause IS NULL OR @OrderByClause = ''
						SET @OrderByClause = 'ISNULL(IdArch, Id) ASC';
						
					IF SUBSTRING(@OrderByClause, 1, 2) = 'Id'
						SET @OrderByClause = REPLACE(@OrderByClause, 'Id', 'ISNULL(IdArch, Id)');
						
					--pobranie danych Id pasujacych branz do tabeli tymczasowej							
					SET @Query = '
							INSERT INTO #Branze (Id)
							SELECT allData.Id FROM
							(
								SELECT b.Id, ROW_NUMBER() OVER(PARTITION BY ISNULL(b.IdArch, b.Id) ORDER BY b.Id ASC) AS Rn
								FROM [dbo].[Branze] b
								INNER JOIN
								(
									SELECT ISNULL(b2.IdArch, b2.Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, b2.' + @DateFromColumnName + ' AS MaxDate
									FROM [dbo].[Branze] b2								 
									INNER JOIN 
									(
										SELECT ISNULL(b3.IdArch, b3.Id) AS RowID, MAX(b3.' + @DateFromColumnName + ') AS MaxDate
										FROM [dbo].[Branze] b3
										WHERE 1=1'									
									
					--dodanie frazy statusow na filtracje jesli trzeba
					SET @Query += [THB].[PrepareStatusesPhrase] ('b3', @StatusS, @StatusP, @StatusW);
					
					--dodanie frazy na daty
					SET @Query += [THB].[PrepareDatesPhrase] ('b3', @AppDate);					
									
					IF @WhereClause IS NOT NULL
						SET @Query += [THB].PrepareSafeQuery(@WhereClause);	
					
					IF @BranzeZDostepem IS NOT NULL
						SET @Query += ' AND b3.Id IN (' + @BranzeZDostepem + ' ) '; 
									
					SET @Query += '
										GROUP BY ISNULL(b3.IdArch, b3.Id)
									) latest
									ON ISNULL(b2.IdArch, b2.Id) = latest.RowID AND b2.' + @DateFromColumnName + ' = latest.MaxDate
									GROUP BY ISNULL(b2.IdArch, b2.Id), b2.' + @DateFromColumnName + '					
								) latestWithMaxDate
								ON  ISNULL(b.IdArch, b.Id) = latestWithMaxDate.RowID AND b.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND b.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
							) allData
							WHERE allData.Rn = 1'
		
					--PRINT @Query;
					EXECUTE sp_executesql @Query;				
					
					--posortowanie i wybranie przedzialu stronicowego pasujacych branz
					SET @Query = 'INSERT INTO #BranzeFinal (Id)
						SELECT Id FROM
						(
							SELECT Id, ROW_NUMBER() OVER(ORDER BY ' + @OrderByClause + ') Rn							
							FROM [Branze] 
							WHERE Id IN (SELECT Id FROM #Branze)
						) X
						WHERE 1=1'
								
					IF @stronicowanieWl = 1
						SET @Query += ' AND Rn > ' + CAST(@from as varchar) + ' AND Rn <= ' + CAST(@to as varchar);
					
					--PRINT @query;
					EXECUTE sp_executesql @Query
						
---------------- pobranie danych w postaci XMLa ---	
					SET @query = 'SET @xmlTemp = (';
					
					IF @PobierzWszystieDane IS NULL OR @PobierzWszystieDane = 0
					BEGIN
						SET @query += 'SELECT ISNULL(IdArch, [Id]) AS "@Id"
										,[Nazwa] AS "@Name"
										,ISNULL([LastModifiedOn], [CreatedOn]) AS "@LastModifiedOn"'				
					END
					ELSE
					BEGIN
						SET @query += 'SELECT ISNULL(IdArch, [Id]) AS "@Id"
								  ,[Nazwa] AS "@Name"
								  ,[IsDeleted] AS "@IsDeleted"
								  ,[DeletedFrom] AS "@DeletedFrom"
								  ,[DeletedBy] AS "@DeletedBy"
								  ,[CreatedOn] AS "@CreatedOn"
								  ,[CreatedBy] AS "@CreatedBy"
								  ,ISNULL([LastModifiedOn], [CreatedOn]) AS "@LastModifiedOn"
								  ,[LastModifiedBy] AS "@LastModifiedBy"
								  ,[ObowiazujeOd] AS "History/@EffectiveFrom"
								  ,[ObowiazujeDo] AS "History/@EffectiveTo"
								  ,[IsAlternativeHistory] AS "History/@IsAlternativeHistory"
								  ,[IsMainHistFlow] AS "History/@IsMainHistFlow"
								  ,[IsStatus] AS "Statuses/@IsStatus"
								  ,[StatusS] AS "Statuses/@StatusS"
								  ,[StatusSFrom] AS "Statuses/@StatusSFrom"
								  ,[StatusSTo] AS "Statuses/@StatusSTo"
								  ,[StatusSFromBy] AS "Statuses/@StatusSFromBy"
								  ,[StatusSToBy] AS "Statuses/@StatusSToBy"
								  ,[StatusW] AS "Statuses/@StatusW"
								  ,[StatusWFrom] AS "Statuses/@StatusWFrom"
								  ,[StatusWTo] AS "Statuses/@StatusWTo"
								  ,[StatusWFromBy] AS "Statuses/@StatusWFromBy"
								  ,[StatusWToBy] AS "Statuses/@StatusWToBy"
								  ,[StatusP] AS "Statuses/@StatusP"
								  ,[StatusPFrom] AS "Statuses/@StatusPFrom"
								  ,[StatusPTo] AS "Statuses/@StatusPTo"
								  ,[StatusPFromBy] AS "Statuses/@StatusPFromBy"
								  ,[StatusPToBy] AS "Statuses/@StatusPToBy"';
					END	 
					
					--jesli domyslne sortowanie po Id to podmiana na indeks - wymagane dla rekordow historycznych			
					IF SUBSTRING(@OrderByClause, 1, 18) = 'ISNULL(IdArch, Id)'
						SET @OrderByClause = REPLACE(@OrderByClause, 'ISNULL(IdArch, Id)', '1');					
					
					SET @query += ' FROM dbo.Branze
									WHERE Id IN (SELECT DISTINCT Id FROM #BranzeFinal)
									ORDER BY ' + @OrderByClause + '
									FOR XML PATH(''Branch'') )'
					
					--PRINT @query;
					EXECUTE sp_executesql @query, N'@xmlTemp xml OUTPUT', @xmlTemp = @xmlResponse OUTPUT
					
					IF @stronicowanieWl = 1
					BEGIN
						--pobranie ilosci wszystkich rekordow i obliczenie ilosci stron
						SET @query = 'SET @IloscStron = (SELECT COUNT(1) FROM #Branze)';
						
						EXECUTE sp_executesql @query, N'@IloscStron int OUTPUT', @IloscStron = @IloscRekordow OUTPUT
					END
					
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Branches_Get', @Wiadomosc = @ERRMSG OUTPUT 
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Branches_Get', @Wiadomosc = @ERRMSG OUTPUT
			
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH		
		END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Branches_Get"';
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
	
	SET @XMLDataOut += '>'	
	
	--dodanie do odpowiedzi informacji o stronach
	IF @stronicowanieWl = 1
	BEGIN
		SET @XMLDataOut += '<TotalPages PageIndex="' + CAST(@NumerStrony AS varchar) + '" PageSize="' + CAST(@RozmiarStrony AS varchar) + '" ItemCount="' + CAST(ISNULL(@IloscRekordow, 0) AS varchar) + '"/>'; --'" TotalPagesCount="' + CAST(ISNULL(@IloscStron, 0) AS varchar) + '"/>'
	END
	
	IF @ERRMSG IS NULL OR @ERRMSG = ''		
		SET @XMLDataOut += ISNULL(CAST(@xmlResponse AS nvarchar(MAX)), '');
	ELSE
		SET @XMLDataOut += '<Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/>';
	
	SET @XMLDataOut += '</Response>'; 
	
	
	--usuwanie tabel tymczasowych, jesli istnieja	
	IF OBJECT_ID('tempdb..#BranzeFinal') IS NOT NULL
		DROP TABLE #BranzeFinal
		
	IF OBJECT_ID('tempdb..#Branze') IS NOT NULL
		DROP TABLE #Branze
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
END
