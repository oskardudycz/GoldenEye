﻿-- =============================================
-- Author:		DK
-- Create date: 2013-04-27
-- Last modified on: -
-- Description:	Zwraca liste obiektow o podanych ID (dowolnego typu) wraz z cechami.
-- Wynik zwrocony do interfejsu w formie XML'a

-- XML wejsciowy:

	--<Request RequestType="Units_GetOfType" TypeId="3" UserId="1" AppDate="2012-09-26T12:43:22" GetFullColumnsData="true" ExpandNestedValues="true"
	--	xsi:noNamespaceSchemaLocation="1.Request.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	--	<CompositeFilterDescriptor LogicalOperator="AND">
	--		<FilterDescriptor AttributeTypeId="12" Operator="IsGreaterThanOrEqualTo" Value="12" />
	--		<FilterDescriptor AttributeTypeId="33" Operator="IsEqualTo" Value="4" />
	--		<CompositeFilterDescriptor LogicalOperator="OR">
	--			<FilterDescriptor AttributeTypeId="40" Operator="IsLessThan" Value="200" />
	--			<CompositeFilterDescriptor LogicalOperator="AND">
	--				<FilterDescriptor AttributeTypeId="15" Operator="IsLessThan" Value="1" />
	--			</CompositeFilterDescriptor>
	--		</CompositeFilterDescriptor>
	--	</CompositeFilterDescriptor>
	--</Request>

