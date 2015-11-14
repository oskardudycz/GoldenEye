-- =============================================
-- Author:		DK
-- Create date: 2012-04-04
-- Last modified on: 2012-11-29
-- Description:	Zwraca liste obiektow o podanych ID (dowolnego typu) wraz z cechami.
-- Wynik zwrocony do interfejsu w formie XML'a

-- XML wejsciowy:

	--<Request RequestType="Units_GetRelationsCount" UserId="1" AppDate="2012-09-09T11:45:22" GetFullColumnsData="true">
	--	<ObjectRef Id="1" TypeId="12" EntityType="Unit"/>
	--	<ObjectRef Id="2" TypeId="12" EntityType="Unit"/>
	--	<ObjectRef Id="3" TypeId="52" EntityType="Unit"/>
	--</Request>

-- XML wyjsciowy:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="Units_GetRelationsCount" AppDate="2012-02-09Z" xsi:noNamespaceSchemaLocation="1.4.Response.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<UnitCounter Id="1" TypeId="12" Counter="1" />
	--	<UnitCounter Id="2" TypeId="12" Counter="10" />
	--	<UnitCounter Id="3" TypeId="52" Counter="1" />
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Units_GetRelationsCount]
(	
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN

	DECLARE @Query nvarchar(max) = '',
		@RequestType nvarchar(100),
		@xml_data xml,
		@xmlOk bit = 0,
		@xmlOut xml,
		@StatusS int,
		@StatusW int,
		@StatusP int,
		@DataProgramu datetime,
		@UzytkownikID int = NULL,
		@BranzaID int,
		@TypObiektuId int,
		@ObiektId int,
		@MaUprawnienia bit = 0,
		@ERRMSG nvarchar(255),
		@AppDate datetime,
		@DateFromColumnName nvarchar(100)
	
	--usuwanie tabel tymczasowych, jesli istnieja		
	IF OBJECT_ID('tempdb..#Obiekty') IS NOT NULL
		DROP TABLE #Obiekty
		
	IF OBJECT_ID('tempdb..#RelacjeObiektow') IS NOT NULL
		DROP TABLE #RelacjeObiektow
		
	IF OBJECT_ID('tempdb..#RelacjeObiektowCopy') IS NOT NULL
		DROP TABLE #RelacjeObiektowCopy
		
	CREATE TABLE #Obiekty (TypObiektuId int, ObiektId int);	
	CREATE TABLE #RelacjeObiektow (TypObiektuId int, ObiektId int, Id int);
	CREATE TABLE #RelacjeObiektowCopy (TypObiektuId int, ObiektId int, Id int);
	
	--walidacja poprawnosci XMLa
	EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Units_GetRelationsCount', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT

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
				,@UzytkownikID = C.value('./@UserId', 'int')
				,@StatusS = C.value('./@StatusS', 'int')
				,@StatusP = C.value('./@StatusP', 'int')
				,@StatusW = C.value('./@StatusW', 'int')
		FROM @xml_data.nodes('/Request') T(C) 
	
		--wyciaganie danych obiektow do pobrania
		INSERT INTO #Obiekty (ObiektId, TypObiektuId)
		SELECT	C.value('./@Id', 'int')
			,C.value('./@TypeId', 'int')
		FROM @xml_data.nodes('/Request/ObjectRef') T(C)
		WHERE C.value('./@EntityType', 'nvarchar(50)') = 'Unit'

		IF @RequestType = 'Units_GetRelationsCount'
		BEGIN
			BEGIN TRY
			
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
				--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
				IF Cursor_Status('local','cur') > 0 
				BEGIN
					 CLOSE cur
					 DEALLOCATE cur
				END
				
				DECLARE cur CURSOR LOCAL FOR 
					SELECT DISTINCT TypObiektuId, ObiektId FROM #Obiekty
				OPEN cur
				FETCH NEXT FROM cur INTO @TypObiektuId, @ObiektId
				WHILE @@FETCH_STATUS = 0
				BEGIN
					
					DELETE FROM #RelacjeObiektowCopy;					
					
					--pobranie danych Id pasujacych relacji do tabeli tymczasowej							
					SET @Query = '
							INSERT INTO #RelacjeObiektowCopy (TypObiektuId, ObiektId, Id)
							SELECT ' + CAST(@TypObiektuId AS varchar) + ', ' + CAST(@ObiektId AS varchar) + ', allData.Id FROM
							(
								SELECT o.Id, ROW_NUMBER() OVER(PARTITION BY ISNULL(o.IdArch, o.Id) ORDER BY o.Id ASC) AS Rn
								FROM dbo.[Relacje] o
								INNER JOIN
								(
									SELECT ISNULL(o2.IdArch, o2.Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, o2.' + @DateFromColumnName + ' AS MaxDate
									FROM dbo.[Relacje] o2								 
									INNER JOIN 
									(
										SELECT ISNULL(o3.IdArch, o3.Id) AS RowID, MAX(o3.' + @DateFromColumnName + ') AS MaxDate
										FROM dbo.[Relacje] o3
										WHERE ((TypObiektuID_L = ' + CAST(@TypObiektuId AS varchar) + ' AND ObiektID_L = ' + CAST(@ObiektId AS varchar) + ') OR (TypObiektuID_R = ' 
											+ CAST(@TypObiektuId AS varchar) + ' AND ObiektID_R = ' + CAST(@ObiektId AS varchar) + '))';
										
					--dodanie frazy statusow na filtracje jesli trzeba
					SET @Query += [THB].[PrepareStatusesPhrase] ('o3', @StatusS, @StatusP, @StatusW);
					
					--dodanie frazy na daty
					SET @Query += [THB].[PrepareDatesPhrase] ('o3', @AppDate);																
									
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
					
					INSERT INTO #RelacjeObiektow(TypObiektuId, ObiektId, Id)
					SELECT TypObiektuId, ObiektId, Id FROM #RelacjeObiektowCopy;

					FETCH NEXT FROM cur INTO @TypObiektuId, @ObiektId
				END
				CLOSE cur;
				DEALLOCATE cur;
				
				SET @Query = N' SET @xmlOutVar = (
								SELECT o.[ObiektId] AS "@Id"
									,o.[TypObiektuId] AS "@TypeId"
									,COUNT(r.Id) AS "@Counter"
									FROM 
									(
										SELECT DISTINCT ObiektId, TypObiektuId FROM #Obiekty
									) o
									LEFT OUTER JOIN #RelacjeObiektow r ON (r.ObiektId = o.ObiektId AND r.TypObiektuId = o.TypObiektuId) 
								 GROUP BY o.[ObiektId], o.[TypObiektuId]
								 FOR XML PATH(''UnitCounter'')
								)' 					
				
				--PRINT @query
				EXECUTE sp_executesql @Query, N'@xmlOutVar xml OUTPUT', @xmlOutVar = @xmlOut OUTPUT		
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Units_GetRelationsCount', @Wiadomosc = @ERRMSG OUTPUT 
		
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH		
		END
		ELSE
			EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Units_GetRelationsCount', @Wiadomosc = @ERRMSG OUTPUT 
	END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Units_GetRelationsCount"';
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
	
	SET @XMLDataOut += '>';
	
	IF @ERRMSG iS NULL OR @ERRMSG = ''		
		SET @XMLDataOut += ISNULL(CAST(@xmlOut AS nvarchar(MAX)), '');
	ELSE
		SET @XMLDataOut += '<Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/>';
	
	SET @XMLDataOut += '</Response>';		

	--usuwanie tabel tymczasowych, jesli istnieja		
	IF OBJECT_ID('tempdb..#Obiekty') IS NOT NULL
		DROP TABLE #Obiekty
		
	IF OBJECT_ID('tempdb..#RelacjeObiektow') IS NOT NULL
		DROP TABLE #RelacjeObiektow
		
	IF OBJECT_ID('tempdb..#RelacjeObiektowCopy') IS NOT NULL
		DROP TABLE #RelacjeObiektowCopy
	
END
