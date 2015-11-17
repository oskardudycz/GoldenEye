-- =============================================
-- Author:		DK
-- Create date: 2012-03-19
-- Last modified on: 2013-02-12
-- Description:	Pobiera dane z tabeli GrupyUzytkownikow z uwzglednieniem filrów.
--•	filtr
--•	sortowanie
--•	stronicowanie

-- XML wejsciowy w postaci:

	--<Request RequestType="UserGroups_Get" GetFullColumnsData="true" UserId="1" StatusS="1" AppDate="2012-02-09T11:12:56" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<CompositeFilterDescriptor LogicalOperator="AND" xsi:noNamespaceSchemaLocation="GenericFilter.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--		<FilterDescriptor PropertyName="Id" Operator="IsGreaterThanOrEqualTo" Value="1" />
	--	</CompositeFilterDescriptor>
	--	<SortDescriptors>
	--		<SortDescriptor PropertyName="Nazwa" Direction="Descending"></SortDescriptor>
	--	</SortDescriptors>
	--	<Paging PageSize="5" PageIndex="1" />
	--</Request>

-- XM wyjsciowy w postaci:

	--<Response ResponseType="UserGroups_Get" AppDate="2012-02-09Z" xsi:noNamespaceSchemaLocation="18.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	    
	--	<UserGroup Id="1" Name="23123" LastModifiedOn="2012-02-09T12:12:12.121Z">
	--		<Users>
	--			<User Id="21" Name="12321" IsDeleted="false" Login="23" FirstName="2331" LastName="23122" Email="23132" Password="232312" IsActive="true" IsDomain="false" 
	--				LastModifiedOn="2012-02-09T12:12:12.121Z" />
	--		</Users>
	--		<Roles>
	--			<Role Id="50" Name="2312" LastModifiedOn="2012-02-09T12:12:12.121Z" />
	--		</Roles>        
	--	</UserGroup>	    
	--</Response>