-- =============================================
CREATE PROCEDURE [THB].[Units_GetOfTableType]
(	
	@XMLDataIn nvarchar(MAX),
	@RecordsCount int OUTPUT,
	@ErrorMessage nvarchar(500) OUTPUT
)
AS
BEGIN

	DECLARE @Query nvarchar(max) = '',
		@QueryColumns nvarchar(max) = '',
		@RequestType nvarchar(100),
		@TableName nvarchar(100) = 'PLATNICY',
		@xml_data xml,
		@xmlOk bit = 0,
		@xmlOut xml,
		@StatusS int,
		@StatusP int,
		@StatusW int,
		@DataProgramu datetime,
		@UzytkownikID int = NULL,
		@BranzaID int,
		@TypObiektuId int,		
		@NazwaTypuObiektu nvarchar(500),		
		@ObiektId int,
		@MaUprawnienia bit = 0,
		@RozwijajPodwezly bit = 0,
		@PobierzWszystieDane bit = 0,
		@NumerStrony int = NULL,
		@RozmiarStrony int = NULL,
		@WhereClause nvarchar(MAX),
		@OrderByClause nvarchar(500),
		@stronicowanieWl bit = 0,
		@from int,
		@to int,
		@AppDate datetime,
		@DateFromColumnName nvarchar(100),
		@StatusesForFilters nvarchar(500),
		@NazwaKolumny nvarchar(500),
		@AktualnaNazwaCechy nvarchar(500),
		@CzyTabela bit,
		@CechyWidoczneDlaUzytkownika nvarchar(MAX) = ''
	
	--walidacja poprawnosci XMLa
	EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Units_GetOfTableType', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ErrorMessage OUTPUT

	IF @xmlOk = 0
	BEGIN
		-- co zrobic jak nie poprawna walidacja XML
		SET @ErrorMessage = @ErrorMessage;
	END
	ELSE
	BEGIN
		
		--usuwanie tabel tymczasowych, jesli istnieja				
		IF OBJECT_ID('tempdb..#ObiektyMain') IS NOT NULL
			DROP TABLE #ObiektyMain
			
		IF OBJECT_ID('tempdb..#ObiektyMainFinal') IS NOT NULL
			DROP TABLE #ObiektyMainFinal
			
		IF OBJECT_ID('tempdb..#KolumnyTypuObiektu') IS NOT NULL
			DROP TABLE #KolumnyTypuObiektu	

		--poprawny XML wejsciowy
		SET @xml_data = CAST(@XMLDataIn AS xml);
		
		--wyciaganie daty i typu zadania
		SELECT	@DataProgramu = C.value('./@AppDate', 'datetime')
				,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
				,@BranzaId = C.value('./@BranchId', 'int')
				,@TypObiektuId = C.value('./@TypeId', 'int')
				,@NazwaTypuObiektu = C.value('./@Name', 'nvarchar(300)')
				,@RozwijajPodwezly = C.value('./@ExpandNestedValues', 'bit')
				,@PobierzWszystieDane = C.value('./@GetFullColumnsData', 'bit')
				,@UzytkownikID = C.value('./@UserId', 'int')
				,@StatusS =  C.value('./@StatusS','int') 
				,@StatusP = C.value('./@StatusP','int') 
				,@StatusW = C.value('./@StatusW','int') 
		FROM @xml_data.nodes('/Request') T(C) 
	
		IF @RequestType = 'Units_GetOfTableType'
		BEGIN
			BEGIN TRY
			
			-- pobranie daty na podstawie przekazanego AppDate
			SELECT @AppDate = THB.PrepareAppDate(@DataProgramu);

			--pobranie nazwy kolumny po ktorej filtrowane sa daty
			SET @DateFromColumnName = [THB].[GetDateFromFilterColumn]();
			
			SELECT @TableName = t.Nazwa, @CzyTabela = Tabela 
			FROM dbo.TypObiektu t 
			WHERE t.TypObiekt_ID = @TypObiektuId AND t.IdArch IS NULL AND t.IsValid = 1 AND t.IsDeleted = 0;
			
			--jesli typ nie jest tabelaryczny to zwracamy blad
			IF @CzyTabela = 0
			BEGIN
				SET @ErrorMessage = 'Błąd. Podany typ obiektu nie jest typem tabelarycznym.';
				SET @RecordsCount = 0;
				RETURN
			END
			
			--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji select
			EXEC [THB].[CheckUserPermission]
				@Operation = N'GET',
				@UserId = @UzytkownikID,
				@BranchId = @BranzaId,
				@Result = @MaUprawnienia OUTPUT
			
			IF @MaUprawnienia = 1
			BEGIN
			
				CREATE TABLE #ObiektyMain (Id int PRIMARY KEY, IdArch int);	
				CREATE TABLE #ObiektyMainFinal (Id int, IdArch int, Rn int);
				CREATE TABLE #KolumnyTypuObiektu(CechaId int, NazwaKolumny nvarchar(500), TypKolumny varchar(50), AktualnaNazwaCechy nvarchar(500));
			
				SET @StatusesForFilters = [THB].[PrepareStatusesPhrase] ('ch', @StatusS, @StatusP, @StatusW);			
	
				--pobranie danych filtrow, sortowania, stronicowania
				EXEC [THB].[PrepareFilters_UnitsGetOfType]
					@XMLDataIn = @XMLDataIn,
					@ObjectTypeId = @TypObiektuId,
					@ObjectType = @tableName,
					@AppDate = @AppDate,
					@IsTable = 1,
					@StatusesClause = @StatusesForFilters,
					@WhereClause = @WhereClause OUTPUT,
					@OrderByClause = @OrderByClause OUTPUT,
					@PageSize = @RozmiarStrony OUTPUT,
					@PageIndex = @NumerStrony OUTPUT,
					@ERRMSG = @ErrorMessage OUTPUT
	
				IF @NumerStrony IS NOT NULL AND @NumerStrony > 0 AND @RozmiarStrony IS NOT NULL AND @RozmiarStrony > 0
				BEGIN
					SET @from = ((@NumerStrony - 1) * @RozmiarStrony);		
					SET @to = ((@NumerStrony) * @RozmiarStrony);			
					SET @stronicowanieWl = 1;
				END
				
