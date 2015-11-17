-- =============================================
-- Author:		DK
-- Create date: 2012-03-21
-- Last modified on: 2012-11-23
-- Description:	Pobiera dane z tabeli Operacje z uwzglednieniem filrów.
--•	filtr
--•	sortowanie
--•	stronicowanie

-- XML wejsciowy w postaci:

	--<Request RequestType="Operations_Get" GetFullColumnsData="true" UserId="1" AppDate="2012-09-09T11:45:33">
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
	--<Response ResponseType="Operations_Get" AppDate="2012-02-09">
	--	<Operation Id="1" Name="312213" Description="323123123" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	--	<Operation Id="2" Name="2312213" Description="2323123123" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Operations_Get]
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
		@WhereClause nvarchar(MAX),
		@OrderByClause nvarchar(255),
		@IloscRekordow int,
		@IloscStron int = 0,
		@xml_data xml,
		@xmlOk bit = 0,
		@ERRMSG nvarchar(255),
		@xmlResponse xml,
		@MaUprawnienia bit = 0,
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
			
			--usuwanie tabel tymczasowych, jesli istnieja				
			IF OBJECT_ID('tempdb..#OperacjeFinal') IS NOT NULL
				DROP TABLE #OperacjeFinal
				
			IF OBJECT_ID('tempdb..#Operacje') IS NOT NULL
				DROP TABLE #Operacje
				
			CREATE TABLE #OperacjeFinal (Id int);			
			CREATE TABLE #Operacje (Id int);
			
			--poprawny XML wejsciowy
			SET @xml_data = CAST(@XMLDataIn AS xml);
			
			--wyciaganie daty i typu zadania
			SELECT	@DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(32)')
					,@BranzaId = C.value('./@BranchId', 'int')
					,@UzytkownikID = C.value('./@UserId', 'nvarchar(32)')
					,@StatusS = C.value('./@StatusS', 'int')
					,@StatusP = C.value('./@StatusP', 'int')
					,@StatusW = C.value('./@StatusW', 'int')
			FROM @xml_data.nodes('/Request') T(C)
		
			IF @RequestType = 'Operations_Get'
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
						--@Alias = 'o',
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
		
					--ustawienie sortowania dla funkcji rankingowych
					IF @OrderByClause IS NULL OR @OrderByClause = ''
						SET @OrderByClause = 'Id ASC';						
						
					--pobranie danych Id pasujacych operacji do tabeli tymczasowej							
					SET @Query = '
							INSERT INTO #Operacje (Id)
							SELECT allData.Id FROM
							(
								SELECT o.Id, ROW_NUMBER() OVER(PARTITION BY ISNULL(o.IdArch, o.Id) ORDER BY o.Id ASC) AS Rn
								FROM [dbo].[Operacje] o
								INNER JOIN
								(
									SELECT ISNULL(o2.IdArch, o2.Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, o2.' + @DateFromColumnName + ' AS MaxDate
									FROM [dbo].[Operacje] o2								 
									INNER JOIN 
									(
										SELECT ISNULL(o3.IdArch, o3.Id) AS RowID, MAX(o3.' + @DateFromColumnName + ') AS MaxDate
										FROM [dbo].[Operacje] o3
										WHERE 1=1'									
									
					--dodanie frazy statusow na filtracje jesli trzeba
					SET @Query += [THB].[PrepareStatusesPhrase] ('o3', @StatusS, @StatusP, @StatusW);
					
					--dodanie frazy na daty
					SET @Query += [THB].[PrepareDatesPhrase] ('o3', @AppDate);					
									
					IF @WhereClause IS NOT NULL
						SET @Query += [THB].PrepareSafeQuery(@WhereClause);	
									
					SET @Query += '
										GROUP BY ISNULL(o3.IdArch, o3.Id)
									) latest
									ON ISNULL(o2.IdArch, o2.Id) = latest.RowID AND o2.' + @DateFromColumnName + ' = latest.MaxDate
									GROUP BY ISNULL(o2.IdArch, o2.Id), o2.' + @DateFromColumnName + '					
								) latestWithMaxDate
								ON  ISNULL(o.IdArch, o.Id) = latestWithMaxDate.RowID AND o.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND o.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
							) allData
							WHERE allData.Rn = 1'
		
					--PRINT @Query;
					EXECUTE sp_executesql @Query;							

					
					--posortowanie i wybranie przedzialu stronicowego pasujacych operacji
					SET @Query = 'INSERT INTO #OperacjeFinal (Id)
						SELECT Id FROM
						(
							SELECT Id, ROW_NUMBER() OVER(ORDER BY ' + @OrderByClause + ') Rn							
							FROM [Operacje] 
							WHERE Id IN (SELECT Id FROM #Operacje)
						) X
						WHERE 1=1'
								
					IF @stronicowanieWl = 1
						SET @query += ' AND Rn > ' + CAST(@from as varchar) + ' AND Rn <= ' + CAST(@to as varchar);
					
					--PRINT @query;
					EXECUTE sp_executesql @query	  
		--			
					SET @query += 'SET @xmlTemp = (SELECT o.[Id] AS "@Id"
									,o.[Nazwa] AS "@Name"
									,o.[Opis] AS "@Description"
									,ISNULL(o.[LastModifiedOn], o.[CreatedOn]) AS "@LastModifiedOn"						
									FROM [Operacje] o
									WHERE Id IN (SELECT DISTINCT Id FROM #OperacjeFinal) 					
									ORDER BY ' + @OrderByClause + ' FOR XML PATH(''Operation'') )';
					
					--PRINT @query;
					EXECUTE sp_executesql @query, N'@xmlTemp xml OUTPUT', @xmlTemp = @xmlResponse OUTPUT
					
					--pobranie ilosci wszystkich rekordow i obliczenie ilosci stron
					SET @Query = 'SET @IloscStron = (SELECT COUNT(1) FROM [#Operacje])';
					
					EXECUTE sp_executesql @query, N'@IloscStron int OUTPUT', @IloscStron = @IloscRekordow OUTPUT

				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Operations_Get', @Wiadomosc = @ERRMSG OUTPUT		
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Operations_Get', @Wiadomosc = @ERRMSG OUTPUT
			
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH
		END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Operations_Get"';
	
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
	IF OBJECT_ID('tempdb..#OperacjeFinal') IS NOT NULL
		DROP TABLE #OperacjeFinal
		
	IF OBJECT_ID('tempdb..#Operacje') IS NOT NULL
		DROP TABLE #Operacje
END
