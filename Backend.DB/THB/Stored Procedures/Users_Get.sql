-- =============================================
-- Author:		DK
-- Create date: 2012-03-16
-- Last modified on: 2013-02-12
-- Description:	Pobiera dane z tabeli Uzytkownicy z uwzglednieniem filrów.
--•	filtr
--•	sortowanie
--•	stronicowanie

-- XML wejsciowy w postaci:

	--<Request RequestType="Users_Get" GetFullColumnsData="true" UserId="1" StatusS="" StatusP="" StatusW="" AppDate="2012-02-09T12:33:34" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
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
	--<Response ResponseType="Users_Get" AppDate="2012-02-09T12:33:34" xsi:noNamespaceSchemaLocation="17.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	    
	--	<User Id="1" Login="Ewa" FirstName="Ewa" LastName="Kawka" Email="ewa@wp.pl" Password="LKOEFJ#@YHRIW" IsActive="true" IsDeleted="false" IsDomain="false" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--		<Roles>
	--			<Role Id="1" Name="Supervisor" Description="Maksymalny dostęp" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	--			<Role Id="2" Name="Administrator" Description="Administrator" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	--			<Role Id="3" Name="User" Description="Użytkownik" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	--		</Roles>
	--	</User>
	    
	--	<User Id="2" Login="Steve" FirstName="Steve" LastName="Kawka" Email="steve@wp.pl" Password="LKOyyEFJ#@YHRIW" IsActive="true" IsDeleted="false" IsDomain="false" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--		<Roles>
	--			<Role Id="1" Name="Supervisor" Description="Maksymalny dostęp" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	--			<Role Id="2" Name="Administrator" Description="Administrator" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	--			<Role Id="3" Name="User" Description="Użytkownik" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	--		</Roles>
	--	</User>
	    
	--</Response>


-- =============================================
CREATE PROCEDURE [THB].[Users_Get]
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
			IF OBJECT_ID('tempdb..#UzytkownicyFinal') IS NOT NULL
				DROP TABLE #UzytkownicyFinal
				
			IF OBJECT_ID('tempdb..#Uzytkownicy') IS NOT NULL
				DROP TABLE #Uzytkownicy
			
			CREATE TABLE #UzytkownicyFinal (Id int);			
			CREATE TABLE #Uzytkownicy (Id int);
			
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
			
			--dla pobierania rol uzytkownika
			SET @RozwijajPodwezly = 1;	
	
			IF @RequestType = 'Users_Get'
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
						SET @OrderByClause = 'ISNULL(IdArch, Id) ASC';
						
					IF SUBSTRING(@OrderByClause, 1, 2) = 'Id'
						SET @OrderByClause = REPLACE(@OrderByClause, 'Id', 'ISNULL(IdArch, Id)');