--SELECT @WhereClause, @OrderByClause, @RozmiarStrony, @NumerStrony,  'po filtrach'										

				--ustawienie sortowania dla funkcji rankingowych
				IF @OrderByClause IS NULL OR @OrderByClause = ''
					SET @OrderByClause = 'ISNULL(IdArch, Id) ASC';	

				IF SUBSTRING(@OrderByClause, 1, 2) = 'Id'
					SET @OrderByClause = REPLACE(@OrderByClause, 'Id', 'ISNULL(IdArch, Id)');				
					
				--jesli obiekt tabelaryczny mozmy od razu wstawic dane do tabeli finalnej w rankingiem
				SET @Query = '
					IF OBJECT_ID (N''[_' + @TableName + ']'', N''U'') IS NOT NULL
					BEGIN
						INSERT INTO #ObiektyMain (Id, IdArch)
						SELECT Id, IdArch							
						FROM [dbo].[_' + @TableName + ']
						WHERE 1=1'									
								
				IF @WhereClause IS NOT NULL
					SET @Query += [THB].PrepareSafeQuery(@WhereClause);
					
				SET @Query += [THB].[PrepareStatusesPhrase] (NULL, @StatusS, @StatusP, @StatusW);

				SET @Query += [THB].[PrepareDatesPhrase] (NULL, @AppDate);
				
				SET @Query += '
				  END';							
	
				--PRINT @Query;
				EXECUTE sp_executesql @Query;
				
				--posortowanie i wybranie przedzialu stronicowego pasujacych branz
				SET @Query = 'INSERT INTO #ObiektyMainFinal (Id, IdArch, Rn)
					SELECT Id, IdArch, Rn FROM
					(
						SELECT Id, IdArch, ROW_NUMBER() OVER(ORDER BY ' + @OrderByClause + ') Rn							
						FROM [dbo].[_' + @TableName + ']
						WHERE Id IN (SELECT Id FROM #ObiektyMain)
					) X
					WHERE 1=1'
								
				IF @stronicowanieWl = 1
					SET @Query += ' AND Rn > ' + CAST(@from as varchar) + ' AND Rn <= ' + CAST(@to as varchar);
				
				--PRINT @query;
				EXECUTE sp_executesql @Query
---
--SELECT * FROM #ObiektyMain;	
--SELECT * FROM #ObiektyMainFinal	

				SET @Query = '
					SELECT ob.Id, ob.IdArch, ob.Nazwa, ob.IsStatus, ob.[StatusS], ob.[StatusSFrom], ob.[StatusSTo], ob.[StatusSFromBy],
						ob.[StatusSToBy], ob.[StatusW], ob.[StatusWFrom], ob.[StatusWTo], ob.[StatusWFromBy], ob.[StatusWToBy], ob.[StatusP], ob.[StatusPFrom], ob.[StatusPTo],
						ob.[StatusPFromBy], ob.[StatusPToBy], ob.[ObowiazujeOd], ob.[ObowiazujeDo], ob.[IsValid], ob.[ValidFrom], ob.[ValidTo],
						ob.[IsDeleted], ob.[DeletedFrom], ob.[DeletedBy], ob.[CreatedOn], ob.[CreatedBy], ISNULL(ob.[LastModifiedOn], ob.[CreatedOn]) AS LastModifiedOn,
						ob.[LastModifiedBy], ob.[IsAlternativeHistory], ob.[IsMainHistFlow]'
				
				--dodanie do zwracanych wynikow kolumn z cechami
				IF @RozwijajPodwezly = 1
				BEGIN
				
					-- pobranie Id cech do ktorych uzytkownik ma dostep
					EXEC [THB].[GetUserAttributeTypes]
						@Alias = 'c',
						@DataProgramu = @DataProgramu,
						@UserId = @UzytkownikID,
						@BranchId = @BranzaId,
						@AtributeTypesWhere = @CechyWidoczneDlaUzytkownika OUTPUT
				
					--pobranie nazw i typow kolumn/cech na podstawie PIERWSZEJ nazwy cechy
					SET @QueryColumns = '
					INSERT INTO #KolumnyTypuObiektu (NazwaKolumny, TypKolumny, CechaId, AktualnaNazwaCechy)
					SELECT DISTINCT c.Nazwa, ct.NazwaSql, ISNULL(allData.IdArch, allData.Cecha_ID), c2.Nazwa
					FROM
					(
						SELECT c.Cecha_ID, c.IdArch, ROW_NUMBER() OVER(PARTITION BY ISNULL(c.IdArch, c.Cecha_ID) ORDER BY c.Cecha_ID ASC) AS Rn
						FROM [dbo].[Cechy] c
						INNER JOIN
						(
							SELECT ISNULL(c2.IdArch, c2.Cecha_ID) AS RowID, MIN(c2.ObowiazujeOd) AS MinDate
							FROM [dbo].[Cechy] c2							 
							JOIN dbo.TypObiektu_Cechy toc ON (c2.Cecha_Id = toc.Cecha_Id OR c2.IdArch = toc.Cecha_Id)
							WHERE toc.TypObiektu_ID = ' + CAST(@TypObiektuId AS varchar) + ' AND toc.IsDeleted = 0
							GROUP BY ISNULL(c2.IdArch, c2.Cecha_ID)
						) latestWithMaxDate
						ON ISNULL(c.IdArch, c.Cecha_ID) = latestWithMaxDate.RowID AND c.ObowiazujeOd = latestWithMaxDate.MinDate
					) allData
					JOIN dbo.Cechy c ON (c.Cecha_Id = allData.Cecha_Id)
					JOIN dbo.Cecha_Typy ct ON (c.TypId = ct.Id)
					LEFT OUTER JOIN dbo.Cechy c2 ON (ISNULL(c2.IdArch, c2.Cecha_Id) = c.IdArch)
					WHERE allData.Rn = 1 AND c2.IdArch IS NULL '
					
					IF @CechyWidoczneDlaUzytkownika IS NOT NULL
						SET @QueryColumns += @CechyWidoczneDlaUzytkownika;
						
					--PRINT @query;
					EXECUTE sp_executesql @QueryColumns
					
					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','curColumns') > 0 
					BEGIN
						 CLOSE curColumns
						 DEALLOCATE curColumns
					END
				
					DECLARE curColumns CURSOR LOCAL FOR 
						SELECT NazwaKolumny, AktualnaNazwaCechy FROM #KolumnyTypuObiektu
					OPEN curColumns
					FETCH NEXT FROM curColumns INTO @NazwaKolumny, @AktualnaNazwaCechy
					WHILE @@FETCH_STATUS = 0
					BEGIN
						
						IF @NazwaKolumny <> 'Id' AND @NazwaKolumny <> 'Nazwa'
						BEGIN
							SET @Query += ',ob.[' + @NazwaKolumny + ']';
							
							IF @AktualnaNazwaCechy IS NOT NULL AND @NazwaKolumny <> @AktualnaNazwaCechy
								SET @Query += ' AS [' + @AktualnaNazwaCechy + ']';
						END

						FETCH NEXT FROM curColumns INTO @NazwaKolumny, @AktualnaNazwaCechy
					END
					CLOSE curColumns;
					DEALLOCATE curColumns;
						
					SET @Query += '						
						FROM [dbo].[_' + @TableName + '] ob
						JOIN #ObiektyMainFinal omf ON (ob.Id = omf.Id)
						ORDER BY omf.Rn';

					--PRINT @Query;
					EXECUTE sp_executesql @Query;
					
					SELECT @RecordsCount = COUNT(Id) FROM #ObiektyMain;	
				END				
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'UNIT_TYPE_NOT_EXISTS', @Grupa = N'PROC_RESULT', @Val1 = @TypObiektuId, @Wiadomosc = @ErrorMessage OUTPUT 			
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Units_GetOfTableType', @Wiadomosc = @ErrorMessage OUTPUT 
		
			END TRY
			BEGIN CATCH
				SET @ErrorMessage = @@ERROR;
				SET @ErrorMessage += ' ';
				SET @ErrorMessage += ERROR_MESSAGE();
				
			END CATCH		
		END
		ELSE
			EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Units_GetOfTableType', @Wiadomosc = @ErrorMessage OUTPUT 
	END
	
	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

	--usuwanie tabel tymczasowych, jesli istnieja	
	IF OBJECT_ID('tempdb..#Obiekty') IS NOT NULL
		DROP TABLE #Obiekty
		
	IF OBJECT_ID('tempdb..#ObiektyMain') IS NOT NULL
		DROP TABLE #ObiektyMain
		
	IF OBJECT_ID('tempdb..#ObiektyMainFinal') IS NOT NULL
		DROP TABLE #ObiektyMainFinal
		
	IF OBJECT_ID('tempdb..#KolumnyTypuObiektu') IS NOT NULL
		DROP TABLE #KolumnyTypuObiektu

END