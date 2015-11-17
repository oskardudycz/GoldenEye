-- =============================================
-- Author:		DK
-- Create date: 2012-03-21
-- Last modified on: 2013-02-12
-- Description:	Pobiera dane z tabeli Role z uwzglednieniem filrów. Pobierane sa takze operacje dla roli.
--•	filtr
--•	sortowanie
--•	stronicowanie

-- XML wejsciowy w postaci:

	--<Request RequestType="Operations_Get" GetFullColumnsData="true" UserId="1" StatusS="" StatusP="" StatusW="" AppDate="2012-02-09T09:34:21" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
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
	--<Response ResponseType="Roles_Get" AppDate="2012-02-09Z" xsi:noNamespaceSchemaLocation="19.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

	--	<!-- przy <Request .. GetFullColumnsData="false" ExpandNestedValues="true"  ../> -->
	--	<Role Id="1" Name="23312" Rank="50" Description="2331232" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--		<CouplerRoleOperation RoleId="1" OperationId="2" BranchId="12"/>
	--	</Role>
	    
	--	<!-- przy <Request .. GetFullColumnsData="false" ExpandNestedValues="false"  ../> -->
	--	<Role Id="1" Name="23312" Rank="50" Description="2331232" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	    
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Roles_Get]
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
		@RozwijajPodwezly bit = 0,
		@PobierzWszystieDane bit = 0,
		@IloscRekordow int,
		@xml_data xml,
		@xmlOk bit = 0,
		@ERRMSG nvarchar(255),
		@xmlResponse xml,
		@MaUprawnienia bit,
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
			IF OBJECT_ID('tempdb..#RoleFinal') IS NOT NULL
				DROP TABLE #RoleFinal
				
			IF OBJECT_ID('tempdb..#Role') IS NOT NULL
				DROP TABLE #Role
				
			CREATE TABLE #RoleFinal (Id int, Rn int IDENTITY(1,1) NOT NULL PRIMARY KEY);			
			CREATE TABLE #Role (Id int);			
			
			--poprawny XML wejsciowy
			SET @xml_data = CAST(@XMLDataIn AS xml);
			
			--wyciaganie daty i typu zadania
			SELECT	@DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(32)')
					,@BranzaId = C.value('./@BranchId', 'int')
					,@RozwijajPodwezly = C.value('./@ExpandNestedValues', 'bit')
					,@PobierzWszystieDane = C.value('./@GetFullColumnsData', 'bit')
					,@UzytkownikID = C.value('./@UserId', 'nvarchar(32)')
					,@StatusS = C.value('./@StatusS', 'int')
					,@StatusP = C.value('./@StatusP', 'int')
					,@StatusW = C.value('./@StatusW', 'int')
			FROM @xml_data.nodes('/Request') T(C)
		
			IF @RequestType = 'Roles_Get'
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

					--gdy podano numery stron i jej rozmiar
					IF @NumerStrony IS NOT NULL AND @NumerStrony > 0 AND @RozmiarStrony IS NOT NULL AND @RozmiarStrony > 0
					BEGIN
						SET @from = ((@NumerStrony - 1) * @RozmiarStrony);
						SET @to = ((@NumerStrony) * @RozmiarStrony);			
						SET @stronicowanieWl = 1;
					END
					
					--ustawienie sortowania dla funkcji rankingowych
					IF @OrderByClause IS NULL OR @OrderByClause = ''
						SET @OrderByClause = 'ISNULL(IdArch, Id) ASC';
						
					--jesli domyslne sortowanie po Id to podmiana na indeks - wymagane dla rekordow historycznych			
					IF SUBSTRING(@OrderByClause, 1, 2) = 'Id)'
						SET @OrderByClause = REPLACE(@OrderByClause, 'Id', 'ISNULL(IdArch, Id)');					
