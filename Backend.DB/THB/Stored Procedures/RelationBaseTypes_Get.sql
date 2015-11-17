-- =============================================
-- Author:		DK
-- Create date: 2012-03-20
-- Last modified on: 2013-02-12
-- Description:	Pobiera dane z tabeli Relacja_Typ z uwzglednieniem filrów.
--•	filtr
--•	sortowanie
--•	stronicowanie

-- XML wejsciowy w postaci:

	--<Request RequestType="RelationBaseTypes_Get" GetFullColumnsData="true" UserId="1" StatusS="1" StatusP="8" StatusW="5" AppDate="2012-02-09T11:45:23" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
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
	--<Response ResponseType="RelationBaseTypes_Get" AppDate="2012-02-09">

	--<!-- ExpandNestedValues nie ma tu znaczenia -->

	--<!-- przy <Request .. GetFullColumnsData="true" .. /> -->
	--	<RelationBaseType Id="1" Name="43324423" LastModifiedOn="2012-02-09T12:12:12.121Z" IsArchive="false" ArchivedFrom="2012-02-09T12:12:12.121Z" ArchivedBy="1" IsDeleted="false" DeletedFrom="2012-02-09T12:12:12.121Z" DeletedBy="1" CreatedOn="2012-02-09T12:12:12.121Z" CreatedBy="1" LastModifiedBy="1">
	--		<History ChangeFrom="2012-02-09T12:12:12.121Z" ChangeTo="2012-02-09T12:12:12.121Z" EffectiveFrom="2012-02-09T12:12:12.121Z" EffectiveTo="2012-02-09T12:12:12.121Z" IsAlternativeHistory="false" IsMainHistFlow="false"/>
	--		<Statuses IsStatus="true" StatusSFrom="2012-02-09T12:12:12.121Z" StatusSTo="2012-02-09T12:12:12.121Z" StatusSFromBy="1" StatusSToBy="1" StatusW="?" StatusWFrom="2012-02-09T12:12:12.121Z" StatusWTo="2012-02-09T12:12:12.121Z" StatusWFromBy="1" StatusWToBy="1" StatusP="?" StatusPFrom="2012-02-09T12:12:12.121Z" StatusPTo="2012-02-09T12:12:12.121Z" StatusPFromBy="1" StatusPToBy="1"/>
	--	</RelationBaseType>
		
	--<!-- przy <Request .. GetFullColumnsData="false" .. /> -->
	--	<RelationBaseType Id="1" Name="?" LastModifiedOn="2012-02-09T12:12:12.121Z"/>
	--</Response>