-- =============================================
CREATE PROCEDURE [THB].[UserGroups_Get]
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
		IF OBJECT_ID('tempdb..#GrupyUzytkownikow') IS NOT NULL
			DROP TABLE #GrupyUzytkownikow;
			
		IF OBJECT_ID('tempdb..#GrupyUzytkownikowFinal') IS NOT NULL
			DROP TABLE #GrupyUzytkownikowFinal;
		
		CREATE TABLE #GrupyUzytkownikowFinal (Id int);
		CREATE TABLE #GrupyUzytkownikow (Id int);
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_StandardRequest', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
	
		IF @xmlOk = 0
		BEGIN
			-- co zrobic jak nie poprawna walidacja XML
			SET @ERRMSG = @ERRMSG;
		END
		ELSE
		BEGIN	
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
	
			IF @RequestType = 'UserGroups_Get'
			BEGIN
			
				BEGIN TRY
			
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
							
					--pobranie danych Id pasujacych grup uzytkownikow do tabeli tymczasowej							
					SET @Query = '
							INSERT INTO #GrupyUzytkownikow (Id)
							SELECT allData.Id FROM
							(
								SELECT gu.Id, ROW_NUMBER() OVER(PARTITION BY ISNULL(gu.IdArch, gu.Id) ORDER BY gu.Id ASC) AS Rn
								FROM [dbo].[GrupyUzytkownikow] gu
								INNER JOIN
								(
									SELECT ISNULL(gu2.IdArch, gu2.Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, gu2.' + @DateFromColumnName + ' AS MaxDate
									FROM [dbo].[GrupyUzytkownikow] gu2								 
									INNER JOIN 
									(
										SELECT ISNULL(gu3.IdArch, gu3.Id) AS RowID, MAX(gu3.' + @DateFromColumnName + ') AS MaxDate
										FROM [dbo].[GrupyUzytkownikow] gu3
										WHERE 1=1' + @StandardWhere;										
					
					IF @WhereClause IS NOT NULL
						SET @Query += [THB].PrepareSafeQuery(@WhereClause);							
									
					SET @Query += '
										GROUP BY ISNULL(gu3.IdArch, gu3.Id)
									) latest
									ON ISNULL(gu2.IdArch, gu2.Id) = latest.RowID AND gu2.' + @DateFromColumnName + ' = latest.MaxDate
									GROUP BY ISNULL(gu2.IdArch, gu2.Id), gu2.' + @DateFromColumnName + '					
								) latestWithMaxDate
								ON  ISNULL(gu.IdArch, gu.Id) = latestWithMaxDate.RowID AND gu.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND gu.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
							) allData
							WHERE allData.Rn = 1'
		
					--PRINT @Query;
					EXECUTE sp_executesql @Query;
											
---------			
					
					SET @Query = 'INSERT INTO #GrupyUzytkownikowFinal (Id)
						SELECT Id FROM
						(
							SELECT Id, ROW_NUMBER() OVER(ORDER BY ' + @OrderByClause + ') Rn							
							FROM [GrupyUzytkownikow] 
							WHERE Id IN (SELECT Id FROM #GrupyUzytkownikow)
						) X
						WHERE 1=1'
								
					IF @stronicowanieWl = 1
						SET @Query += ' AND Rn > ' + CAST(@from as varchar) + ' AND Rn <= ' + CAST(@to as varchar);
					
					--PRINT @query;
					EXECUTE sp_executesql @Query
					
--------- zapytanie o dane w postaciXML		
					SET @query = 'SET @xmlTemp = (';
					
					IF @PobierzWszystieDane IS NULL OR @PobierzWszystieDane = 0 
					BEGIN
						SET @query += 'SELECT ISNULL(gu.[IdArch], gu.[Id]) AS "@Id"
										,gu.[Nazwa] AS "@Name"
										,gu.[Opis] AS "@Description"
										,ISNULL(gu.[LastModifiedOn], gu.[CreatedOn]) AS "@LastModifiedOn"'
									
						--pobieranie danych podwezlow - rol, uzytkownikow			
						IF @RozwijajPodwezly = 1
						BEGIN
							SET @query += ', (SELECT ISNULL(u.[IdArch], u.[Id]) AS "@Id"
												,u.[Nazwa] AS "@Name"
												,u.[IsDeleted] AS "@IsDeleted"
												,u.[Login] AS "@Login"
												,u.[Imie] AS "@FirstName"
												,u.[Nazwisko] AS "@LastName"
												,u.[Email] AS "@Email"
												,[THB].[GenerateRandomText](50) AS "@Password" --ukrywamy haslo
												--,u.[Haslo] AS "@Password"
												,u.[Aktywny] AS "@IsActive"
												,u.[Domenowy] AS "@IsDomain"
												,ISNULL(u.[LastModifiedOn], u.[CreatedOn]) AS "@LastModifiedOn"
												FROM [Uzytkownicy] u
												JOIN [GrupaUzytkownikowUzytkownik] guu ON (u.Id = guu.Uzytkownik)
												WHERE (guu.GrupaUzytkownikow = gu.Id OR guu.GrupaUzytkownikow = gu.IdArch)'
																	
							--dodanie frazy na daty
							SET @Query += [THB].[PrepareDatesPhrase] ('u', @AppDate);
							SET @Query += [THB].[PrepareDatesPhrase] ('guu', @AppDate);
								
							SET @Query += [THB].[PrepareStatusesPhrase] ('u', @StatusS, @StatusP, @StatusW);
												
							SET @query += '			
												FOR XML PATH(''User''), ROOT(''Users''), TYPE
												)
											, (SELECT ISNULL(r.[IdArch], r.[Id]) AS "@Id"
												,r.[Nazwa] AS "@Name"
												,r.[Opis] AS "@Description"
												,r.[Rank] AS "@Rank"
												,ISNULL(r.[LastModifiedOn], r.[CreatedOn]) AS "@LastModifiedOn"
												FROM [Role] r
												JOIN [RolaGrupaUzytkownikow] rgu ON (r.Id = rgu.Rola)
												WHERE (rgu.GrupaUzytkownikow = gu.Id OR rgu.GrupaUzytkownikow = gu.IdArch)'
												
							--dodanie frazy na daty
							SET @Query += [THB].[PrepareDatesPhrase] ('r', @AppDate);
							SET @Query += [THB].[PrepareDatesPhrase] ('rgu', @AppDate);
								
							SET @Query += [THB].[PrepareStatusesPhrase] ('r', @StatusS, @StatusP, @StatusW);
							
							SET @Query += '						
												FOR XML PATH(''Role''), ROOT(''Roles''), TYPE
												)'					
						END																		
					END
					ELSE  -- pobranie wszystkich danych
					BEGIN
						SET @query += 'SELECT ISNULL(gu.[IdArch], gu.[Id]) AS "@Id"
									  ,gu.[Nazwa] AS "@Name"
									  ,gu.[Opis] AS "@Description"
									  ,gu.[IsDeleted] AS "@IsDeleted"
									  ,gu.[DeletedFrom] AS "@DeletedFrom"
									  ,gu.[DeletedBy] AS "@DeletedBy"
									  ,gu.[CreatedOn] AS "@CreatedOn"
									  ,gu.[CreatedBy] AS "@CreatedBy"
									  ,ISNULL(gu.[LastModifiedOn], gu.[CreatedOn]) AS "@LastModifiedOn"
									  ,gu.[LastModifiedBy] AS "@LastModifiedBy"
									  ,gu.[IsStatus] AS "Statuses/@IsStatus"
									  ,gu.[StatusS] AS "Statuses/@StatusS"
									  ,gu.[StatusSFrom] AS "Statuses/@StatusSFrom"
									  ,gu.[StatusSTo] AS "Statuses/@StatusSTo"
									  ,gu.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
									  ,gu.[StatusSToBy] AS "Statuses/@StatusSToBy"
									  ,gu.[StatusW] AS "Statuses/@StatusW"
									  ,gu.[StatusWFrom] AS "Statuses/@StatusWFrom"
									  ,gu.[StatusWTo] AS "Statuses/@StatusWTo"
									  ,gu.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
									  ,gu.[StatusWToBy] AS "Statuses/@StatusWToBy"
									  ,gu.[StatusP] AS "Statuses/@StatusP"
									  ,gu.[StatusPFrom] AS "Statuses/@StatusPFrom"
									  ,gu.[StatusPTo] AS "Statuses/@StatusPTo"
									  ,gu.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
									  ,gu.[StatusPToBy] AS "Statuses/@StatusPToBy"
									  ,gu.[ObowiazujeOd] AS "History/@EffectiveFrom"
									  ,gu.[ObowiazujeDo] AS "History/@EffectiveTo"';
									  
						--pobieranie danych podwezlow			
						IF @RozwijajPodwezly = 1
						BEGIN
							SET @query += ', (SELECT ISNULL(u.[IdArch], u.[Id]) AS "@Id"
												,u.[Nazwa] AS "@Name"
												,u.[IsDeleted] AS "@IsDeleted"
												,u.[Login] AS "@Login"
												,u.[Imie] AS "@FirstName"
												,u.[Nazwisko] AS "@LastName"
												,u.[Email] AS "@Email"
												,[THB].[GenerateRandomText](50) AS "@Password" --ukrywamy haslo
												--,u.[Haslo] AS "@Password"
												,u.[Aktywny] AS "@IsActive"
												,u.[Domenowy] AS "@IsDomain"
												,ISNULL(u.[LastModifiedOn], u.[CreatedOn]) AS "@LastModifiedOn"
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
												,u.[ObowiazujeDo] AS "History/@EffectiveTo"
												FROM [Uzytkownicy] u
												JOIN [GrupaUzytkownikowUzytkownik] guu ON (u.Id = guu.Uzytkownik)
												WHERE (guu.GrupaUzytkownikow = gu.Id OR guu.GrupaUzytkownikow = gu.IdArch)'
												
							--dodanie frazy na daty
							SET @Query += [THB].[PrepareDatesPhrase] ('u', @AppDate);
							SET @Query += [THB].[PrepareDatesPhrase] ('guu', @AppDate);
								
							SET @Query += [THB].[PrepareStatusesPhrase] ('u', @StatusS, @StatusP, @StatusW);
															
							SET @Query += '					
												FOR XML PATH(''User''), ROOT(''Users''), TYPE
												)
											, (SELECT ISNULL(r.[IdArch], r.[Id]) AS "@Id"
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
												FROM [Role] r
												JOIN [RolaGrupaUzytkownikow] rgu ON (r.Id = rgu.Rola)
												WHERE (rgu.GrupaUzytkownikow = gu.Id OR rgu.GrupaUzytkownikow = gu.IdArch)'
												
							--dodanie frazy na daty
							SET @Query += [THB].[PrepareDatesPhrase] ('r', @AppDate);
							SET @Query += [THB].[PrepareDatesPhrase] ('rgu', @AppDate);
								
							SET @Query += [THB].[PrepareStatusesPhrase] ('r', @StatusS, @StatusP, @StatusW);
							
							SET @Query += '					
												FOR XML PATH(''Role''), ROOT(''Roles''), TYPE
												)'				
						END				  				  
					END
					
					--jesli domyslne sortowanie po Id to podmiana na indeks - wymagane dla rekordow historycznych			
					IF SUBSTRING(@OrderByClause, 1, 18) = 'ISNULL(IdArch, Id)'
						SET @OrderByClause = REPLACE(@OrderByClause, 'ISNULL(IdArch, Id)', '1');					  
	
					----wybranie kreslonego zakresu wynikow jesli podano nr strony i maksymalna liczebnosc					
					SET @query += ' FROM [GrupyUzytkownikow] gu
								WHERE Id IN (SELECT DISTINCT Id FROM #GrupyUzytkownikowFinal)
								ORDER BY ' + @OrderByClause + '
								FOR XML PATH(''UserGroup'') )';			

					--PRINT @query;
					EXECUTE sp_executesql @query, N'@xmlTemp xml OUTPUT', @xmlTemp = @xmlResponse OUTPUT
					
					IF @stronicowanieWl = 1
					BEGIN
						--pobranie ilosci wszystkich rekordow i obliczenie ilosci stron
						SELECT @IloscRekordow = COUNT(1) FROM #GrupyUzytkownikow;
	
					END

				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'UserGroups_Get', @Wiadomosc = @ERRMSG OUTPUT
					
				END TRY
				BEGIN CATCH
					SET @ERRMSG = @@ERROR;
					SET @ERRMSG += ' ';
					SET @ERRMSG += ERROR_MESSAGE();
				END CATCH
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'UserGroups_Get', @Wiadomosc = @ERRMSG OUTPUT
		END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="UserGroups_Get"'
	
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

END

--usuwanie tabel tymczasowych, jesli istnieja
IF OBJECT_ID('tempdb..#GrupyUzytkownikow') IS NOT NULL
	DROP TABLE #GrupyUzytkownikow
	
IF OBJECT_ID('tempdb..#GrupyUzytkownikowFinal') IS NOT NULL
	DROP TABLE #GrupyUzytkownikowFinal

	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
