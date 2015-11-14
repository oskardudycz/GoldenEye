-- =============================================
-- Author:		DK
-- Create date: 2012-03-09
-- Description:	Zwraca warunek WHERE na podstawie XMLa z filtrami
-- =============================================
CREATE PROCEDURE [THB].[PrepareFilters]
(
	@XMLDataIn nvarchar(MAX),
	@Alias varchar(10) = NULL,
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
			@DirectionSQL nvarchar (4),
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
			@iloscComposite1Poziom int = 0,
			@iloscComposit2Poziom int = 0,
			@counter int = 0,
			@counter2 int = 0,
			@Query nvarchar(MAX),
			@IloscWszystkichFiltrow int = 0,
			@IloscFilter1Poziom int = 0

	BEGIN TRY
		SET @ERRMSG = '';
	--	SET @PageSize = 0;
	--	SET @PageIndex = 0;
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
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_StandardRequest', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
		
		IF @xmlOk = 0
		BEGIN
			SET @ERRMSG = @ERRMSG
			SELECT @ERRMSG;
			--EXEC dbo.Variables_Display 'XML_KO','PROC_RESULT', @STATUS OUT, @_typ OUT
			--RETURN -5
		END
		ELSE
		BEGIN	
			SET @xml_data = CAST(@XMLDataIn AS xml);
			
			--odczytanie ilosci composti filtrow 1 poziomu
			SET @iloscComposite1Poziom = (SELECT @xml_data.value('count(/Request/CompositeFilterDescriptor/CompositeFilterDescriptor)','int') );
			SET @IloscFilter1Poziom = (SELECT @xml_data.value('count(/Request/CompositeFilterDescriptor/FilterDescriptor)','int') );
		
			--odczytywanie danych filtrowania
			SELECT	@Level1MainOperator = C.value('./@LogicalOperator', 'varchar(3)')
			FROM @xml_data.nodes('/Request/CompositeFilterDescriptor') T(C) 
			
			--1 poziomu
			SELECT	C.value('./@PropertyName', 'nvarchar(200)') AS PropertyName
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
				   ,x.value('./@PropertyName', 'nvarchar(200)') AS 'PropertyName'
				   ,x.value('./@Operator', 'nvarchar(30)') AS 'Operator'
				   ,x.value('./@Value', 'nvarchar(255)') AS 'Value'
				   ,j AS 'Index'
			INTO #Filtrowanie2
			FROM Num
			CROSS APPLY @xml_data.nodes('/Request/CompositeFilterDescriptor/CompositeFilterDescriptor[position()=sql:column("j")]/FilterDescriptor')  e(x);
					
			--wyciaganie danych 3 poziomu	
			DECLARE @ii int = 1;
			DECLARE @tmpCommand nvarchar(150) = '';
			SET @counter = 1;
			
			CREATE TABLE #Filtrowanie3 (LogicalOperator varchar(20), PropertyName nvarchar(200), Operator nvarchar(30), Value nvarchar(255), [Index] int, RootId int);
			
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
						
					INSERT INTO #Filtrowanie3 (LogicalOperator, PropertyName, Operator, Value, [Index], RootId)
					SELECT x.value(''../@LogicalOperator'', ''varchar(20)'')
						   ,x.value(''./@PropertyName'', ''nvarchar(200)'')
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
			
			--wyciaganie danych stronicowania
			SELECT @PageSize = C.value('./@PageSize', 'int')
					,@PageIndex = C.value('./@PageIndex', 'int')  --(./text())[1]', 'int')
			FROM @xml_data.nodes('/Request/Paging') T(C)
			
			--odczytywanie danych sortowania
			SELECT C.value('./@PropertyName','nvarchar(200)') AS PropertyName
				,C.value('./@Direction', 'nvarchar(15)') AS Direction
			INTO #Sortowanie 
			FROM @xml_data.nodes('/Request/SortDescriptors/SortDescriptor') T(C)
		
			--SELECT * FROM #Sortowanie;
			--SELECT * FROM #Filtrowanie1;
			--SELECT * FROM #Filtrowanie2;
					--	SELECT * FROM #Filtrowanie3	
			--SELECT 	@Level1MainOperator, @Level2MainOperator
			
			-- przygotowanie frazy WHERE
			--SET @WhereClause = ' WHERE 1=1 ';			

			
			IF (SELECT COUNT(1) FROM #Filtrowanie1) > 0
			BEGIN
			
				--obliczenie ilsoci wszystkich filtrow
				SET @IloscWszystkichFiltrow += (SELECT COUNT(1) FROM #Filtrowanie1);
				SET @IloscWszystkichFiltrow += (SELECT COUNT(1) FROM #Filtrowanie2);
				SET @IloscWszystkichFiltrow += (SELECT COUNT(1) FROM #Filtrowanie3);
				
				IF @IloscWszystkichFiltrow > 0
					SET @WhereClause += ' AND (';
				
				--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
				IF Cursor_Status('local','cur') > 0 
				BEGIN
					 CLOSE cur
					 DEALLOCATE cur
				END
				
				SET @counter = 1;
			
				DECLARE cur CURSOR LOCAL FOR 
					SELECT PropertyName, Operator, Value FROM #Filtrowanie1
				OPEN cur
				FETCH NEXT FROM cur INTO @PropertyName, @Operator, @Value
				WHILE @@FETCH_STATUS = 0
				BEGIN
					--pobranie kawalka frazy where dla podanych parametrow
					EXEC [THB].[CheckOperatorAndValue] @PropertyName = @PropertyName, @Alias = @Alias, @Operator = @Operator, @Value = @Value, @Result = @TmpWhere OUTPUT
				
					--dodawanie 1 poziomu zaklebienia warunkow filtracji
					IF @TmpWhere IS NOT NULL
					BEGIN
						IF @counter > 1						
							SET @WhereClause += ' ' + @Level1MainOperator + ' ' + @TmpWhere;
						ELSE
							SET @WhereClause += ' ' + @TmpWhere;
					END
				
					SET @counter += 1;
					FETCH NEXT FROM cur INTO @PropertyName, @Operator, @Value
				END
				CLOSE cur
				DEALLOCATE cur			
			END
			
	-----		
			
			IF (SELECT COUNT(1) FROM #Filtrowanie2) > 0 -- 1 
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
					SET @WhereClause += ' ' + @Level1MainOperator + ' ('; 
				
					DECLARE cur CURSOR LOCAL FOR 
						SELECT LogicalOperator, PropertyName, Operator, Value FROM #Filtrowanie2 WHERE [Index] = @counter
					OPEN cur
					FETCH NEXT FROM cur INTO @Level2MainOperator, @PropertyName, @Operator, @Value
					WHILE @@FETCH_STATUS = 0
					BEGIN
						--pobranie kawalka frazy where dla podanych parametrow
						EXEC [THB].[CheckOperatorAndValue] @PropertyName = @PropertyName, @Operator = @Operator, @Value = @Value, @Result = @TmpWhere OUTPUT
					
						--dodawanie 1 poziomu zaklebienia warunkow filtracji
						IF @TmpWhere IS NOT NULL
						BEGIN							
							IF @i > 0
								SET @WhereClause += ' ' + @Level2MainOperator + ' ';
							
							SET @WhereClause += @TmpWhere;
						END
				
						SET @i += 1;
						FETCH NEXT FROM cur INTO @Level2MainOperator, @PropertyName, @Operator, @Value
					END
					CLOSE cur
					DEALLOCATE cur					
					
					DECLARE @i3 int = 0;
					--SET @WhereClause += ')';
					
					--sprawdzenie czy dla podanego filtru 2 poziomu istnieje filtr 3 poziomu					
					IF (SELECT COUNT(1) FROM #Filtrowanie3 WHERE [RootId] = @counter) > 0 --1
					BEGIN					
						SET @WhereClause += ' ' + @Level2MainOperator + ' ';
						
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
							
							--SET @WhereClause += ' ' + @Level2MainOperator + ' (';
							IF (SELECT COUNT (1) FROM #Filtrowanie3 WHERE [RootId] = @counter AND [Index] = @counter2) > 0
							BEGIN
								IF @i3 > 0
									SET @WhereClause += ' ' + @Level2MainOperator + ' ';
								
								SET @WhereClause += '('; 
								SET @i2 = 0;
						
								DECLARE cur3 CURSOR LOCAL FOR 
									SELECT LogicalOperator, PropertyName, Operator, Value FROM #Filtrowanie3 WHERE [RootId] = @counter AND [Index] = @counter2
								OPEN cur3
								FETCH NEXT FROM cur3 INTO @Level3MainOperator, @PropertyName, @Operator, @Value
								WHILE @@FETCH_STATUS = 0
								BEGIN
									--pobranie kawalka frazy where dla podanych parametrow
									EXEC [THB].[CheckOperatorAndValue] @PropertyName = @PropertyName, @Operator = @Operator, @Value = @Value, @Result = @TmpWhere OUTPUT
								
									--dodawanie 1 poziomu zaklebienia warunkow filtracji
									IF @TmpWhere IS NOT NULL
									BEGIN							
										IF @i2 > 0
											SET @WhereClause += ' ' + @Level3MainOperator + ' ';
										
										SET @WhereClause += @TmpWhere;
									END
					
									SET @i2 += 1;
									FETCH NEXT FROM cur3 INTO @Level3MainOperator, @PropertyName, @Operator, @Value
								END
								CLOSE cur3
								DEALLOCATE cur3
								
								SET @WhereClause += ')';  
								
							END
							
							SET @i3 += 1;
							FETCH NEXT FROM cur2 INTO @counter2
						END
						CLOSE cur2
						DEALLOCATE cur2;
				
					END	
										
					SET @counter = @counter + 1; 					
					SET @WhereClause += ')'; 
				END
				--koniec kursora po el z 2 poziomu zaglebienia
							
			END
			
			IF @IloscWszystkichFiltrow > 0
				SET @WhereClause += ' )'
			
	-----
			
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
		--EXEC dbo.Variables_Display 'STATUS_KO','PROC_RESULT', @STATUS OUT, @_typ OUT
		PRINT 'rollback'
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		--IF Cursor_Status('variable','cur2') > 0 
		--BEGIN
		--	 CLOSE cur
		--	 DEALLOCATE cur
		--END
		
	END CATCH 
	 
END