-- =============================================
CREATE PROCEDURE [THB].[RelationBaseTypes_Get]
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
			IF OBJECT_ID('tempdb..#TypyRelacjiBazoweTmp') IS NOT NULL
				DROP TABLE #TypyRelacjiBazoweFinal
				
			IF OBJECT_ID('tempdb..#TypyRelacjiBazoweTmp') IS NOT NULL
				DROP TABLE #TypyRelacjiBazowe
				
			CREATE TABLE #TypyRelacjiBazoweFinal (Id int);			
			CREATE TABLE #TypyRelacjiBazoweTmp (Id int, IdArch int, IdArchLink int, ValidFrom datetime, ValidTo datetime, RealCreatedOn datetime);
			CREATE TABLE #TypyRelacjiBazowe (Id int);
			
			--poprawny XML wejsciowy
			SET @xml_data = CAST(@XMLDataIn AS xml);
			
			--wyciaganie daty i typu zadania
			SELECT	@DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
					,@BranzaId = C.value('./@BranchId', 'int')
					,@RozwijajPodwezly = C.value('./@ExpandNestedValues', 'bit')
					,@PobierzWszystieDane = C.value('./@GetFullColumnsData', 'bit')
					,@UzytkownikID = C.value('./@UserId', 'nvarchar(32)')
					,@StatusS = C.value('./@StatusS', 'int')
					,@StatusP = C.value('./@StatusP', 'int')
					,@StatusW = C.value('./@StatusW', 'int')
			FROM @xml_data.nodes('/Request') T(C) 
	
			IF @RequestType = 'RelationBaseTypes_Get'
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
						
					--pobranie danych Id pasujacych bazowych typow relacji do tabeli tymczasowej							
					SET @Query = '
							INSERT INTO #TypyRelacjiBazowe (Id)
							SELECT allData.Id FROM
							(
								SELECT rt.Id, ROW_NUMBER() OVER(PARTITION BY ISNULL(rt.IdArch, rt.Id) ORDER BY rt.Id ASC) AS Rn
								FROM [dbo].[Relacja_Typ] rt
								INNER JOIN
								(
									SELECT ISNULL(rt2.IdArch, rt2.Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, rt2.' + @DateFromColumnName + ' AS MaxDate
									FROM [dbo].[Relacja_Typ] rt2								 
									INNER JOIN 
									(
										SELECT ISNULL(rt3.IdArch, rt3.Id) AS RowID, MAX(rt3.' + @DateFromColumnName + ') AS MaxDate
										FROM [dbo].[Relacja_Typ] rt3
										WHERE 1=1'									
									
					--dodanie frazy statusow na filtracje jesli trzeba
					SET @Query += [THB].[PrepareStatusesPhrase] ('rt3', @StatusS, @StatusP, @StatusW);
					
					--dodanie frazy na daty
					SET @Query += [THB].[PrepareDatesPhrase] ('rt3', @AppDate);					
									
					IF @WhereClause IS NOT NULL
						SET @Query += [THB].PrepareSafeQuery(@WhereClause);	
									
					SET @Query += '
										GROUP BY ISNULL(rt3.IdArch, rt3.Id)
									) latest
									ON ISNULL(rt2.IdArch, rt2.Id) = latest.RowID AND rt2.' + @DateFromColumnName + ' = latest.MaxDate
									GROUP BY ISNULL(rt2.IdArch, rt2.Id), rt2.' + @DateFromColumnName + '					
								) latestWithMaxDate
								ON  ISNULL(rt.IdArch, rt.Id) = latestWithMaxDate.RowID AND rt.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND rt.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
							) allData
							WHERE allData.Rn = 1'
		
					--PRINT @Query;
					EXECUTE sp_executesql @Query;	
									
					--posortowanie i wybranie przedzialu stronicowego pasujacych branz
					SET @Query = 'INSERT INTO #TypyRelacjiBazoweFinal (Id)
						SELECT Id FROM
						(
							SELECT Id, ROW_NUMBER() OVER(ORDER BY ' + @OrderByClause + ') Rn							
							FROM [Relacja_Typ] 
							WHERE Id IN (SELECT Id FROM #TypyRelacjiBazowe)
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
						SET @query += 'SELECT ISNULL(rt.IdArch, rt.[Id]) AS "@Id"
										,rt.[Nazwa] AS "@Name"
										,ISNULL(rt.[LastModifiedOn], rt.[CreatedOn]) AS "@LastModifiedOn"'																										
					END
					ELSE --pobranie wszystkich danych
					BEGIN
						SET @query += 'SELECT ISNULL(rt.IdArch, rt.[Id]) AS "@Id"
										  ,rt.[Nazwa] AS "@Name"
										  ,rt.[IsDeleted] AS "@IsDeleted"
										  ,rt.[DeletedFrom] AS "@DeletedFrom"
										  ,rt.[DeletedBy] AS "@DeletedBy"
										  ,rt.[CreatedOn] AS "@CreatedOn"
										  ,rt.[CreatedBy] AS "@CreatedBy"
										  ,ISNULL(rt.[LastModifiedOn], rt.[CreatedOn]) AS "@LastModifiedOn"
										  ,rt.[LastModifiedBy] AS "@LastModifiedBy"
										  ,rt.[ObowiazujeOd] AS "History/@EffectiveFrom"
										  ,rt.[ObowiazujeDo] AS "History/@EffectiveTo"
										  ,rt.[IsMainHistFlow] AS "History/@IsMainHistFlow"
										  ,rt.[IsAlternativeHistory] AS "History/@IsAlternativeHistory"
										  ,rt.[IsStatus] AS "Statuses/@IsStatus"
										  ,rt.[StatusS] AS "Statuses/@StatusS"
										  ,rt.[StatusSFrom] AS "Statuses/@StatusSFrom"
										  ,rt.[StatusSTo] AS "Statuses/@StatusSTo"
										  ,rt.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
										  ,rt.[StatusSToBy] AS "Statuses/@StatusSToBy"
										  ,rt.[StatusW] AS "Statuses/@StatusW"
										  ,rt.[StatusWFrom] AS "Statuses/@StatusWFrom"
										  ,rt.[StatusWTo] AS "Statuses/@StatusWTo"
										  ,rt.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
										  ,rt.[StatusWToBy] AS "Statuses/@StatusWToBy"
										  ,rt.[StatusP] AS "Statuses/@StatusP"
										  ,rt.[StatusPFrom] AS "Statuses/@StatusPFrom"
										  ,rt.[StatusPTo] AS "Statuses/@StatusPTo"
										  ,rt.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
										  ,rt.[StatusPToBy] AS "Statuses/@StatusPToBy"';				  
					END	
					
					--jesli domyslne sortowanie po Id to podmiana na indeks - wymagane dla rekordow historycznych			
					IF SUBSTRING(@OrderByClause, 1, 2) = 'Id'
						SET @OrderByClause = REPLACE(@OrderByClause, 'Id', '1');
					
					SET @Query += ' FROM [Relacja_Typ] rt
									WHERE Id IN (SELECT Id FROM #TypyRelacjiBazoweFinal)
									ORDER BY ' + @OrderByClause + ' 
									FOR XML PATH(''RelationBaseType'') )';

					--PRINT @query;
					EXECUTE sp_executesql @query, N'@xmlTemp xml OUTPUT', @xmlTemp = @xmlResponse OUTPUT
						
					IF @stronicowanieWl = 1
					BEGIN
						--pobranie ilosci wszystkich rekordow i obliczenie ilosci stron
						SET @query = 'SET @IloscStron = (SELECT COUNT(1) FROM #TypyRelacjiBazowe)';
						
						EXECUTE sp_executesql @query, N'@IloscStron int OUTPUT', @IloscStron = @IloscRekordow OUTPUT
					END					
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'RelationBaseTypes_Get', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'RelationBaseTypes_Get', @Wiadomosc = @ERRMSG OUTPUT
				
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH	
		END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="RelationBaseTypes_Get"';
	
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
	IF OBJECT_ID('tempdb..#TypyRelacjiBazoweTmp') IS NOT NULL
		DROP TABLE #TypyRelacjiBazoweFinal
		
	IF OBJECT_ID('tempdb..#TypyRelacjiBazoweTmp') IS NOT NULL
		DROP TABLE #TypyRelacjiBazowe
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut

END