---
					--pobranie danych Id pasujacych rol do tabeli tymczasowej							
					SET @Query = '
							INSERT INTO #Role (Id)
							SELECT allData.Id FROM
							(
								SELECT r.Id, ROW_NUMBER() OVER(PARTITION BY ISNULL(r.IdArch, r.Id) ORDER BY r.Id ASC) AS Rn
								FROM [dbo].[Role] r
								INNER JOIN
								(
									SELECT ISNULL(r2.IdArch, r2.Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, r2.' + @DateFromColumnName + ' AS MaxDate
									FROM [dbo].[Role] r2								 
									INNER JOIN 
									(
										SELECT ISNULL(r3.IdArch, r3.Id) AS RowID, MAX(r3.' + @DateFromColumnName + ') AS MaxDate
										FROM [dbo].[Role] r3
										WHERE 1=1'
										
					--dodanie frazy statusow na filtracje jesli trzeba
					SET @Query += [THB].[PrepareStatusesPhrase] ('r3', @StatusS, @StatusP, @StatusW);
					
					--dodanie frazy na daty
					SET @Query += [THB].[PrepareDatesPhrase] ('r3', @AppDate);
					
					IF @WhereClause IS NOT NULL
						SET @Query += [THB].PrepareSafeQuery(@WhereClause);								
									
					SET @Query += '
										GROUP BY ISNULL(r3.IdArch, r3.Id)
									) latest
									ON ISNULL(r2.IdArch, r2.Id) = latest.RowID AND r2.' + @DateFromColumnName + ' = latest.MaxDate
									GROUP BY ISNULL(r2.IdArch, r2.Id), r2.' + @DateFromColumnName + '					
								) latestWithMaxDate
								ON  ISNULL(r.IdArch, r.Id) = latestWithMaxDate.RowID AND r.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND r.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
							) allData
							WHERE allData.Rn = 1'
		
					--PRINT @Query;
					EXECUTE sp_executesql @Query;
					
					--posortowanie i wybranie przedzialu stronicowego pasujacych branz
					SET @Query = 'INSERT INTO #RoleFinal (Id)
						SELECT Id FROM
						(
							SELECT Id, ROW_NUMBER() OVER(ORDER BY ' + @OrderByClause + ') Rn							
							FROM [Role] 
							WHERE Id IN (SELECT Id FROM #Role)
						) X
						WHERE 1=1'
					
					--wybranie kreslonego zakresu wynikow jesli podano nr strony i maksymalna liczebnosc			
					IF @stronicowanieWl = 1
						SET @query += ' AND Rn > ' + CAST(@from as varchar) + ' AND Rn <= ' + CAST(@to as varchar);
					
					--PRINT @query;
					EXECUTE sp_executesql @query												
---		 
					
					SET @Query += 'SET @xmlTemp = ('
					
					IF @PobierzWszystieDane IS NULL OR @PobierzWszystieDane = 0
					BEGIN
					
						SET @query += '
							SELECT ISNULL(r.[IdArch], r.[Id]) AS "@Id"
								,r.[Nazwa] AS "@Name"
								,r.[Opis] AS "@Description"
								,r.[Rank] AS "@Rank"
								,ISNULL(r.[LastModifiedOn], r.[CreatedOn]) AS "@LastModifiedOn"'
						
						IF @RozwijajPodwezly = 1
						BEGIN
						
							SET @query += '
										, (SELECT ro.[Rola] AS "@RoleId"
											,ro.[Operacja] AS "@OperationId"
											,ro.[Branza] AS "@BranchId"
											--, (SELECT r2.[Id] AS "@Id"
											--	,r2.[Nazwa] AS "@Name"
											--	,r2.[Opis] AS "@Description"
											--	,r2.[Rank] AS "@Rank"
											--	,ISNULL(r2.[LastModifiedOn], r2.[CreatedOn]) AS "@LastModifiedOn"
											--	FROM [Role] r2
											--	WHERE r2.Id = ro.Rola
											--	FOR XML PATH(''Role''), TYPE)										
											--, (SELECT o.[Id] AS "@Id"
											--	,o.[Nazwa] AS "@Name"
											--	,o.[Opis] AS "@Description"
											--	,ISNULL(o.[LastModifiedOn], o.[CreatedOn]) AS "@LastModifiedOn"
											--	FROM [Operacje] o
											--	WHERE o.Id = ro.Operacja
											--	FOR XML PATH(''Operation''), TYPE)										
											--, (SELECT b.[Id] AS "@Id"
											--	,b.[Nazwa] AS "@Name"
											--	,ISNULL(b.[LastModifiedOn], b.[CreatedOn]) AS "@LastModifiedOn"
											--	FROM [Branze] b
											--	WHERE b.Id = ro.Branza
											--	FOR XML PATH(''Branch''), TYPE)									
											FROM [RolaOperacja] ro
											WHERE (ro.Rola = r.Id OR ro.Rola = r.IdArch)
										FOR XML PATH(''CouplerRoleOperation''), TYPE)'
					
						END
					END
					ELSE --pobranie wszystkich danych
					BEGIN
						
						SET @query += '
								SELECT ISNULL(r.[IdArch], r.[Id]) AS "@Id"
									,r.[Nazwa] AS "@Name"
									,r.[Opis] AS "@Description"
									,r.[Rank] AS "@Rank"
									,r.[IsDeleted] AS "@IsDeleted"
									,r.[DeletedFrom] AS "@DeletedFrom"
									,r.[DeletedBy] AS "@DeletedBy"
									,r.[CreatedOn] AS "@CreatedOn"
									,r.[CreatedBy] AS "@CreatedBy"
									,ISNULL([LastModifiedOn], [CreatedOn]) AS "@LastModifiedOn"
									,r.[LastModifiedBy] AS "@LastModifiedBy"
									,r.[ObowiazujeOd] AS "History/@EffectiveFrom"
									,r.[ObowiazujeDo] AS "History/@EffectiveTo"
									,r.[IsAlternativeHistory] AS "History/@IsAlternativeHistory"
									,r.[IsMainHistFlow] AS "History/@IsMainHistFlow"
									,r.[IsStatus] AS "Statuses/@IsStatus"
									,r.[StatusS] AS "Statuses/@StatusS"
									,r.[StatusSFrom] AS "Statuses/@StatusSFrom"
									,r.[StatusSTo] AS "Statuses/@StatusSTo"
									,r.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
									,r.[StatusSToBy] AS "Statuses/@StatusSToBy"
									,r.[StatusW] AS "Statuses/@StatusW"
									,r.[StatusWFrom] AS "Statuses/@StatusWFrom"
									,r.[StatusWTo] AS "Statuses/@StatusWTo"
									,r.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
									,r.[StatusWToBy] AS "Statuses/@StatusWToBy"
									,r.[StatusP] AS "Statuses/@StatusP"
									,r.[StatusPFrom] AS "Statuses/@StatusPFrom"
									,r.[StatusPTo] AS "Statuses/@StatusPTo"
									,r.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
									,r.[StatusPToBy] AS "Statuses/@StatusPToBy"'					
						
						IF @RozwijajPodwezly = 1
						BEGIN
						
							SET @query += '
										, (SELECT ro.[Rola] AS "@RoleId"
											,ro.[Operacja] AS "@OperationId"
											,ro.[Branza] AS "@BranchId"
											--, (SELECT r2.[Id] AS "@Id"
											--	,r2.[Nazwa] AS "@Name"
											--	,r2.[Opis] AS "@Description"
											--	,r2.[Rank] AS "@Rank"
											--	,ISNULL(r2.[LastModifiedOn], r2.[CreatedOn]) AS "@LastModifiedOn"
											--	FROM [Role] r2
											--	WHERE r2.Id = ro.Rola
											--	FOR XML PATH(''Role''), TYPE)										
											--, (SELECT o.[Id] AS "@Id"
											--	,o.[Nazwa] AS "@Name"
											--	,o.[Opis] AS "@Description"
											--	,ISNULL(o.[LastModifiedOn], o.[CreatedOn]) AS "@LastModifiedOn"
											--	FROM [Operacje] o
											--	WHERE o.Id = ro.Operacja
											--	FOR XML PATH(''Operation''), TYPE)										
											--, (SELECT b.[Id] AS "@Id"
											--	,b.[Nazwa] AS "@Name"
											--	,ISNULL(b.[LastModifiedOn], b.[CreatedOn]) AS "@LastModifiedOn"
											--	FROM [Branze] b
											--	WHERE b.Id = ro.Branza
											--	FOR XML PATH(''Branch''), TYPE)									
											FROM [RolaOperacja] ro
											WHERE (ro.Rola = r.Id OR ro.Rola = r.IdArch)
										FOR XML PATH(''CouplerRoleOperation''), TYPE)'					
						END
					
					END
					
					--jesli domyslne sortowanie po Id to podmiana na indeks - wymagane dla rekordow historycznych			
					IF SUBSTRING(@OrderByClause, 1, 18) = 'ISNULL(IdArch, Id)'
						SET @OrderByClause = REPLACE(@OrderByClause, 'ISNULL(IdArch, Id)', '1');			

					SET @Query += '
									FROM [Role] r
									WHERE Id IN (SELECT ID FROM #RoleFinal)				  
									ORDER BY ' + @OrderByClause + ' FOR XML PATH(''Role'') )';
					
					--PRINT @query;
					EXECUTE sp_executesql @query, N'@xmlTemp xml OUTPUT', @xmlTemp = @xmlResponse OUTPUT
					
					--pobranie ilosci wszystkich rekordow i obliczenie ilosci stron
					SELECT @IloscRekordow = COUNT(1) FROM #Role;
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Roles_Get', @Wiadomosc = @ERRMSG OUTPUT 		
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Roles_Get', @Wiadomosc = @ERRMSG OUTPUT 
		
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH
		END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Roles_Get"';
	
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
	IF OBJECT_ID('tempdb..#RoleFinal') IS NOT NULL
		DROP TABLE #RoleFinal
		
	IF OBJECT_ID('tempdb..#Role') IS NOT NULL
		DROP TABLE #Role
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut

END
