-- =============================================
-- Author:		DK
-- Create date: 2012-03-12
-- Last modified on: 2013-02-12
-- Description:	Pobiera dane z tabeli Cecha_Typy z uwzglednieniem filtrów.
--•	filtr
--•	sortowanie
--•	stronicowanie

-- XML wejsciowy w postaci:

	--<Request RequestType="DataTypes_Get" GetFullColumnsData="true" UserId="1" AppDate="2012-09-09T11:34:34" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
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
	--<Response ResponseType="DataTypes_Get" AppDate="2012-02-09" xsi:noNamespaceSchemaLocation="5.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

	--<!-- przy <Request .. GetFullColumnsData="true"  ../> -->
 --   <DataType Id="1" Name="?" SQLName="varchar(255)" UIName="nazwaaa" IsUserAttribute="false"
 --       IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedOn="2012-02-09T12:12:12.121Z" LastModifiedBy="1">
 --       <History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false" />
 --       <Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1" />
 --   </DataType>
    
 --   <!-- przy <Request .. GetFullColumnsData="false" .. /> -->
 --   <DataType Id="1" Name="?" SQLName="varchar(255)" UIName="nazwaaa" IsUserAttribute="false"
 --       LastModifiedOn="2012-02-09T12:12:12.121Z" />   
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[DataTypes_Get]
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
	--	@RozwijajPodwezly bit = 0
		@OrderByClause nvarchar(255),
		@IloscRekordow int,
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
		
		--usuniecie tabel tymczasowych
		IF OBJECT_ID('tempdb..#TypyDanych') IS NOT NULL
			DROP TABLE #TypyDanych
			
		IF OBJECT_ID('tempdb..#TypyDanychFinal') IS NOT NULL
			DROP TABLE #TypyDanychFinal
			
		CREATE TABLE #TypyDanych (Id int);
		CREATE TABLE #TypyDanychFinal (Id int);
				
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
				--	,@RozwijajPodwezly = C.value('./@ExpandNestedValues', 'bit')
					,@PobierzWszystieDane = C.value('./@GetFullColumnsData', 'bit')
					,@UzytkownikID = C.value('./@UserId', 'nvarchar(32)')
					,@StatusS = C.value('./@StatusS', 'int')
					,@StatusP = C.value('./@StatusP', 'int')
					,@StatusW = C.value('./@StatusW', 'int')
			FROM @xml_data.nodes('/Request') T(C) 
		
			IF @RequestType = 'DataTypes_Get'
			BEGIN
				
				-- pobranie daty na podstawie przekazanego AppDate
				SELECT @AppDate = THB.PrepareAppDate(@DataProgramu);
				
				--pobrnaie nazwy kolumny po ktorej filtrowane sa daty
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
						SET @OrderByClause = 'Id ASC';						
						
					SET @Query = '
						INSERT INTO #TypyDanych (Id)
						SELECT allData.Id FROM
						(
							SELECT ct.Id, ROW_NUMBER() OVER(PARTITION BY ISNULL(ct.IdArch, ct.Id) ORDER BY ct.Id ASC) AS Rn
							FROM [dbo].[Cecha_Typy] ct
							INNER JOIN
							(
								SELECT ISNULL(ct2.IdArch, ct2.Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, ct2.' + @DateFromColumnName + ' AS MaxDate
								FROM [dbo].[Cecha_Typy] ct2								 
								INNER JOIN 
								(
									SELECT ISNULL(ct3.IdArch, ct3.Id) AS RowID, MAX(ct3.' + @DateFromColumnName + ') AS MaxDate
									FROM [dbo].[Cecha_Typy] ct3
									WHERE 1=1'									
									
					--dodanie frazy statusow na filtracje jesli trzeba
					SET @Query += [THB].[PrepareStatusesPhrase] ('ct3', @StatusS, @StatusP, @StatusW);
					
					--dodanie frazy na daty
					SET @Query += [THB].[PrepareDatesPhrase] ('ct3', @AppDate);					
									
					IF @WhereClause IS NOT NULL
						SET @Query += [THB].PrepareSafeQuery(@WhereClause);	
									
					SET @Query += '
									GROUP BY ISNULL(ct3.IdArch, ct3.Id)
								) latest
								ON ISNULL(ct2.IdArch, ct2.Id) = latest.RowID AND ct2.' + @DateFromColumnName + ' = latest.MaxDate
								GROUP BY ISNULL(ct2.IdArch, ct2.Id), ct2.' + @DateFromColumnName + '					
							) latestWithMaxDate
							ON  ISNULL(ct.IdArch, ct.Id) = latestWithMaxDate.RowID AND ct.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND ct.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
						) allData
						WHERE allData.Rn = 1'
					
					--PRINT @query
					EXECUTE sp_executesql @query
					
					--wydzielenie typow cech wg stronicowania i sortowania
					SET @Query = 'INSERT INTO #TypyDanychFinal (Id)
						SELECT Id FROM
						(
							SELECT Id, ROW_NUMBER() OVER(ORDER BY ' + @OrderByClause + ') Rn							
							FROM [Cecha_Typy] 
							WHERE Id IN (SELECT Id FROM #TypyDanych)
						) X
						WHERE 1=1'
								
					IF @stronicowanieWl = 1
						SET @query += ' AND Rn > ' + CAST(@from as varchar) + ' AND Rn <= ' + CAST(@to as varchar);
					
					--PRINT @query;
					EXECUTE sp_executesql @query
					  
---					
					SET @query = 'SET @xmlTemp = (';
					
					IF @PobierzWszystieDane = 0 OR @PobierzWszystieDane IS NULL
					BEGIN
						SET @query += 'SELECT ISNULL(ct.[IdArch], ct.[Id]) AS "@Id"
										,ct.[Nazwa] AS "@Name"
										,ct.[NazwaSQL] AS "@SQLName"
										,ct.[Nazwa_UI] AS "@UIName"
										,CASE ct.[CzyCechaUzytkownika] WHEN 1 THEN ''true'' ELSE ''false'' END AS "@IsUserAttribute"
										,ISNULL(ct.[LastModifiedOn], ct.[CreatedOn]) AS "@LastModifiedOn"'																	
					END
					ELSE
					BEGIN
						SET @query += 'SELECT ISNULL(ct.[IdArch], ct.[Id]) AS "@Id"
									  ,ct.[Nazwa] AS "@Name"
									  ,ct.[NazwaSQL] AS "@SQLName"
									  ,ct.[Nazwa_UI] AS "@UIName"
									  ,CASE ct.[CzyCechaUzytkownika] WHEN 1 THEN ''true'' ELSE ''false'' END AS "@IsUserAttribute"
									  ,ct.[IsDeleted] AS "@IsDeleted"
									  ,ct.[DeletedFrom] AS "@DeletedFrom"
									  ,ct.[DeletedBy] AS "@DeletedBy"
									  ,ct.[CreatedOn] AS "@CreatedOn"
									  ,ct.[CreatedBy] AS "@CreatedBy"
									  ,ISNULL(ct.[LastModifiedOn], ct.[CreatedOn]) AS "@LastModifiedOn"
									  ,ct.[LastModifiedBy] AS "@LastModifiedBy"
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
									  ,ct.[StatusPToBy] AS "Statuses/@StatusPToBy"';				  
					END	
					
					--jesli domyslne sortowanie po Id to podmiana na indeks - wymagane dla rekordow historycznych			
					IF SUBSTRING(@OrderByClause, 1, 2) = 'Id'
						SET @OrderByClause = REPLACE(@OrderByClause, 'Id', '1');
			
					SET @query += 'FROM [Cecha_Typy] ct
								   WHERE ct.Id IN (SELECT Id FROM #TypyDanychFinal)
								   ORDER BY ' + @OrderByClause + ' FOR XML PATH(''DataType'') )';	

					--PRINT @query;
					EXECUTE sp_executesql @query, N'@xmlTemp xml OUTPUT', @xmlTemp = @xmlResponse OUTPUT
					
					IF @stronicowanieWl = 1
					BEGIN
						--pobranie ilosci wszystkich rekordow i obliczenie ilosci stron
						SET @query = 'SET @IloscStron = (SELECT COUNT(1) FROM #TypyDanych)';
						
						EXECUTE sp_executesql @query, N'@IloscStron int OUTPUT', @IloscStron = @IloscRekordow OUTPUT
					END

				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'DataTypes_Get', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'DataTypes_Get', @Wiadomosc = @ERRMSG OUTPUT		
		
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH
		END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="DataTypes_Get"'
	
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
	
	--usuniecie tabel tymczasowych
	IF OBJECT_ID('tempdb..#TypyDanych') IS NOT NULL
		DROP TABLE #TypyDanych
		
	IF OBJECT_ID('tempdb..#TypyDanychFinal') IS NOT NULL
		DROP TABLE #TypyDanychFinal
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut

END