---						
					
					--pobranie danych Id pasujacych uzytkownikow do tabeli tymczasowej							
					SET @Query = '
							INSERT INTO #Uzytkownicy (Id)
							SELECT allData.Id FROM
							(
								SELECT u.Id, ROW_NUMBER() OVER(PARTITION BY ISNULL(u.IdArch, u.Id) ORDER BY u.Id ASC) AS Rn
								FROM [dbo].[Uzytkownicy] u
								INNER JOIN
								(
									SELECT ISNULL(u2.IdArch, u2.Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, u2.' + @DateFromColumnName + ' AS MaxDate
									FROM [dbo].[Uzytkownicy] u2								 
									INNER JOIN 
									(
										SELECT ISNULL(u3.IdArch, u3.Id) AS RowID, MAX(u3.' + @DateFromColumnName + ') AS MaxDate
										FROM [dbo].[Uzytkownicy] u3
										WHERE 1=1';
										
					--dodanie frazy statusow na filtracje jesli trzeba
					SET @Query += [THB].[PrepareStatusesPhrase] ('u3', @StatusS, @StatusP, @StatusW);
					
					--dodanie frazy na daty
					SET @Query += [THB].[PrepareDatesPhrase] ('u3', @AppDate);										
					
					IF @WhereClause IS NOT NULL
						SET @Query += [THB].PrepareSafeQuery(@WhereClause);							
									
					SET @Query += '
										GROUP BY ISNULL(u3.IdArch, u3.Id)
									) latest
									ON ISNULL(u2.IdArch, u2.Id) = latest.RowID AND u2.' + @DateFromColumnName + ' = latest.MaxDate
									GROUP BY ISNULL(u2.IdArch, u2.Id), u2.' + @DateFromColumnName + '					
								) latestWithMaxDate
								ON  ISNULL(u.IdArch, u.Id) = latestWithMaxDate.RowID AND u.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND u.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
							) allData
							WHERE allData.Rn = 1'
		
					--PRINT @Query;
					EXECUTE sp_executesql @Query;
					
					--posortowanie i wybranie przedzialu stronicowego pasujacych branz
					SET @Query = 'INSERT INTO #UzytkownicyFinal (Id)
						SELECT Id FROM
						(
							SELECT Id, ROW_NUMBER() OVER(ORDER BY ' + @OrderByClause + ') Rn							
							FROM [Uzytkownicy] 
							WHERE Id IN (SELECT Id FROM #Uzytkownicy)
						) X
						WHERE 1=1'
								
					IF @stronicowanieWl = 1
						SET @Query += ' AND Rn > ' + CAST(@from as varchar) + ' AND Rn <= ' + CAST(@to as varchar);
					
					--PRINT @query;
					EXECUTE sp_executesql @Query			
							  
---	zapytanie zwracajace dane jako XML				
					SET @Query = 'SET @xmlTemp = (';
				
					IF @PobierzWszystieDane = 0 OR @PobierzWszystieDane IS NULL
					BEGIN
						SET @Query += 'SELECT ISNULL(u.[IdArch], u.[Id]) AS "@Id"
										,u.[Login] AS "@Login"
										,u.[Imie] AS "@FirstName"
										,u.[Nazwisko] AS "@LastName"
										,u.[Email] AS "@Email"
										,u.[Haslo] AS "@Password"
										,u.[Aktywny] AS "@IsActive"
										,u.[IsDeleted] AS "@IsDeleted"
										,u.[Domenowy] AS "@IsDomain"
										,ISNULL(u.[LastModifiedOn], u.[CreatedOn]) AS "@LastModifiedOn"'
										
						--pobieranie danych podwezlow - rol uzytkownika			
						IF @RozwijajPodwezly = 1
						BEGIN
							SET @Query += ', (SELECT DISTINCT ISNULL(r.IdArch, r.id) AS "@Id"
												,r.[Nazwa] AS "@Name"
												,r.[Opis] AS "@Description"
												,r.[Rank] AS "@Rank"
												,ISNULL(r.[LastModifiedOn], r.[CreatedOn]) AS "@LastModifiedOn"
												FROM [GrupaUzytkownikowUzytkownik] guu
												JOIN [RolaGrupaUzytkownikow] rgu ON (rgu.GrupaUzytkownikow = guu.GrupaUzytkownikow)
												JOIN [Role] r ON (r.Id = rgu.Rola)
												WHERE guu.Uzytkownik = ISNULL(u.IdArch, u.Id)'
							
							--dodanie filtracji na statusy
							SET @Query += [THB].[PrepareStatusesPhrase] ('r', @StatusS, @StatusP, @StatusW);
					
							--dodanie frazy na daty
							SET @Query += [THB].[PrepareDatesPhrase] ('r', @AppDate);
							SET @Query += [THB].[PrepareDatesPhrase] ('guu', @AppDate);
							SET @Query += [THB].[PrepareDatesPhrase] ('rgu', @AppDate);
							
							SET @Query += '
										FOR XML PATH(''Role''), ROOT(''Roles''), TYPE
												)'					
						END																		
					END
					ELSE
					BEGIN
						--pobranie wszystkich danych uzytkownikow
						SET @Query += 'SELECT ISNULL(u.[IdArch], u.[Id]) AS "@Id"
										,u.[Login] AS "@Login"
										,u.[Imie] AS "@FirstName"
										,u.[Nazwisko] AS "@LastName"
										,u.[Email] AS "@Email"
										,u.[Haslo] AS "@Password"
										,u.[Aktywny] AS "@IsActive"
										,u.[Domenowy] AS "@IsDomain"
										,u.[IsDeleted] AS "@IsDeleted"
										,u.[DeletedFrom] AS "@DeletedFrom"
										,u.[DeletedBy] AS "@DeletedBy"
										,u.[CreatedOn] AS "@CreatedOn"
										,u.[CreatedBy] AS "@CreatedBy"
										,ISNULL(u.[LastModifiedOn], u.[CreatedOn]) AS "@LastModifiedOn"
										,u.[LastModifiedBy] AS "@LastModifiedBy"
										,u.[IsStatus] AS "Statuses/@IsStatus"
										,u.[StatusS] AS "Statuses/@StatusS"
										,u.[StatusSFrom] AS "Statuses/@StatusSFrom"
										,u.[StatusSTo] AS "Statuses/@StatusSTo"
										,u.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
										,u.[StatusSToBy] AS "Statuses/@StatusSToBy"
										,u.[StatusW] AS "Statuses/@StatusW"
										,u.[StatusWFrom] AS "Statuses/@StatusWFrom"
										,u.[StatusWTo] AS "Statuses/@StatusWTo"
										,u.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
										,u.[StatusWToBy] AS "Statuses/@StatusWToBy"
										,u.[StatusP] AS "Statuses/@StatusP"
										,u.[StatusPFrom] AS "Statuses/@StatusPFrom"
										,u.[StatusPTo] AS "Statuses/@StatusPTo"
										,u.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
										,u.[StatusPToBy] AS "Statuses/@StatusPToBy"
										,u.[ObowiazujeOd] AS "History/@EffectiveFrom"
										,u.[ObowiazujeDo] AS "History/@EffectiveTo"';
									  
						--pobieranie danych podwezlow			
						IF @RozwijajPodwezly = 1
						BEGIN
							SET @Query += ', (SELECT DISTINCT ISNULL(r.IdArch, r.id) AS "@Id"
												,r.[Nazwa] AS "@Name"
												,r.[Opis] AS "@Description"
												,r.[Rank] AS "@Rank"
												,ISNULL(r.[LastModifiedOn], r.[CreatedOn]) AS "@LastModifiedOn"
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
												,r.[StatusPToBy] AS "Statuses/@StatusPToBy"
												,r.[ObowiazujeOd] AS "History/@EffectiveFrom"
												,r.[ObowiazujeDo] AS "History/@EffectiveTo"
												FROM [GrupaUzytkownikowUzytkownik] guu
												JOIN [RolaGrupaUzytkownikow] rgu ON (rgu.GrupaUzytkownikow = guu.GrupaUzytkownikow)
												JOIN [Role] r ON (r.Id = rgu.Rola)
												WHERE guu.Uzytkownik = ISNULL(u.IdArch, u.Id)'
												
							--dodanie filtracji na statusy
							SET @Query += [THB].[PrepareStatusesPhrase] ('r', @StatusS, @StatusP, @StatusW);
					
							--dodanie frazy na daty
							SET @Query += [THB].[PrepareDatesPhrase] ('r', @AppDate);
							SET @Query += [THB].[PrepareDatesPhrase] ('guu', @AppDate);
							SET @Query += [THB].[PrepareDatesPhrase] ('rgu', @AppDate);
								
							SET @query += '		
												FOR XML PATH(''Role''), ROOT(''Roles''), TYPE
												)'				
						END		 									  
					END
					
					SET @Query += ' FROM [Uzytkownicy] u
									WHERE Id IN (SELECT Id FROM #UzytkownicyFinal)'
									
					--jesli domyslne sortowanie po Id to podmiana na indeks - wymagane dla rekordow historycznych			
					IF SUBSTRING(@OrderByClause, 1, 18) = 'ISNULL(IdArch, Id)'
						SET @OrderByClause = REPLACE(@OrderByClause, 'ISNULL(IdArch, Id)', '1');			
					
					SET @Query += ' ORDER BY ' + @OrderByClause + ' FOR XML PATH(''User'') )';

					--PRINT @query;
					EXECUTE sp_executesql @query, N'@xmlTemp xml OUTPUT', @xmlTemp = @xmlResponse OUTPUT
					
					IF @stronicowanieWl = 1
					BEGIN
						--pobranie ilosci wszystkich rekordow i obliczenie ilosci stron
						SELECT @IloscRekordow = COUNT(1) FROM #Uzytkownicy;
					END

				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Users_Get', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Users_Get', @Wiadomosc = @ERRMSG OUTPUT
				
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH			
		END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Users_Get"'
	
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
	IF OBJECT_ID('tempdb..#UzytkownicyFinal') IS NOT NULL
		DROP TABLE #UzytkownicyFinal
		
	IF OBJECT_ID('tempdb..#Uzytkownicy') IS NOT NULL
		DROP TABLE #Uzytkownicy
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut 

END
