-- =============================================
-- Author:		DK
-- Create date: 2012-03-14
-- Last modified on: 2013-02-12
-- Description:	Pobiera dane z tabeli Slowniki z uwzglednieniem filrów.
--•	filtr
--•	sortowanie
--•	stronicowanie

-- XML wejsciowy w postaci:

	--<Request RequestType="Dictionary_Get" GetFullColumnsData="true" UserId="1" AppDate="2012-09-09T11:45:22">
	--	<CompositeFilterDescriptor LogicalOperator="AND">
	--		<FilterDescriptor PropertyName="Id" Operator="IsGreaterThanOrEqualTo" Value="1" />
	--	</CompositeFilterDescriptor>
	--	<SortDescriptors>
	--		<SortDescriptor PropertyName="Nazwa" Direction="Descending"></SortDescriptor>
	--	</SortDescriptors>
	--	<Paging PageSize="5" PageIndex="1" />
	--</Request>
	
-- XML wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="Dictionary_Get" AppDate="2012-02-09">	    
	--	<Dictionary Id="2" Name="Banki" LastModifiedOn="2012-02-09T12:12:12.121Z"/>    
	--	<Dictionary Id="4" Name="KodyPocztowe"  LastModifiedOn="2012-02-09T12:12:12.121Z"/>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Dictionary_Get]
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
		@DateFromColumnName nvarchar(100),
		@RozwijajPodwezly bit = 0
		
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
			IF OBJECT_ID('tempdb..#SlownikiFinal') IS NOT NULL
				DROP TABLE #SlownikiFinal
				
			IF OBJECT_ID('tempdb..#Slowniki') IS NOT NULL
				DROP TABLE #Slowniki
				
			IF OBJECT_ID('tempdb..#TypyDanych') IS NOT NULL
				DROP TABLE #TypyDanych
				
			CREATE TABLE #SlownikiFinal (Id int);			
			CREATE TABLE #Slowniki (Id int);
			CREATE TABLE #TypyDanych(Id int, IdArch int);
			
			--poprawny XML wejsciowy
			SET @xml_data = CAST(@XMLDataIn AS xml);
			
			--wyciaganie daty i typu zadania
			SELECT	@DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(32)')
					,@BranzaId = C.value('./@BranchId', 'int')
					,@RozwijajPodwezly = C.value('./@ExpandNestedValues', 'bit')
					,@PobierzWszystieDane = C.value('./@GetFullColumnsData', 'bit')
					,@UzytkownikID = C.value('./@UserId', 'int')
					,@StatusS = C.value('./@StatusS', 'int')
					,@StatusP = C.value('./@StatusP', 'int')
					,@StatusW = C.value('./@StatusW', 'int')
			FROM @xml_data.nodes('/Request') T(C)
		
			IF @RequestType = 'Dictionary_Get'
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
		
					--ustawienie sortowania dla funkcji rankingowych
					IF @OrderByClause IS NULL OR @OrderByClause = ''
						SET @OrderByClause = 'Id ASC';						
						
					--pobranie danych Id pasujacych branz do tabeli tymczasowej							
					SET @Query = '
							INSERT INTO #Slowniki (Id)
							SELECT allData.Id FROM
							(
								SELECT s.Id, ROW_NUMBER() OVER(PARTITION BY ISNULL(s.IdArch, s.Id) ORDER BY s.Id ASC) AS Rn
								FROM [dbo].[Slowniki] s
								INNER JOIN
								(
									SELECT ISNULL(s2.IdArch, s2.Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, s2.' + @DateFromColumnName + ' AS MaxDate
									FROM [dbo].[Slowniki] s2								 
									INNER JOIN 
									(
										SELECT ISNULL(s3.IdArch, s3.Id) AS RowID, MAX(s3.' + @DateFromColumnName + ') AS MaxDate
										FROM [dbo].[Slowniki] s3
										WHERE 1=1'									
									
					--dodanie frazy statusow na filtracje jesli trzeba
					SET @Query += [THB].[PrepareStatusesPhrase] ('s3', @StatusS, @StatusP, @StatusW);
					
					--dodanie frazy na daty
					SET @Query += [THB].[PrepareDatesPhrase] ('s3', @AppDate);					
									
					IF @WhereClause IS NOT NULL
						SET @Query += [THB].PrepareSafeQuery(@WhereClause);	
									
					SET @Query += '
										GROUP BY ISNULL(s3.IdArch, s3.Id)
									) latest
									ON ISNULL(s2.IdArch, s2.Id) = latest.RowID AND s2.' + @DateFromColumnName + ' = latest.MaxDate
									GROUP BY ISNULL(s2.IdArch, s2.Id), s2.' + @DateFromColumnName + '					
								) latestWithMaxDate
								ON  ISNULL(s.IdArch, s.Id) = latestWithMaxDate.RowID AND s.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND s.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
							) allData
							WHERE allData.Rn = 1'
		
					--PRINT @Query;
					EXECUTE sp_executesql @Query;
					
					
					--posortowanie i wybranie przedzialu stronicowego pasujacych branz
					SET @Query = 'INSERT INTO #SlownikiFinal (Id)
						SELECT Id FROM
						(
							SELECT Id, ROW_NUMBER() OVER(ORDER BY ' + @OrderByClause + ') Rn							
							FROM [Slowniki] 
							WHERE Id IN (SELECT Id FROM #Slowniki)
						) X
						WHERE 1=1'
								
					IF @stronicowanieWl = 1
						SET @Query += ' AND Rn > ' + CAST(@from as varchar) + ' AND Rn <= ' + CAST(@to as varchar);
					
					--PRINT @query;
					EXECUTE sp_executesql @Query
					
					IF @RozwijajPodwezly = 1
					BEGIN
						--pobranie typu danych slownika
						SET @Query = '
								INSERT INTO #TypyDanych (Id, IdArch)
								SELECT allData.Id, allData.IdArch FROM
								(
									SELECT ct.Id, ISNULL(ct.IdArch, ct.Id) AS IdArch, ROW_NUMBER() OVER(PARTITION BY ISNULL(ct.IdArch, ct.Id) ORDER BY ct.Id ASC) AS Rn
									FROM [dbo].[Cecha_Typy] ct
									INNER JOIN
									(
										SELECT ISNULL(ct2.IdArch, ct2.Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, ct2.' + @DateFromColumnName + ' AS MaxDate
										FROM [dbo].[Cecha_Typy] ct2								 
										INNER JOIN 
										(
											SELECT ISNULL(ct3.IdArch, ct3.Id) AS RowID, MAX(ct3.' + @DateFromColumnName + ') AS MaxDate
											FROM [dbo].[Cecha_Typy] ct3
											WHERE ISNULL(ct3.IdArch, ct3.Id) IN (SELECT DISTINCT TypId FROM dbo.Slowniki s WHERE s.Id IN (SELECT Id FROM #SlownikiFinal))'									
										
						--dodanie frazy statusow na filtracje jesli trzeba
						SET @Query += [THB].[PrepareStatusesPhrase] ('ct3', @StatusS, @StatusP, @StatusW);
						
						--dodanie frazy na daty
						SET @Query += [THB].[PrepareDatesPhrase] ('ct3', @AppDate);					
									
						SET @Query += '
											GROUP BY ISNULL(ct3.IdArch, ct3.Id)
										) latest
										ON ISNULL(ct2.IdArch, ct2.Id) = latest.RowID AND ct2.' + @DateFromColumnName + ' = latest.MaxDate
										GROUP BY ISNULL(ct2.IdArch, ct2.Id), ct2.' + @DateFromColumnName + '					
									) latestWithMaxDate
									ON  ISNULL(ct.IdArch, ct.Id) = latestWithMaxDate.RowID AND ct.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND ct.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
								) allData
								WHERE allData.Rn = 1'
								
						--PRINT @query;
						EXECUTE sp_executesql @Query
					END	
							
			----------------					
					
					SET @Query = 'SET @xmlTemp = (';
				
					IF @PobierzWszystieDane IS NULL OR @PobierzWszystieDane = 0 
					BEGIN
						SET @Query += 'SELECT ISNULL(s.[IdArch], s.[Id]) AS "@Id"
										,s.[Nazwa] AS "@Name"
										,s.[TypId] AS "@DataTypeId"
										,ISNULL(s.[LastModifiedOn], s.[CreatedOn]) AS "@LastModifiedOn"'
										
						IF @RozwijajPodwezly = 1
						BEGIN
							SET @Query += '			
										, (SELECT ISNULL(ct.[IdArch], ct.[Id]) AS "@Id"
											,ct.[Nazwa] AS "@Name"
											,ct.[NazwaSQL] AS "@SQLName"
											,ct.[Nazwa_UI] AS "@UIName"
											,CASE ct.[CzyCechaUzytkownika] WHEN 1 THEN ''true'' ELSE ''false'' END AS "@IsUserAttribute"
											,ISNULL(ct.[LastModifiedOn], ct.[CreatedOn]) AS "@LastModifiedOn"
											FROM dbo.Cecha_Typy ct
											WHERE ct.[Id] = (SELECT Id FROM #TypyDanych WHERE IdArch = s.[TypId])
											FOR XML PATH (''DataType''), TYPE)'
						END		
					END
					ELSE
					BEGIN
						SET @Query += 'SELECT ISNULL(s.[IdArch], s.[Id]) AS "@Id"
								  ,s.[Nazwa] AS "@Name"
								  ,s.[TypId] AS "@DataTypeId"
								  ,ISNULL(s.[LastModifiedOn], s.[CreatedOn]) AS "@LastModifiedOn"
								  ,s.[IsDeleted] AS "@IsDeleted"
								  ,s.[DeletedFrom] AS "@DeletedFrom"
								  ,s.[DeletedBy] AS "@DeletedBy"
								  ,s.[CreatedOn] AS "@CreatedOn"
								  ,s.[CreatedBy] AS "@CreatedBy"
								  ,s.[LastModifiedBy] AS "@LastModifiedBy"
								  ,s.[ObowiazujeOd] AS "History/@EffectiveFrom"
								  ,s.[ObowiazujeDo] AS "History/@EffectiveTo"
								  ,s.[CzyPrzechowujeHistorie] AS "History/@IsMainHistFlow"
								  ,s.[IsStatus] AS "Statuses/@IsStatus"
								  ,s.[StatusS] AS "Statuses/@StatusS"
								  ,s.[StatusSFrom] AS "Statuses/@StatusSFrom"
								  ,s.[StatusSTo] AS "Statuses/@StatusSTo"
								  ,s.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
								  ,s.[StatusSToBy] AS "Statuses/@StatusSToBy"
								  ,s.[StatusW] AS "Statuses/@StatusW"
								  ,s.[StatusWFrom] AS "Statuses/@StatusWFrom"
								  ,s.[StatusWTo] AS "Statuses/@StatusWTo"
								  ,s.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
								  ,s.[StatusWToBy] AS "Statuses/@StatusWToBy"
								  ,s.[StatusP] AS "Statuses/@StatusP"
								  ,s.[StatusPFrom] AS "Statuses/@StatusPFrom"
								  ,s.[StatusPTo] AS "Statuses/@StatusPTo"
								  ,s.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
								  ,s.[StatusPToBy] AS "Statuses/@StatusPToBy"';
								  
						IF @RozwijajPodwezly = 1
						BEGIN
							SET @Query += '			
										, (SELECT ISNULL(ct.[IdArch], ct.[Id]) AS "@Id"
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
											  ,ct.[StatusPToBy] AS "Statuses/@StatusPToBy"
											FROM dbo.Cecha_Typy ct
											WHERE ct.[Id] = (SELECT Id FROM #TypyDanych WHERE IdArch = s.[TypId])
											FOR XML PATH (''DataType''), TYPE)'
						END				  
					END	 
					
					SET @Query += ' FROM [Slowniki] s
									WHERE Id IN (SELECT Id FROM #SlownikiFinal)
									ORDER BY ' 
					
					--jesli domyslne sortowanie po Id to podmiana na indeks - wymagane dla rekordow historycznych			
					IF SUBSTRING(@OrderByClause, 1, 2) = 'Id'
						SET @OrderByClause = REPLACE(@OrderByClause, 'Id', '1');
						
					SET @Query += @OrderByClause + ' FOR XML PATH(''Dictionary'') )';
					
					--PRINT @query;
					EXECUTE sp_executesql @Query, N'@xmlTemp xml OUTPUT', @xmlTemp = @xmlResponse OUTPUT
					
					--pobranie ilosci wszystkich rekordow i obliczenie ilosci stron
					SET @query = 'SET @IloscStron = (SELECT COUNT(1) FROM #Slowniki)';
					
					EXECUTE sp_executesql @Query, N'@IloscStron int OUTPUT', @IloscStron = @IloscRekordow OUTPUT

				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Dictionary_Get', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Dictionary_Get', @Wiadomosc = @ERRMSG OUTPUT
				
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH		
		END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Dictionary_Get"'
	
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
	IF OBJECT_ID('tempdb..#SlownikiFinal') IS NOT NULL
		DROP TABLE #SlownikiFinal
		
	IF OBJECT_ID('tempdb..#Slowniki') IS NOT NULL
		DROP TABLE #Slowniki 
		
	IF OBJECT_ID('tempdb..#TypyDanych') IS NOT NULL
		DROP TABLE #TypyDanych
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut

END
