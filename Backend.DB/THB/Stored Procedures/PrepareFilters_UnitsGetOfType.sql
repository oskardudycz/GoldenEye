-- =============================================
-- Author:		DK
-- Create date: 2012-03-27
-- Last modified on: 2013-04-10
-- Description:	Zwraca warunek WHERE na podstawie XMLa z filtrami
-- =============================================
CREATE PROCEDURE [THB].[PrepareFilters_UnitsGetOfType]
(
	@XMLDataIn nvarchar(MAX),
	@ObjectTypeId int,
	@ObjectType nvarchar(500),
	@AppDate datetime,
	@IsTable bit = 0,
	@StatusesClause nvarchar(300),
	@WhereClause nvarchar(MAX) OUTPUT,
	@OrderByClause nvarchar(300) OUTPUT,
	@PageSize int OUTPUT,
	@PageIndex int OUTPUT,
	@ERRMSG nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @AttributeTypeId int,
			@PropertyName nvarchar(500),
			@Direction nvarchar(20),
			@DirectionSQL nvarchar (4),
			@xml_data xml,
			@xmlOk bit = 0,
			@Level1MainOperator varchar(3),
			@Level2MainOperator varchar(3),
			@Level3MainOperator varchar(3),
			@Operator varchar(25),
			@Value nvarchar(MAX),
			@TmpWhere nvarchar(MAX),
			@i int = 0,
			@i2 int = 0,
			@i3 int = 0,
			@IloscFiltrow int = 0,
			@iloscComposite1Poziom int = 0,
			@iloscComposit2Poziom int = 0,
			@counter int = 0,
			@counter2 int = 0,
			@Query nvarchar(MAX),
			@Obiekty nvarchar(MAX),
			@WhereClauseTmp nvarchar(MAX) = '',
			@Table IdsTable,
			@IloscWszystkichFiltrow int = 0,
			@ActualDate bit,
			
			@NazwaKolumny nvarchar(500),
			@UnitTypeColumns nvarchar(MAX) = '',
			@CechaIdKolumny int,
			@TypKolumny nvarchar(100),
			@WartoscCechy nvarchar(MAX),
			@WartoscCechyString nvarchar(MAX),
			@WartoscCechyXml nvarchar(MAX),
			@ObiektIdDlaCechy int,			
			@TypCechyID int,
			@CzySlownik bit,
			@ValueCechyObiektu nvarchar(MAX),
			@DateFromColumnName nvarchar(100) = '',
			@AttributeTypeName nvarchar(500),
			@SaFiltry1Poziom bit = 0,
			@SaFiltry2Poziom bit = 0

	--BEGIN TRY
		SET @ERRMSG = NULL;
		SET @WhereClause = '';
		SET @WhereClauseTmp = '';
		SET @OrderByClause = '';
		
		--usuwanie tabel tymczasowych, jesli istnieja
		IF OBJECT_ID('tempdb..#Sortowanie') IS NOT NULL
			DROP TABLE #Sortowanie
			
		IF OBJECT_ID('tempdb..#Filtrowanie1') IS NOT NULL
			DROP TABLE #Filtrowanie1
			
		IF OBJECT_ID('tempdb..#Filtrowanie2') IS NOT NULL
			DROP TABLE #Filtrowanie2
			
		IF OBJECT_ID('tempdb..#Filtrowanie3') IS NOT NULL
			DROP TABLE #Filtrowanie3
			
		IF OBJECT_ID('tempdb..#ObiektyID') IS NOT NULL
			DROP TABLE #ObiektyID
			
		IF OBJECT_ID('tempdb..#Cechy') IS NOT NULL
			DROP TABLE #Cechy
			
		IF OBJECT_ID('tempdb..#KolumnyTypuObiektuFilters') IS NOT NULL
			DROP TABLE #KolumnyTypuObiektuFilters
			
		IF OBJECT_ID('tempdb..#CechyTypuObiektuFilters') IS NOT NULL
			DROP TABLE #CechyTypuObiektuFilters
			
		IF OBJECT_ID('tempdb..##CechyTabelaryczne_GetOfTypeFilters') IS NOT NULL
			DROP TABLE ##CechyTabelaryczne_GetOfTypeFilters
		
		CREATE TABLE #ObiektyID (ObiektId int);
		CREATE TABLE #Filtrowanie3 (LogicalOperator varchar(20), AttributeTypeId int, Operator nvarchar(30), Value nvarchar(255), [Index] int, RootId int);
		CREATE TABLE #Cechy(Id int, RelacjaId int, CechaId int, TypCechyId int, CzySlownik bit, SparceValue xml, ValString nvarchar(MAX), ValueType nvarchar(20), Value nvarchar(MAX));
		CREATE TABLE #CechyTypuObiektuFilters(Id int, ObiektId int, CechaId int, TypCechyId int, CzySlownik bit, SparseValue xml, ValString nvarchar(MAX), ValueType nvarchar(MAX), Value nvarchar(MAX));	
		CREATE TABLE #KolumnyTypuObiektuFilters(CechaId int, NazwaKolumny nvarchar(150), TypKolumny varchar(50));
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Units_GetOfType', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT

		IF @xmlOk = 0
		BEGIN
			SET @ERRMSG = @ERRMSG
			--EXEC dbo.Variables_Display 'XML_KO','PROC_RESULT', @STATUS OUT, @_typ OUT
		END
		ELSE
		BEGIN	
			SET @xml_data = CAST(@XMLDataIn AS xml);

			SELECT @ActualDate = THB.IsActualDate(@AppDate);			
			
			--wyciaganie danych stronicowania
			SELECT @PageSize = C.value('./@PageSize', 'int')
					,@PageIndex = C.value('./@PageIndex', 'int')  --(./text())[1]', 'int')
			FROM @xml_data.nodes('/Request/Paging') T(C)
			
			--odczytywanie danych sortowania
			SELECT C.value('./@PropertyName','nvarchar(200)') AS PropertyName
				,C.value('./@Direction', 'nvarchar(15)') AS Direction
			INTO #Sortowanie 
			FROM @xml_data.nodes('/Request/SortDescriptors/SortDescriptor') T(C)
			
			--pobranie nazwy kolumny po ktorej filtrowane sa daty
			SET @DateFromColumnName = [THB].[GetDateFromFilterColumn]();	

			IF @ObjectType IS NOT NULL
			BEGIN
			
				--przygotowanie frazy ORDER BY
				IF (SELECT COUNT(1) FROM #Sortowanie) > 0
				BEGIN			
					--SET @OrderByClause = ' ORDER BY ';
				
					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','cur') > 0 
					BEGIN
						 CLOSE cur
						 DEALLOCATE cur
					END
				
					DECLARE cur CURSOR LOCAL FOR 
						SELECT PropertyName, Direction FROM #Sortowanie
					OPEN cur
					FETCH NEXT FROM cur INTO @PropertyName, @Direction
					WHILE @@FETCH_STATUS = 0
					BEGIN
						--zmiana nazwy property z EN na PL
						SET @PropertyName = THB.ChangePropertyNameFromENToPL(@PropertyName);
						
						--zmiana LastModifiedOn na CreatedOn
						IF @PropertyName = 'LastModifiedOn'
							SET @PropertyName = 'CreatedOn'
						
						IF @Direction = 'Ascending'
							SET @DirectionSQL = 'ASC'
						ELSE
							SET @DirectionSQL = 'DESC'
					
						SET @OrderByClause += @PropertyName + ' ' + @DirectionSQL + ',';				

						FETCH NEXT FROM cur INTO @PropertyName, @Direction
					END
					CLOSE cur
					DEALLOCATE cur
					
					--usuniecie ostatniego przecinka z frazy ORDER BY
					SET @OrderByClause = SUBSTRING(@OrderByClause, 1, LEN(@OrderByClause) - 1);
					
				END			

				--odczytanie ilosci composti filtrow 1 poziomu
				SET @iloscComposite1Poziom = (SELECT @xml_data.value('count(/Request/CompositeFilterDescriptor/CompositeFilterDescriptor)','int') )
					
				--odczytywanie danych filtrowania
				SELECT	@Level1MainOperator = C.value('./@LogicalOperator', 'varchar(3)')
				FROM @xml_data.nodes('/Request/CompositeFilterDescriptor') T(C) 
		
				--1 poziomu
				SELECT	C.value('./@AttributeTypeId', 'int') AS AttributeTypeId
						,C.value('./@Operator', 'nvarchar(25)') AS Operator
						,C.value('./@Value', 'nvarchar(255)') AS Value
				INTO #Filtrowanie1
				FROM @xml_data.nodes('/Request/CompositeFilterDescriptor/FilterDescriptor') T(C);			 
				
				--2 poziomu		
				WITH Num(j)
				AS
				(
				   SELECT 1
				   UNION ALL
				   SELECT j + 1
				   FROM Num
				   WHERE j < (SELECT @xml_data.value('count(/Request/CompositeFilterDescriptor/CompositeFilterDescriptor)','int') )
				)
				SELECT x.value('../@LogicalOperator', 'varchar(20)') AS 'LogicalOperator'
					   ,x.value('./@AttributeTypeId', 'int') AS 'AttributeTypeId'
					   ,x.value('./@Operator', 'nvarchar(30)') AS 'Operator'
					   ,x.value('./@Value', 'nvarchar(255)') AS 'Value'
					   ,j AS 'Index'
				INTO #Filtrowanie2
				FROM Num
				CROSS APPLY @xml_data.nodes('/Request/CompositeFilterDescriptor/CompositeFilterDescriptor[position()=sql:column("j")]/FilterDescriptor')  e(x);	
				
				--wyciaganie danych 3 poziomu			
				SET @counter = 1;				
				
				WHILE @counter <= @iloscComposite1Poziom
				BEGIN
					SET @Query = '
						WITH Num2(j)
						AS
						(
						   SELECT 1
						   UNION ALL
						   SELECT j + 1
						   FROM Num2
						   WHERE j < (SELECT @xml_data.value(''count(/Request/CompositeFilterDescriptor/CompositeFilterDescriptor[position()=' + CAST(@counter AS varchar) + ']/CompositeFilterDescriptor)'', ''int'') )
						)	
							
						INSERT INTO #Filtrowanie3 (LogicalOperator, AttributeTypeId, Operator, Value, [Index], RootId)
						SELECT x.value(''../@LogicalOperator'', ''varchar(20)'')
							   ,x.value(''./@AttributeTypeId'', ''int'')
							   ,x.value(''./@Operator'', ''nvarchar(30)'')
							   ,x.value(''./@Value'', ''nvarchar(255)'')
							   ,j
							   ,' + CAST(@counter AS varchar) + '
						FROM Num2
						CROSS APPLY @xml_data.nodes(''/Request/CompositeFilterDescriptor/CompositeFilterDescriptor[position()=' + CAST(@counter AS varchar) + ']/CompositeFilterDescriptor[position()=sql:column("j")]/FilterDescriptor'')  e(x);	
					';

					--PRINT @Query
					EXEC sp_executesql @Query, N'@xml_data xml', @xml_data = @xml_data
				
					SET @counter = @counter + 1; 
				END				
				
--SELECT * FROM #Filtrowanie1;
--SELECT * FROM #Filtrowanie2;
--SELECT * FROM #Filtrowanie3;
			
				IF (SELECT COUNT(1) FROM #Filtrowanie1) > 0
					SET @SaFiltry1Poziom = 1;
				ELSE
					SET @SaFiltry1Poziom = 0;
				
				IF (SELECT COUNT(1) FROM #Filtrowanie2) > 0
					SET @SaFiltry2Poziom = 1;
				ELSE
					SET @SaFiltry2Poziom = 0;
				
				IF @SaFiltry1Poziom = 1 OR @SaFiltry2Poziom = 1
				BEGIN
					--pobranie cech
					IF @IsTable = 0			
					BEGIN
						--pobranie wszystkich cech dla podanego typu obiektu
						SET @Query = 'INSERT INTO #CechyTypuObiektuFilters(Id, ObiektId, CechaId, TypCechyId, CzySlownik, SparseValue, ValString, ValueType, Value)					
						SELECT ch.Id, ch.ObiektId, ch.CechaId, c.TypID, c.CzySlownik, [THB].GetAttributeValueFromSparseXML(ch.ColumnsSet), ch.ValString,
							--ISNULL([THB].GetAttributeValueTypeFromSparseXML(ch.ColumnsSet), ''nvarchar''),
							--ISNULL([THB].GetAttributeValueValueFromSparseXML(ch.ColumnsSet), ch.ValString)
							ch.ValString, [THB].GetAttributeFilterValue(ch.ColumnsSet, ch.ValString)
						FROM [dbo].[_' + @ObjectType + '_Cechy_Hist] ch
						
						INNER JOIN
						(
							SELECT ISNULL(ch2.IdArch, ch2.Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, ch2.' + @DateFromColumnName + ' AS MaxDate
							FROM [dbo].[_' + @ObjectType + '_Cechy_Hist] ch2	
							INNER JOIN 
							(
								SELECT ISNULL(ch3.IdArch, ch3.Id) AS RowID, MAX(ch3.' + @DateFromColumnName + ') AS MaxDate
								FROM [dbo].[_' + @ObjectType + '_Cechy_Hist] ch3
								WHERE 1=1';
											
						--dodanie frazy na daty
						SET @Query += [THB].[PrepareDatesPhrase] ('ch3', @AppDate);
						
						--IF @WhereClause IS NOT NULL
						--	SET @Query += [THB].PrepareSafeQuery(@WhereClause)																
						
						SET @Query += '
									GROUP BY ISNULL(ch3.IdArch, ch3.Id)
								) latest
								ON ISNULL(ch2.IdArch, ch2.Id) = latest.RowID AND ch2.' + @DateFromColumnName + ' = latest.MaxDate
								GROUP BY ISNULL(ch2.IdArch, ch2.Id), ch2.' + @DateFromColumnName + '					
							) latestWithMaxDate
						ON  ISNULL(ch.IdArch, ch.Id) = latestWithMaxDate.RowID AND ch.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND ch.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
						
						
						JOIN dbo.[Cechy] c ON (c.Cecha_ID = ch.CechaID)
						WHERE 1=1' --ch.IdArch IS NULL	AND ch.IsValid = 1';
					
						SET @Query += [THB].[PrepareDatesPhrase] ('ch', @AppDate);
						
						IF @StatusesClause IS NOT NULL
							SET @Query += @StatusesClause;
						
						--PRINT @Query;
						EXECUTE sp_executesql @Query;
							
					END
					ELSE --obiekt tabelaryczny
					BEGIN
						--pobranie nazw i typow kolumn/cech na podstawie PIERWSZEJ nazwy cechy
						INSERT INTO #KolumnyTypuObiektuFilters (NazwaKolumny, TypKolumny, CechaId)
						SELECT DISTINCT c.Nazwa, ct.NazwaSql, ISNULL(allData.IdArch, allData.Cecha_ID)
						FROM
						(
							SELECT c.Cecha_ID, c.IdArch, ROW_NUMBER() OVER(PARTITION BY ISNULL(c.IdArch, c.Cecha_ID) ORDER BY c.Cecha_ID ASC) AS Rn
							FROM [dbo].[Cechy] c
							INNER JOIN
							(
								SELECT ISNULL(c2.IdArch, c2.Cecha_ID) AS RowID, MIN(c2.ObowiazujeOd) AS MinDate
								FROM [dbo].[Cechy] c2							 
								JOIN dbo.TypObiektu_Cechy toc ON (c2.Cecha_Id = toc.Cecha_Id OR c2.IdArch = toc.Cecha_Id)
								WHERE toc.TypObiektu_ID = @ObjectTypeId AND toc.IsDeleted = 0
								GROUP BY ISNULL(c2.IdArch, c2.Cecha_ID)
							) latestWithMaxDate
							ON ISNULL(c.IdArch, c.Cecha_ID) = latestWithMaxDate.RowID AND c.ObowiazujeOd = latestWithMaxDate.MinDate
						) allData
						JOIN dbo.Cechy c ON (c.Cecha_Id = allData.Cecha_Id)
						JOIN dbo.Cecha_Typy ct ON (c.TypId = ct.Id) 
						WHERE allData.Rn = 1
						
--SELECT * FROM #KolumnyTypuObiektuFilters
					
					END	
				
				END

--SELECT * FROM #CechyTypuObiektuFilters
				
				--obliczenie ilosci wszystkich filtrow
				SET @IloscWszystkichFiltrow += (SELECT COUNT(1) FROM #Filtrowanie1);
				SET @IloscWszystkichFiltrow += (SELECT COUNT(1) FROM #Filtrowanie2);
				SET @IloscWszystkichFiltrow += (SELECT COUNT(1) FROM #Filtrowanie3);
				SET @Query = '';
				SET @TmpWhere = '';
				
				IF @IloscWszystkichFiltrow > 0
					SET @WhereClauseTmp += ' AND ('
				
				IF @SaFiltry1Poziom = 1
				BEGIN	
					
--SELECT * FROM #CechyTypuObiektuFilters									
					--IF @IloscWszystkichFiltrow > 0
					--	SET @WhereClauseTmp += ' AND (';					
				
					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','cur') > 0 
					BEGIN
						 CLOSE cur
						 DEALLOCATE cur
					END
				
					IF @Level1MainOperator = 'OR'
					BEGIN
						IF @IsTable = 0
						BEGIN
							SET @Query = '
										INSERT INTO #ObiektyID
										SELECT ObiektId FROM #CechyTypuObiektuFilters
										WHERE 1=1 AND ('
						END
						ELSE
						BEGIN
							SET @Query = '
										INSERT INTO #ObiektyID
										SELECT Id FROM [_' + @ObjectType + ']
										WHERE 1=1 AND ('
						END
					END
				
					DECLARE cur CURSOR LOCAL FOR 
						SELECT AttributeTypeId, Operator, Value FROM #Filtrowanie1
					OPEN cur
					FETCH NEXT FROM cur INTO @AttributeTypeId, @Operator, @Value
					WHILE @@FETCH_STATUS = 0
					BEGIN						
						IF @IsTable = 0
						BEGIN
							--pobranie kawalka frazy where dla podanych parametrow
							EXEC [THB].[CheckOperatorAndValue_Relations_Get] @AttributeTypeId = @AttributeTypeId, @Operator = @Operator, @Value = @Value, @Result = @TmpWhere OUTPUT			
						END
						ELSE
						BEGIN
							SELECT @AttributeTypeName = NazwaKolumny FROM #KolumnyTypuObiektuFilters WHERE CechaId = @AttributeTypeId
											
							EXEC [THB].[CheckOperatorAndValue_TableTypes] @AttributeTypeId = @AttributeTypeId, @AttributeTypeName = @AttributeTypeName, @Operator = @Operator, @Value = @Value, @Result = @TmpWhere OUTPUT	
						END						

					
						--dodawanie 1 poziomu zaglebienia warunkow filtracji
						IF @TmpWhere IS NOT NULL AND LEN(@TmpWhere) > 2
						BEGIN
							--typ obiektu "normalny"
							IF @IsTable = 0						
							BEGIN
								IF @Level1MainOperator = 'OR'
								BEGIN
									SET @Query += @TmpWhere + ' ' + @Level1MainOperator;
								END
								ELSE
								BEGIN
								
									SET @Query += '
												INSERT INTO #ObiektyID
												SELECT ObiektId FROM #CechyTypuObiektuFilters
												WHERE 1=1 ' + @Level1MainOperator + ' ' + @TmpWhere + ';';
								END
							END
							ELSE --typ obiektu tabelaryczny
							BEGIN
							
								IF @Level1MainOperator = 'OR'
								BEGIN
									SET @Query += @TmpWhere + ' ' + @Level1MainOperator;
								END
								ELSE
								BEGIN
								
									SET @Query += '
												INSERT INTO #ObiektyID
												SELECT Id FROM [_' + @ObjectType + ']
												WHERE 1=1 ' + @Level1MainOperator + ' ' + @TmpWhere + ';';
								END
							
							END 
							
							--PRINT @query;
							--EXECUTE sp_executesql @Query;
						END
						
						SET @IloscFiltrow += 1;
					
						FETCH NEXT FROM cur INTO @AttributeTypeId, @Operator, @Value
					END
					CLOSE cur
					DEALLOCATE cur	
					
					IF @Level1MainOperator = 'OR'
					BEGIN
						SET @Query = SUBSTRING(@Query, 1, LEN(@Query) - 3);
						SET @Query += ')';
					END
					
--PRINT @Query;
					EXECUTE sp_executesql @Query;				
	
				END
		
				IF @SaFiltry2Poziom = 1
				BEGIN
					
					SET @counter = 1;
					WHILE @counter <= @iloscComposite1Poziom
					BEGIN
					
						--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
						IF Cursor_Status('local','cur') > 0 
						BEGIN
							 CLOSE cur
							 DEALLOCATE cur
						END
						
						SET @i = 0;	
						
						--IF @IsTable = 0				
						--	SET @WhereClauseTmp = '(('; --byl pojedynczy
						--ELSE
						--	SET @WhereClauseTmp = '(';
							
						IF @SaFiltry1Poziom = 1
							SET @WhereClauseTmp = '((';
						ELSE
							SET @WhereClauseTmp = '(';
					
						DECLARE cur CURSOR LOCAL FOR 
							SELECT LogicalOperator, AttributeTypeId, Operator, Value FROM #Filtrowanie2 WHERE [Index] = @counter
						OPEN cur
						FETCH NEXT FROM cur INTO @Level2MainOperator, @AttributeTypeId, @Operator, @Value
						WHILE @@FETCH_STATUS = 0
						BEGIN
							IF @IsTable = 0
							BEGIN
								--pobranie kawalka frazy where dla podanych parametrow
								EXEC [THB].[CheckOperatorAndValue_Relations_Get] @AttributeTypeId = @AttributeTypeId, @Operator = @Operator, @Value = @Value, @Result = @TmpWhere OUTPUT			
							END
							ELSE
							BEGIN
								SELECT @AttributeTypeName = NazwaKolumny FROM #KolumnyTypuObiektuFilters WHERE CechaId = @AttributeTypeId
												
								EXEC [THB].[CheckOperatorAndValue_TableTypes] @AttributeTypeId = @AttributeTypeId, @AttributeTypeName = @AttributeTypeName, @Operator = @Operator, @Value = @Value, @Result = @TmpWhere OUTPUT	
							END	
						
							IF @i > 0
								SET @WhereClauseTmp += ' ' + @Level2MainOperator + ' ';
--SELECT @TmpWhere AS TmpWhere						
							--dodawanie 1 poziomu zaklebienia warunkow filtracji
							IF @TmpWhere IS NOT NULL AND LEN(@TmpWhere) > 2
							BEGIN							
								--IF @i > 0
								--	SET @WhereClauseTmp += ' ' + @Level2MainOperator + ' ';													
								
								--typ obiektu "normalny"
								IF @IsTable = 0						
								BEGIN
										
									SET @WhereClauseTmp += @TmpWhere;
										--SET @Query += '
										--			INSERT INTO #ObiektyID
										--			SELECT ObiektId FROM #CechyTypuObiektuFilters
										--			WHERE 1=1 ' + @Level1MainOperator + ' ' + @TmpWhere + ';';
								END
								ELSE --typ obiektu tabelaryczny
								BEGIN
								
									IF @Level1MainOperator = 'OR'
									BEGIN
										SET @WhereClauseTmp += @TmpWhere; -- + ' ' + @Level1MainOperator;
									END
									ELSE
									BEGIN
									
										--SET @Query += '
										--			INSERT INTO #ObiektyID
										--			SELECT Id FROM [_' + @ObjectType + ']
										--			WHERE 1=1 ' + @Level1MainOperator + ' ' + @TmpWhere + ';';
										
										SET @WhereClauseTmp += @TmpWhere;
									END
								
								END 							
								
								
								
								--SET @WhereClauseTmp += @TmpWhere;
							END
							ELSE
								SET @WhereClauseTmp += '1=0'
			
							SET @i += 1;
							FETCH NEXT FROM cur INTO @Level2MainOperator, @AttributeTypeId, @Operator, @Value
						END
						CLOSE cur
						DEALLOCATE cur;							
					
						SET @i3 = 0;
						
						--sprawdzenie czy dla podanego filtru 2 poziomu istnieje filtr 3 poziomu					
						IF (SELECT COUNT(1) FROM #Filtrowanie3 WHERE [RootId] = @counter) > 0
						BEGIN					
							SET @WhereClauseTmp += ' ' + @Level2MainOperator + ' ';
							
							--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
							IF Cursor_Status('local','cur2') > 0 
							BEGIN
								 CLOSE cur2
								 DEALLOCATE cur2
							END
							
							DECLARE cur2 CURSOR LOCAL FOR 
								SELECT DISTINCT [Index] FROM #Filtrowanie3 WHERE [RootId] = @counter
							OPEN cur2
							FETCH NEXT FROM cur2 INTO @counter2
							WHILE @@FETCH_STATUS = 0
							BEGIN
								--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
								IF Cursor_Status('local','cur3') > 0 
								BEGIN
									 CLOSE cur3
									 DEALLOCATE cur3
								END							
							
								IF (SELECT COUNT (1) FROM #Filtrowanie3 WHERE [RootId] = @counter AND [Index] = @counter2) > 0
								BEGIN
									IF @i3 > 0
										SET @WhereClauseTmp += ' ' + @Level2MainOperator + ' ';
									
									SET @WhereClauseTmp += '('; 
									SET @i2 = 0;
							
									DECLARE cur3 CURSOR LOCAL FOR 
										SELECT LogicalOperator, AttributeTypeId, Operator, Value FROM #Filtrowanie3 WHERE [RootId] = @counter AND [Index] = @counter2
									OPEN cur3
									FETCH NEXT FROM cur3 INTO @Level3MainOperator, @AttributeTypeId, @Operator, @Value
									WHILE @@FETCH_STATUS = 0
									BEGIN
										--pobranie kawalka frazy where dla podanych parametrow
										EXEC [THB].[CheckOperatorAndValue_Relations_Get] @AttributeTypeId = @AttributeTypeId, @Operator = @Operator, @Value = @Value, @Result = @TmpWhere OUTPUT
									
										IF @i2 > 0
											SET @WhereClauseTmp += ' ' + @Level3MainOperator + ' ';
									
										--dodawanie 1 poziomu zaklebienia warunkow filtracji
										IF @TmpWhere IS NOT NULL AND LEN(@TmpWhere) > 2
										BEGIN							
											
											--IF @i2 > 0
											--	SET @WhereClauseTmp += ' ' + @Level3MainOperator + ' ';
											
											SET @WhereClauseTmp += @TmpWhere;
										END
										ELSE
											SET @WhereClauseTmp += '1=0'
						
										SET @i2 += 1;
										FETCH NEXT FROM cur3 INTO @Level3MainOperator, @AttributeTypeId, @Operator, @Value
									END
									CLOSE cur3
									DEALLOCATE cur3
									
									SET @WhereClauseTmp += ')';  
									
								END
								
								SET @i3 += 1;
								FETCH NEXT FROM cur2 INTO @counter2
							END
							CLOSE cur2
							DEALLOCATE cur2;
					
						END
											
						SET @counter = @counter + 1;
						
						IF @SaFiltry1Poziom = 1						
							SET @WhereClauseTmp += ')';
						
						IF @IloscWszystkichFiltrow > 0
							SET @WhereClauseTmp += ' )';					
						
						IF @IsTable = 0
						BEGIN	
							SET @Query = 'INSERT INTO #ObiektyID
										  SELECT ObiektId FROM #CechyTypuObiektuFilters
										  WHERE 1=1 ' + @Level1MainOperator + ' ' + @WhereClauseTmp
						END
						ELSE
						BEGIN
							SET @Query = 'INSERT INTO #ObiektyID
										  SELECT Id FROM [_' + @ObjectType + ']
										  WHERE ' + @WhereClauseTmp + ';';
						END
						
						--PRINT @Query;
						EXECUTE sp_executesql @query;
						
						SET @IloscFiltrow += 1;		 
					END
					--koniec kursora po el z 2 poziomu zaglebienia
							
				END

--SELECT * FROM #ObiektyID
--SELECT @IloscFiltrow
				--IF @IsTable = 0
				BEGIN
					--wrzucenie do tabeli tymczasowej Id obiektów ktore spelniaja wszystkie warunki
					IF @Level1MainOperator = 'AND'
					BEGIN
						INSERT INTO @Table
						SELECT ObiektId
						FROM #ObiektyID			
						GROUP BY ObiektId
						HAVING COUNT(ObiektId) = @IloscFiltrow
					END
					ELSE --OR, wystarczy spelnienie tylko 1 warunku
					BEGIN
						INSERT INTO @Table
						SELECT ObiektId
						FROM #ObiektyID			
						GROUP BY ObiektId
						HAVING COUNT(ObiektId) > 0;
					END
						
					SET @Obiekty = [THB].[TableToList](@Table);
					
					--jesli znaleziono obiekty do dodanie do wrazy where kawalka IN
					IF @Obiekty IS NOT NULL AND LEN(@Obiekty) > 0
						SET	@WhereClause += ' AND Id IN (' + @Obiekty + ')';
					ELSE 
					BEGIN
						-- nie znaleziono obiektow o podanych cechach to dodanie In 0 by nic nie zostalo zwrocone
						IF @IloscWszystkichFiltrow > 0
							SET	@WhereClause += ' AND Id IN (-1)';
					END
				END
			END			
		END

	--END TRY
	--BEGIN CATCH
	--	IF @ERRMSG IS NULL
	--	BEGIN
	--		SET @ERRMSG = @@ERROR;
	--		SET @ERRMSG += ' ';
	--		SET @ERRMSG += ERROR_MESSAGE();
	--	END
				
	--END CATCH
	
	--usuwanie tabel tymczasowych, jesli istnieja
	IF OBJECT_ID('tempdb..#Sortowanie') IS NOT NULL
		DROP TABLE #Sortowanie
		
	IF OBJECT_ID('tempdb..#Filtrowanie1') IS NOT NULL
		DROP TABLE #Filtrowanie1
		
	IF OBJECT_ID('tempdb..#Filtrowanie2') IS NOT NULL
		DROP TABLE #Filtrowanie2
		
	IF OBJECT_ID('tempdb..#Filtrowanie3') IS NOT NULL
		DROP TABLE #Filtrowanie3
		
	IF OBJECT_ID('tempdb..#ObiektyID') IS NOT NULL
		DROP TABLE #ObiektyID
		
	IF OBJECT_ID('tempdb..#Cechy') IS NOT NULL
		DROP TABLE #Cechy
	
	IF OBJECT_ID('tempdb..#KolumnyTypuObiektuFilters') IS NOT NULL
		DROP TABLE #KolumnyTypuObiektuFilters
		
	IF OBJECT_ID('tempdb..#CechyTypuObiektuFilters') IS NOT NULL
		DROP TABLE #CechyTypuObiektuFilters
		
	IF OBJECT_ID('tempdb..##CechyTabelaryczne_GetOfTypeFilters') IS NOT NULL
		DROP TABLE ##CechyTabelaryczne_GetOfTypeFilters
	 
END
