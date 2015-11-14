-- =============================================
-- Author:		DK
-- Create date: 2012-08-02
-- Last modified on: 2013-01-28
-- Description:	Zwraca warunek WHERE na podstawie XMLa z filtrami
-- =============================================
CREATE PROCEDURE [THB].[PrepareFilters_Relations_GetOfType]
(
	@XMLDataIn nvarchar(MAX),
	@WhereClause nvarchar(MAX) OUTPUT,
	@OrderByClause nvarchar(200) OUTPUT,
	@PageSize int OUTPUT,
	@PageIndex int OUTPUT,
	@ERRMSG nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @PropertyName nvarchar(200),
			@Direction nvarchar(20),
			@RelacjeId varchar(500),
			@LewyObiektId varchar(500),
			@PrawyObiektId varchar(500),			
			@DirectionSQL nvarchar (4),
			@WhereClauseTmp nvarchar(MAX),
			@xml_data xml,
			@xmlOk bit = 0,
			@Level1MainOperator varchar(3),
			@Level2MainOperator varchar(3),
			@Level3MainOperator varchar(3),
			@Operator varchar(25),
			@Value nvarchar(255),
			@TmpWhere nvarchar(300),
			@i int = 0,
			@i2 int = 0,
			@i3 int = 0,
			@iloscComposite1Poziom int = 0,
			@iloscComposit2Poziom int = 0,
			@counter int = 0,
			@counter2 int = 0,
			@Query nvarchar(MAX),		
			@IloscFiltrow int = 0,
			@Table IdsTable,		
			@AttributeTypeId int,
			@LeftObjectTypeId int,
			@RightObjectTypeId int,
			@RelationTypeId int,
			@ValueType varchar(50),
			@AttributeValue nvarchar(350),
			@NazwaTypuObiektu nvarchar(500)			

	BEGIN TRY
		SET @ERRMSG = NULL;
		SET @WhereClause = ''
		SET @OrderByClause = ''
		
		--usuwanie tabel tymczasowych, jesli istnieja
		IF OBJECT_ID('tempdb..#Sortowanie') IS NOT NULL
			DROP TABLE #Sortowanie
			
		IF OBJECT_ID('tempdb..#Filtrowanie1') IS NOT NULL
			DROP TABLE #Filtrowanie1
			
		IF OBJECT_ID('tempdb..#Filtrowanie2') IS NOT NULL
			DROP TABLE #Filtrowanie2
			
		IF OBJECT_ID('tempdb..#Filtrowanie3') IS NOT NULL
			DROP TABLE #Filtrowanie3
			
		IF OBJECT_ID('tempdb..#RelacjeID') IS NOT NULL
			DROP TABLE #RelacjeID
			
		IF OBJECT_ID('tempdb..#Cechy') IS NOT NULL
			DROP TABLE #Cechy
			
		CREATE TABLE #IDDoPobrania (ID int);		
		CREATE TABLE #RelacjeID (RelacjaId int);	
		CREATE TABLE #Cechy(Id int, RelacjaId int, CechaId int, TypCechyId int, CzySlownik bit, SparceValue xml, ValString nvarchar(MAX), ValueType nvarchar(20), Value nvarchar(MAX));
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Relations_GetOfType', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
		
		IF @xmlOk = 0
		BEGIN
			SET @ERRMSG = @ERRMSG
			--SELECT @ERRMSG;
		END
		ELSE
		BEGIN	
			SET @xml_data = CAST(@XMLDataIn AS xml);
			
			--odczytanie typu relacji			
			SELECT @RelationTypeId = C.value('./@TypeId', 'int')
			FROM @xml_data.nodes('/Request') T(C)
			
			--wyciaganie danych stronicowania
			SELECT @PageSize = C.value('./@PageSize', 'int')
					,@PageIndex = C.value('./@PageIndex', 'int')
			FROM @xml_data.nodes('/Request/Paging') T(C)
			
			--odczytywanie danych sortowania
			SELECT C.value('./@PropertyName','nvarchar(200)') AS PropertyName
				,C.value('./@Direction', 'nvarchar(15)') AS Direction
			INTO #Sortowanie 
			FROM @xml_data.nodes('/Request/SortDescriptors/SortDescriptor') T(C)
				
			--pobranie wszystkich cech dla relacji o podanym typie
			INSERT INTO #Cechy(Id, RelacjaId, CechaId, TypCechyId, CzySlownik, SparceValue, ValString, ValueType, Value )					
			SELECT ch.Id, ch.RelacjaId, ch.CechaId, c.TypID, c.CzySlownik, ch.ColumnsSet, ch.ValString,
				ISNULL([THB].GetAttributeValueTypeFromSparseXML(ch.ColumnsSet), 'nvarchar'),
				ISNULL([THB].GetAttributeValueValueFromSparseXML(ch.ColumnsSet), ch.ValString)
			FROM [dbo].[Relacja_Cecha_Hist] ch
			JOIN dbo.[Cechy] c ON (c.Cecha_ID = ch.CechaID)
			JOIN dbo.[Relacje] r ON (ch.RelacjaId = r.Id)
			WHERE ch.IdArch IS NULL	AND ch.IsValid = 1 AND r.TypRelacji_ID = @RelationTypeId;			
			
			--odczytanie ilosci composit filtrow 1 poziomu
			SET @iloscComposite1Poziom = (SELECT @xml_data.value('count(/Request/CompositeFilterDescriptor/CompositeFilterDescriptor)','int') )
		
			--odczytywanie danych filtrowania
			SELECT	@Level1MainOperator = C.value('./@LogicalOperator', 'varchar(3)')
			FROM @xml_data.nodes('/Request/CompositeFilterDescriptor') T(C)
			
			--1 poziomu
			SELECT	C.value('./@AttributeTypeId', 'int') AS AttributeTypeId
					,C.value('./@Operator', 'nvarchar(25)') AS Operator
					,C.value('./@Value', 'nvarchar(255)') AS Value
			INTO #Filtrowanie1
			FROM @xml_data.nodes('/Request/CompositeFilterDescriptor/FilterDescriptor') T(C)	
			
			--2 poziomu		
			;WITH Num(j)
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
			
			CREATE TABLE #Filtrowanie3 (LogicalOperator varchar(20), AttributeTypeId int, Operator nvarchar(30), Value nvarchar(255), [Index] int, RootId int);
			
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
		
			--SELECT * FROM #Sortowanie;
			--SELECT * FROM #Filtrowanie1;
			--SELECT * FROM #Filtrowanie2;
			--SELECT * FROM #Filtrowanie3;
			--SELECT * FROM #Cechy;
			
			IF (SELECT COUNT(1) FROM #Filtrowanie1) > 0
			BEGIN
			
				--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
				IF Cursor_Status('local','cur') > 0 
				BEGIN
					 CLOSE cur
					 DEALLOCATE cur
				END
			
				DECLARE cur CURSOR LOCAL FOR 
					SELECT AttributeTypeId, Operator, Value FROM #Filtrowanie1
				OPEN cur
				FETCH NEXT FROM cur INTO @AttributeTypeId, @Operator, @Value
				WHILE @@FETCH_STATUS = 0
				BEGIN
					
					--pobranie kawalka frazy where dla podanych parametrow
					EXEC [THB].[CheckOperatorAndValue_Relations_Get] @AttributeTypeId = @AttributeTypeId, @Operator = @Operator, @Value = @Value, @Result = @TmpWhere OUTPUT			
				
					--dodawanie 1 poziomu zaklebienia warunkow filtracji
					IF @TmpWhere IS NOT NULL AND LEN(@TmpWhere) > 2
					BEGIN						
						SET @Query = 'INSERT INTO #RelacjeID
									  SELECT RelacjaId FROM #Cechy
									  WHERE 1=1 ' + @Level1MainOperator + ' ' + @TmpWhere
						
						--PRINT @query;
						EXECUTE sp_executesql @query;
					END
					
					SET @IloscFiltrow += 1;
				
					FETCH NEXT FROM cur INTO @AttributeTypeId, @Operator, @Value
				END
				CLOSE cur
				DEALLOCATE cur			
			END
			
			IF (SELECT COUNT(1) FROM #Filtrowanie2) > 0 
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
					SET @WhereClauseTmp = '('
				
					DECLARE cur CURSOR LOCAL FOR 
						SELECT LogicalOperator, AttributeTypeId, Operator, Value FROM #Filtrowanie2 WHERE [Index] = @counter
					OPEN cur
					FETCH NEXT FROM cur INTO @Level2MainOperator, @AttributeTypeId, @Operator, @Value
					WHILE @@FETCH_STATUS = 0
					BEGIN
						--pobranie kawalka frazy where dla podanych parametrow
						EXEC [THB].[CheckOperatorAndValue_Relations_Get] @AttributeTypeId = @AttributeTypeId, @Operator = @Operator, @Value = @Value, @Result = @TmpWhere OUTPUT
					
						IF @i > 0
							SET @WhereClauseTmp += ' ' + @Level2MainOperator + ' ';
						
						--dodawanie 1 poziomu zaklebienia warunkow filtracji
						IF @TmpWhere IS NOT NULL AND LEN(@TmpWhere) > 2
						BEGIN							
							SET @WhereClauseTmp += @TmpWhere;
						END
						ELSE
							SET @WhereClauseTmp += '1=0';
			
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
					SET @WhereClauseTmp += ')';					
						
					SET @Query = 'INSERT INTO #RelacjeID
								  SELECT RelacjaId FROM #Cechy
								  WHERE 1=1 ' + @Level1MainOperator + ' ' + @WhereClauseTmp
					
					--PRINT @query;
					EXECUTE sp_executesql @query;
					
					SET @IloscFiltrow += 1;		 
				END
				--koniec kursora po el z 2 poziomu zaglebienia
							
			END
			
			--wrzucenie do tabeli tymczasowej Id relacji ktore spelniaja wszystkie warunki
			IF @IloscFiltrow > 0
			BEGIN
				INSERT INTO @Table
				SELECT RelacjaId
				FROM #RelacjeID
				GROUP BY RelacjaId
				HAVING COUNT(RelacjaId) = @IloscFiltrow
				
				SET @RelacjeId = [THB].[TableToList](@Table);
				
				--dodanie danych relacji do frazy where
				IF @RelacjeId IS NOT NULL AND LEN(@RelacjeId) > 0
					SET	@WhereClause += ' AND Id IN (' + @RelacjeId + ')';
				ELSE 
				BEGIN
					IF @RelationTypeId IS NOT NULL
						SET @WhereClause += ' AND Id IN (0)';  --zapewnienie braku wynikow
				END
			END
			
---------------------------ORDER BY ------------------------			
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
		END
		
	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		--IF Cursor_Status('variable','cur2') > 0 
		--BEGIN
		--	 CLOSE cur
		--	 DEALLOCATE cur
		--END
		
	END CATCH 
	
	--usuwanie tabel tymczasowych, jesli istnieja
	IF OBJECT_ID('tempdb..#Sortowanie') IS NOT NULL
		DROP TABLE #Sortowanie
		
	IF OBJECT_ID('tempdb..#Filtrowanie1') IS NOT NULL
		DROP TABLE #Filtrowanie1
		
	IF OBJECT_ID('tempdb..#Filtrowanie2') IS NOT NULL
		DROP TABLE #Filtrowanie2
		
	IF OBJECT_ID('tempdb..#Filtrowanie3') IS NOT NULL
		DROP TABLE #Filtrowanie3
		
	IF OBJECT_ID('tempdb..#RelacjeID') IS NOT NULL
		DROP TABLE #RelacjeID
		
	IF OBJECT_ID('tempdb..#Cechy') IS NOT NULL
		DROP TABLE #Cechy
	 
END
