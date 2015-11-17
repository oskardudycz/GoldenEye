-- =============================================
-- Author:		DK
-- Create date: 2012-10-23
-- Last modifies on: 2013-02-18
-- Description:	Zwraca dane statystyczne (ilość elementów każdego typu, "ważnych" na podaną AppDate).

-- XML wejsciowy w postaci:

-- <Request RequestType="Database_GetStatistics" UserId="1" AppDate="2012-05-09T12:34:44" StatusS="2"/>	

-- XML wyjsciowy w postaci:

--<?xml version="1.0" encoding="utf-8"?>
--<Response ResponseType="Database_GetStatistics" AppDate="2012-05-09">
--	<Statistics>
--		<Statistic Count="19" EntityType="AttributeType"/>
--		<Statistic Count="27" EntityType="Branch"/>
--		<Statistic Count="20" EntityType="CouplerStructureType"/>
--		<Statistic Count="25" EntityType="DataType"/>
--		<Statistic Count="40" EntityType="Dictionary"/>
--		<Statistic Count="51" EntityType="DictionaryEntry"/>
--		<Statistic Count="4" EntityType="Operation"/>
--		<Statistic Count="6" EntityType="Relation"/>
--		<Statistic Count="6" EntityType="RelationAttributes"/>
--		<Statistic Count="5" EntityType="RelationBaseType"/>
--		<Statistic Count="5" EntityType="RelationType"/>
--		<Statistic Count="7" EntityType="Role"/>
--		<Statistic Count="7" EntityType="Structure"/>
--		<Statistic Count="7" EntityType="StructureType"/>
--		<Statistic Count="345" EntityType="Unit"/>
--		<Statistic Count="61" EntityType="UnitAttributes"/>
--		<Statistic Count="15" EntityType="UnitOfMeasure"/>
--		<Statistic Count="19" EntityType="UnitOfMeasureConversion"/>
--		<Statistic Count="28" EntityType="UnitType"/>
--		<Statistic Count="13" EntityType="User"/>
--		<Statistic Count="11" EntityType="UserGroup"/>
--	</Statistics>
--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Database_GetStatistics]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Query nvarchar(max) = '',
		@StandardWhere nvarchar(MAX) = '',
		@DataProgramu datetime,
		@RequestType nvarchar(100),
		@UzytkownikID int,
		@BranzaID int,
		@xml_data xml,
		@xmlOk bit = 0,
		@ERRMSG nvarchar(255),
		@xmlResponse xml,
		@MaUprawnienia bit = 0,
		@BranzeZDostepem nvarchar(MAX) = '',
		@AppDate datetime,
		@IdArch int,
		@StatusS int,
		@StatusW int,
		@StatusP int,
		@NazwaTabeli nvarchar(300),		
		@BranzeIlosc int,
		@CechyIlosc int,
		@CechaTypIlosc int,
		@GrupyUzytkownikowIlosc int,
		@JednostkiMiaryIlosc int,
		@JednostkiMiaryPrzelicznikiIlosc int,
		@OperacjeIlosc int,
		@RelacjeIlosc int,
		@RelacjeCechyIlosc int,
		@RelacjaBazowyTypIlosc int,
		@RoleIlosc int,
		@SlownikiIlosc int,
		@SlownikiWpisyIlosc int,
		@StrukturaIlosc int,
		@TypObiektuIlosc int,
		@ObiektyIlosc int,
		@ObiektyCechyIlosc int,
		@TypRelacjiIlosc int,
		@TypStrukturyObiektIlosc int,
		@TypStrukturyIlosc int,
		@UzytkownicyIlosc int		
		
		--usuwanie tabel tymczasowych, jesli istnieja
		IF OBJECT_ID('tempdb..#DanePodstawoweTmp') IS NOT NULL
			DROP TABLE #DanePodstawoweTmp
			
		IF OBJECT_ID('tempdb..#DanePodstawowe') IS NOT NULL
			DROP TABLE #DanePodstawowe
			
		IF OBJECT_ID('tempdb..#DanePomocnicze') IS NOT NULL
			DROP TABLE #DanePomocnicze
			
		IF OBJECT_ID('tempdb..#DanePomocniczeTmp') IS NOT NULL
			DROP TABLE #DanePomocniczeTmp
			
		IF OBJECT_ID('tempdb..#IloscElementowWBazie') IS NOT NULL
			DROP TABLE #IloscElementowWBazie
		
		CREATE TABLE #IloscElementowWBazie (Ilosc int, TypElementu varchar(30));
		CREATE TABLE #DanePodstawoweTmp (Id int, IdArch int, IdArchLink int, ValidFrom datetime, ValidTo datetime, RealCreatedOn datetime);
		CREATE TABLE #DanePodstawowe (Id int);
		CREATE TABLE #DanePomocniczeTmp (Id int, IdArch int, IdArchLink int, ValidFrom datetime, ValidTo datetime, RealCreatedOn datetime);
		CREATE TABLE #DanePomocnicze (Id int);
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Database_GetStatistics', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
	
		IF @xmlOk = 0
		BEGIN
			-- co zrobic jak nie poprawna walidacja XML
			SET @ERRMSG = @ERRMSG;
		END
		ELSE
		BEGIN	
			BEGIN TRY
			
			--poprawny XML wejsciowy
			SET @xml_data = CAST(@XMLDataIn AS xml);
			
			--wyciaganie daty i typu zadania
			SELECT	@DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
					,@BranzaId = C.value('./@BranchId', 'int')
					,@UzytkownikID = C.value('./@UserId', 'nvarchar(32)')
					,@StatusS = C.value('./@StatusS', 'int')
					,@StatusP = C.value('./@StatusP', 'int')
					,@StatusW = C.value('./@StatusW', 'int')
			FROM @xml_data.nodes('/Request') T(C) 
		
			IF @RequestType = 'Database_GetStatistics'
			BEGIN
			
				-- pobranie daty na podstawie przekazanego AppDate
				SELECT @AppDate = THB.PrepareAppDate(@DataProgramu);
				
				-- przygotowanie frazy where wspolnej dla wszystkich zapytan
				SET @StandardWhere = [THB].[PrepareStatusesPhrase] (NULL, @StatusS, @StatusP, @StatusW);
				
				SET @StandardWhere += [THB].[PrepareDatesPhrase] (NULL, @AppDate);						
				
				--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji select
				EXEC [THB].[CheckUserPermission]
					@Operation = N'GET',
					@UserId = @UzytkownikID,
					@BranchId = @BranzaId,
					@Result = @MaUprawnienia OUTPUT
				
				IF @MaUprawnienia = 1
				BEGIN		
	
----------- BRANŻE -----------			
					
					SET @Query = '
						SELECT COUNT(b.Id)
						FROM [dbo].[Branze] b
						INNER JOIN
						(
							SELECT ISNULL(b2.IdArch, b2.Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, b2.' + [THB].[GetDateFromFilterColumn]() + ' AS MaxDate
							FROM [dbo].[Branze] b2								 
							INNER JOIN 
							(
								SELECT ISNULL(b3.IdArch, b3.Id) AS RowID, MAX(b3.' + [THB].[GetDateFromFilterColumn]() + ') AS MaxDate
								FROM [dbo].[Branze] b3
								WHERE 1=1' + @StandardWhere;							
									
					SET @Query += '
								GROUP BY ISNULL(b3.IdArch, b3.Id)
							) latest
							ON ISNULL(b2.IdArch, b2.Id) = latest.RowID AND b2.' + [THB].[GetDateFromFilterColumn]() + ' = latest.MaxDate
							GROUP BY ISNULL(b2.IdArch, b2.Id), b2.' + [THB].[GetDateFromFilterColumn]() + '					
						) latestWithMaxDate
						ON  ISNULL(b.IdArch, b.Id) = latestWithMaxDate.RowID AND b.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND b.' + [THB].[GetDateFromFilterColumn]() + ' = latestWithMaxDate.MaxDate'

					--PRINT @Query;
					EXECUTE sp_executesql @Query;
					
								
					SET @Query = 'INSERT INTO #DanePodstawoweTmp (Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn)
					SELECT Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn					
					FROM [Branze] 
					WHERE 1=1 ' + @StandardWhere;
	
					--PRINT @Query;
					EXECUTE sp_executesql @Query;

					INSERT INTO #DanePodstawowe (Id)
					SELECT b.Id From #DanePodstawoweTmp b WHERE b.IdArch IS NULL AND NOT EXISTS (SELECT b2.Id From #DanePodstawoweTmp b2 WHERE b2.Id = b.IdArchLink);

					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','curBr') > 0 
					BEGIN
						 CLOSE curBr
						 DEALLOCATE curBr
					END
			
					DECLARE curBr CURSOR LOCAL FOR 
					SELECT DISTINCT IdArch FROM #DanePodstawoweTmp WHERE IdArch IS NOT NULL AND IdArch NOT IN (SELECT Id FROM #DanePodstawowe)
					OPEN curBr
					FETCH NEXT FROM curBr INTO @IdArch
					WHILE @@FETCH_STATUS = 0
					BEGIN						
						INSERT INTO #DanePodstawowe (Id)
						SELECT TOP 1 Id FROM #DanePodstawoweTmp
						WHERE Id = @IdArch OR IdArch = @IdArch
						ORDER BY (DATEPART(yy, RealCreatedOn) + DATEPART(mm, RealCreatedOn) + DATEPART(dd, RealCreatedOn)) DESC, ValidFrom DESC
						
						FETCH NEXT FROM curBr INTO @IdArch
					END
					CLOSE curBr
					DEALLOCATE curBr;
					
					--pobranie ilosci branz
					SET @BranzeIlosc = (SELECT COUNT(1) FROM #DanePodstawowe);
SELECT @BranzeIlosc					
					INSERT INTO #IloscElementowWBazie (Ilosc, TypElementu)
					VALUES (@BranzeIlosc, 'Branch');

---------- CECHY ---------
			
					DELETE FROM #DanePodstawowe;
					DELETE FROM #DanePodstawoweTmp;
					
					SET @Query = 'INSERT INTO #DanePodstawoweTmp (Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn)
					SELECT Cecha_ID, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn					
					FROM [Cechy] 
					WHERE 1=1 ' + @StandardWhere;
	
					--PRINT @Query;
					EXECUTE sp_executesql @Query;

					INSERT INTO #DanePodstawowe (Id)
					SELECT b.Id From #DanePodstawoweTmp b WHERE b.IdArch IS NULL AND NOT EXISTS (SELECT b2.Id From #DanePodstawoweTmp b2 WHERE b2.Id = b.IdArchLink);

					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','curBr') > 0 
					BEGIN
						 CLOSE curBr
						 DEALLOCATE curBr
					END
			
					DECLARE curBr CURSOR LOCAL FOR 
					SELECT DISTINCT IdArch FROM #DanePodstawoweTmp WHERE IdArch IS NOT NULL AND IdArch NOT IN (SELECT Id FROM #DanePodstawowe)
					OPEN curBr
					FETCH NEXT FROM curBr INTO @IdArch
					WHILE @@FETCH_STATUS = 0
					BEGIN						
						INSERT INTO #DanePodstawowe (Id)
						SELECT TOP 1 Id FROM #DanePodstawoweTmp
						WHERE Id = @IdArch OR IdArch = @IdArch
						ORDER BY (DATEPART(yy, RealCreatedOn) + DATEPART(mm, RealCreatedOn) + DATEPART(dd, RealCreatedOn)) DESC, ValidFrom DESC
						
						FETCH NEXT FROM curBr INTO @IdArch
					END
					CLOSE curBr
					DEALLOCATE curBr;
					
					--pobranie ilosci cech
					SET @CechyIlosc = (SELECT COUNT(1) FROM #DanePodstawowe);	
					
					INSERT INTO #IloscElementowWBazie (Ilosc, TypElementu)
					VALUES (@CechyIlosc, 'AttributeType');

---------- CECHA TYPY ---------

					DELETE FROM #DanePodstawowe;
					DELETE FROM #DanePodstawoweTmp;
					
					SET @Query = 'INSERT INTO #DanePodstawoweTmp (Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn)
					SELECT Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn					
					FROM [Cecha_Typy] 
					WHERE 1=1 ' + @StandardWhere;
	
					--PRINT @Query;
					EXECUTE sp_executesql @Query;

					INSERT INTO #DanePodstawowe (Id)
					SELECT b.Id From #DanePodstawoweTmp b WHERE b.IdArch IS NULL AND NOT EXISTS (SELECT b2.Id From #DanePodstawoweTmp b2 WHERE b2.Id = b.IdArchLink);

					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','curBr') > 0 
					BEGIN
						 CLOSE curBr
						 DEALLOCATE curBr
					END
			
					DECLARE curBr CURSOR LOCAL FOR 
					SELECT DISTINCT IdArch FROM #DanePodstawoweTmp WHERE IdArch IS NOT NULL AND IdArch NOT IN (SELECT Id FROM #DanePodstawowe)
					OPEN curBr
					FETCH NEXT FROM curBr INTO @IdArch
					WHILE @@FETCH_STATUS = 0
					BEGIN						
						INSERT INTO #DanePodstawowe (Id)
						SELECT TOP 1 Id FROM #DanePodstawoweTmp
						WHERE Id = @IdArch OR IdArch = @IdArch
						ORDER BY (DATEPART(yy, RealCreatedOn) + DATEPART(mm, RealCreatedOn) + DATEPART(dd, RealCreatedOn)) DESC, ValidFrom DESC
						
						FETCH NEXT FROM curBr INTO @IdArch
					END
					CLOSE curBr
					DEALLOCATE curBr;
					
					--pobranie ilosci typów cech
					SET @CechaTypIlosc = (SELECT COUNT(1) FROM #DanePodstawowe);	
					
					INSERT INTO #IloscElementowWBazie (Ilosc, TypElementu)
					VALUES (@CechaTypIlosc, 'DataType');					

---------- GRUPY UŻYTKOWNIKÓW ---------

					DELETE FROM #DanePodstawowe;
					DELETE FROM #DanePodstawoweTmp;
					
					SET @Query = 'INSERT INTO #DanePodstawoweTmp (Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn)
					SELECT Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn					
					FROM [GrupyUzytkownikow] 
					WHERE 1=1 ' + @StandardWhere;
	
					--PRINT @Query;
					EXECUTE sp_executesql @Query;

					INSERT INTO #DanePodstawowe (Id)
					SELECT b.Id From #DanePodstawoweTmp b WHERE b.IdArch IS NULL AND NOT EXISTS (SELECT b2.Id From #DanePodstawoweTmp b2 WHERE b2.Id = b.IdArchLink);

					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','curBr') > 0 
					BEGIN
						 CLOSE curBr
						 DEALLOCATE curBr
					END
			
					DECLARE curBr CURSOR LOCAL FOR 
					SELECT DISTINCT IdArch FROM #DanePodstawoweTmp WHERE IdArch IS NOT NULL AND IdArch NOT IN (SELECT Id FROM #DanePodstawowe)
					OPEN curBr
					FETCH NEXT FROM curBr INTO @IdArch
					WHILE @@FETCH_STATUS = 0
					BEGIN						
						INSERT INTO #DanePodstawowe (Id)
						SELECT TOP 1 Id FROM #DanePodstawoweTmp
						WHERE Id = @IdArch OR IdArch = @IdArch
						ORDER BY (DATEPART(yy, RealCreatedOn) + DATEPART(mm, RealCreatedOn) + DATEPART(dd, RealCreatedOn)) DESC, ValidFrom DESC
						
						FETCH NEXT FROM curBr INTO @IdArch
					END
					CLOSE curBr
					DEALLOCATE curBr;
					
					--pobranie ilosci grup uzytkownika
					SET @GrupyUzytkownikowIlosc = (SELECT COUNT(1) FROM #DanePodstawowe);	
					
					INSERT INTO #IloscElementowWBazie (Ilosc, TypElementu)
					VALUES (@GrupyUzytkownikowIlosc, 'UserGroup');
					
---------- JEDNOSTKI MIARY ---------

					DELETE FROM #DanePodstawowe;
					DELETE FROM #DanePodstawoweTmp;
					
					SET @Query = 'INSERT INTO #DanePodstawoweTmp (Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn)
					SELECT Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn					
					FROM [JednostkiMiary] 
					WHERE 1=1 ' + @StandardWhere;
	
					--PRINT @Query;
					EXECUTE sp_executesql @Query;

					INSERT INTO #DanePodstawowe (Id)
					SELECT ISNULL(b.IdArch, b.Id) From #DanePodstawoweTmp b WHERE b.IdArch IS NULL AND NOT EXISTS (SELECT b2.Id From #DanePodstawoweTmp b2 WHERE b2.Id = b.IdArchLink);

					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','curBr') > 0 
					BEGIN
						 CLOSE curBr
						 DEALLOCATE curBr
					END
			
					DECLARE curBr CURSOR LOCAL FOR 
					SELECT DISTINCT IdArch FROM #DanePodstawoweTmp WHERE IdArch IS NOT NULL AND IdArch NOT IN (SELECT Id FROM #DanePodstawowe)
					OPEN curBr
					FETCH NEXT FROM curBr INTO @IdArch
					WHILE @@FETCH_STATUS = 0
					BEGIN						
						INSERT INTO #DanePodstawowe (Id)
						SELECT TOP 1 ISNULL(IdArch, Id) FROM #DanePodstawoweTmp
						WHERE Id = @IdArch OR IdArch = @IdArch
						ORDER BY (DATEPART(yy, RealCreatedOn) + DATEPART(mm, RealCreatedOn) + DATEPART(dd, RealCreatedOn)) DESC, ValidFrom DESC
						
						FETCH NEXT FROM curBr INTO @IdArch
					END
					CLOSE curBr
					DEALLOCATE curBr;
					
					--pobranie ilosci jednostek miary
					SET @JednostkiMiaryIlosc = (SELECT COUNT(1) FROM #DanePodstawowe);	
					
					INSERT INTO #IloscElementowWBazie (Ilosc, TypElementu)
					VALUES (@JednostkiMiaryIlosc, 'UnitOfMeasure');	
					
---------- JEDNOSTKI MIARY - PRZELICZNIKI ---------

					DELETE FROM #DanePomocnicze;
					DELETE FROM #DanePomocniczeTmp;
					
					SET @Query = 'INSERT INTO #DanePomocniczeTmp (Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn)
					SELECT Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn					
					FROM [JednostkiMiary_Przeliczniki] 
					WHERE IdFrom IN (SELECT Id FROM #DanePodstawowe) AND IdTo IN (SELECT Id FROM #DanePodstawowe) ' + @StandardWhere;
	
					--PRINT @Query;
					EXECUTE sp_executesql @Query;

					INSERT INTO #DanePomocnicze (Id)
					SELECT ISNULL(b.IdArch, b.Id) From #DanePomocniczeTmp b WHERE b.IdArch IS NULL AND NOT EXISTS (SELECT b2.Id From #DanePomocniczeTmp b2 WHERE b2.Id = b.IdArchLink);

					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','curBr') > 0 
					BEGIN
						 CLOSE curBr
						 DEALLOCATE curBr
					END
			
					DECLARE curBr CURSOR LOCAL FOR 
					SELECT DISTINCT IdArch FROM #DanePomocniczeTmp WHERE IdArch IS NOT NULL AND IdArch NOT IN (SELECT Id FROM #DanePomocnicze)
					OPEN curBr
					FETCH NEXT FROM curBr INTO @IdArch
					WHILE @@FETCH_STATUS = 0
					BEGIN						
						INSERT INTO #DanePomocnicze (Id)
						SELECT TOP 1 ISNULL(IdArch, Id) FROM #DanePomocniczeTmp
						WHERE Id = @IdArch OR IdArch = @IdArch
						ORDER BY (DATEPART(yy, RealCreatedOn) + DATEPART(mm, RealCreatedOn) + DATEPART(dd, RealCreatedOn)) DESC, ValidFrom DESC
						
						FETCH NEXT FROM curBr INTO @IdArch
					END
					CLOSE curBr
					DEALLOCATE curBr;
					
					--pobranie ilosci przelicznikow jednostek miary
					SET @JednostkiMiaryPrzelicznikiIlosc = (SELECT COUNT(1) FROM #DanePomocnicze);	
					
					INSERT INTO #IloscElementowWBazie (Ilosc, TypElementu)
					VALUES (@JednostkiMiaryPrzelicznikiIlosc, 'UnitOfMeasureConversion');						
					
---------- OPERACJE ---------

					DELETE FROM #DanePodstawowe;
					DELETE FROM #DanePodstawoweTmp;
					
					SET @Query = 'INSERT INTO #DanePodstawoweTmp (Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn)
					SELECT Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn					
					FROM [Operacje] 
					WHERE 1=1 ' + @StandardWhere;
	
					--PRINT @Query;
					EXECUTE sp_executesql @Query;

					INSERT INTO #DanePodstawowe (Id)
					SELECT ISNULL(b.IdArch, b.Id) From #DanePodstawoweTmp b WHERE b.IdArch IS NULL AND NOT EXISTS (SELECT b2.Id From #DanePodstawoweTmp b2 WHERE b2.Id = b.IdArchLink);

					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','curBr') > 0 
					BEGIN
						 CLOSE curBr
						 DEALLOCATE curBr
					END
			
					DECLARE curBr CURSOR LOCAL FOR 
					SELECT DISTINCT IdArch FROM #DanePodstawoweTmp WHERE IdArch IS NOT NULL AND IdArch NOT IN (SELECT Id FROM #DanePodstawowe)
					OPEN curBr
					FETCH NEXT FROM curBr INTO @IdArch
					WHILE @@FETCH_STATUS = 0
					BEGIN						
						INSERT INTO #DanePodstawowe (Id)
						SELECT TOP 1 ISNULL(IdArch, Id) FROM #DanePodstawoweTmp
						WHERE Id = @IdArch OR IdArch = @IdArch
						ORDER BY (DATEPART(yy, RealCreatedOn) + DATEPART(mm, RealCreatedOn) + DATEPART(dd, RealCreatedOn)) DESC, ValidFrom DESC
						
						FETCH NEXT FROM curBr INTO @IdArch
					END
					CLOSE curBr
					DEALLOCATE curBr;
					
					--pobranie ilosci operacji
					SET @OperacjeIlosc = (SELECT COUNT(1) FROM #DanePodstawowe);	
					
					INSERT INTO #IloscElementowWBazie (Ilosc, TypElementu)
					VALUES (@OperacjeIlosc, 'Operation');					
				
---------- BAZOWY TYP RELACJI ---------

					DELETE FROM #DanePodstawowe;
					DELETE FROM #DanePodstawoweTmp;
					
					SET @Query = 'INSERT INTO #DanePodstawoweTmp (Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn)
					SELECT Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn					
					FROM [Relacja_Typ] 
					WHERE 1=1 ' + @StandardWhere;
	
					--PRINT @Query;
					EXECUTE sp_executesql @Query;

					INSERT INTO #DanePodstawowe (Id)
					SELECT ISNULL(b.IdArch, b.Id) From #DanePodstawoweTmp b WHERE b.IdArch IS NULL AND NOT EXISTS (SELECT b2.Id From #DanePodstawoweTmp b2 WHERE b2.Id = b.IdArchLink);

					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','curBr') > 0 
					BEGIN
						 CLOSE curBr
						 DEALLOCATE curBr
					END
			
					DECLARE curBr CURSOR LOCAL FOR 
					SELECT DISTINCT IdArch FROM #DanePodstawoweTmp WHERE IdArch IS NOT NULL AND IdArch NOT IN (SELECT Id FROM #DanePodstawowe)
					OPEN curBr
					FETCH NEXT FROM curBr INTO @IdArch
					WHILE @@FETCH_STATUS = 0
					BEGIN						
						INSERT INTO #DanePodstawowe (Id)
						SELECT TOP 1 ISNULL(IdArch, Id) FROM #DanePodstawoweTmp
						WHERE Id = @IdArch OR IdArch = @IdArch
						ORDER BY (DATEPART(yy, RealCreatedOn) + DATEPART(mm, RealCreatedOn) + DATEPART(dd, RealCreatedOn)) DESC, ValidFrom DESC
						
						FETCH NEXT FROM curBr INTO @IdArch
					END
					CLOSE curBr
					DEALLOCATE curBr;
					
					--pobranie ilosci bazowych typów relacji
					SET @RelacjaBazowyTypIlosc = (SELECT COUNT(1) FROM #DanePodstawowe);	
					
					INSERT INTO #IloscElementowWBazie (Ilosc, TypElementu)
					VALUES (@RelacjaBazowyTypIlosc, 'RelationBaseType');				
		
---------- TYP RELACJI ---------

					DELETE FROM #DanePodstawowe;
					DELETE FROM #DanePodstawoweTmp;
					
					SET @Query = 'INSERT INTO #DanePodstawoweTmp (Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn)
					SELECT TypRelacji_ID, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn					
					FROM [TypRelacji] 
					WHERE 1=1 ' + @StandardWhere;
	
					--PRINT @Query;
					EXECUTE sp_executesql @Query;

					INSERT INTO #DanePodstawowe (Id)
					SELECT ISNULL(b.IdArch, b.Id) From #DanePodstawoweTmp b WHERE b.IdArch IS NULL AND NOT EXISTS (SELECT b2.Id From #DanePodstawoweTmp b2 WHERE b2.Id = b.IdArchLink);

					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','curBr') > 0 
					BEGIN
						 CLOSE curBr
						 DEALLOCATE curBr
					END
			
					DECLARE curBr CURSOR LOCAL FOR 
					SELECT DISTINCT IdArch FROM #DanePodstawoweTmp WHERE IdArch IS NOT NULL AND IdArch NOT IN (SELECT Id FROM #DanePodstawowe)
					OPEN curBr
					FETCH NEXT FROM curBr INTO @IdArch
					WHILE @@FETCH_STATUS = 0
					BEGIN						
						INSERT INTO #DanePodstawowe (Id)
						SELECT TOP 1 ISNULL(IdArch, Id) FROM #DanePodstawoweTmp
						WHERE Id = @IdArch OR IdArch = @IdArch
						ORDER BY (DATEPART(yy, RealCreatedOn) + DATEPART(mm, RealCreatedOn) + DATEPART(dd, RealCreatedOn)) DESC, ValidFrom DESC
						
						FETCH NEXT FROM curBr INTO @IdArch
					END
					CLOSE curBr
					DEALLOCATE curBr;
					
					--pobranie ilosci typów relacji
					SET @TypRelacjiIlosc = (SELECT COUNT(1) FROM #DanePodstawowe);	
					
					INSERT INTO #IloscElementowWBazie (Ilosc, TypElementu)
					VALUES (@TypRelacjiIlosc, 'RelationType');	
					
---------- RELACJE ---------

					DELETE FROM #DanePodstawowe;
					DELETE FROM #DanePodstawoweTmp;
					
					SET @Query = 'INSERT INTO #DanePodstawoweTmp (Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn)
					SELECT Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn					
					FROM [Relacje] 
					WHERE 1=1 ' + @StandardWhere;
	
					--PRINT @Query;
					EXECUTE sp_executesql @Query;

					INSERT INTO #DanePodstawowe (Id)
					SELECT ISNULL(b.IdArch, b.Id) FROM #DanePodstawoweTmp b WHERE b.IdArch IS NULL AND NOT EXISTS (SELECT b2.Id From #DanePodstawoweTmp b2 WHERE b2.Id = b.IdArchLink);

					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','curBr') > 0 
					BEGIN
						 CLOSE curBr
						 DEALLOCATE curBr
					END
			
					DECLARE curBr CURSOR LOCAL FOR 
					SELECT DISTINCT IdArch FROM #DanePodstawoweTmp WHERE IdArch IS NOT NULL AND IdArch NOT IN (SELECT Id FROM #DanePodstawowe)
					OPEN curBr
					FETCH NEXT FROM curBr INTO @IdArch
					WHILE @@FETCH_STATUS = 0
					BEGIN						
						INSERT INTO #DanePodstawowe (Id)
						SELECT TOP 1 ISNULL(IdArch, Id) FROM #DanePodstawoweTmp
						WHERE Id = @IdArch OR IdArch = @IdArch
						ORDER BY (DATEPART(yy, RealCreatedOn) + DATEPART(mm, RealCreatedOn) + DATEPART(dd, RealCreatedOn)) DESC, ValidFrom DESC
						
						FETCH NEXT FROM curBr INTO @IdArch
					END
					CLOSE curBr
					DEALLOCATE curBr;
					
					--pobranie ilosci relacji
					SET @RelacjeIlosc = (SELECT COUNT(1) FROM #DanePodstawowe);	
					
					INSERT INTO #IloscElementowWBazie (Ilosc, TypElementu)
					VALUES (@RelacjeIlosc, 'Relation');						
	
---------- CECHY RELACJI ---------

					DELETE FROM #DanePomocnicze;
					DELETE FROM #DanePomocniczeTmp;
					
					SET @Query = 'INSERT INTO #DanePomocniczeTmp (Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn)
					SELECT Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn					
					FROM [Relacja_Cecha_Hist] 
					WHERE RelacjaId IN (SELECT Id FROM #DanePodstawowe) ' + @StandardWhere;
	
					--PRINT @Query;
					EXECUTE sp_executesql @Query;

					INSERT INTO #DanePomocnicze (Id)
					SELECT ISNULL(b.IdArch, b.Id) FROM #DanePomocniczeTmp b WHERE b.IdArch IS NULL AND NOT EXISTS (SELECT b2.Id From #DanePomocniczeTmp b2 WHERE b2.Id = b.IdArchLink);

					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','curBr') > 0 
					BEGIN
						 CLOSE curBr
						 DEALLOCATE curBr
					END
			
					DECLARE curBr CURSOR LOCAL FOR 
					SELECT DISTINCT IdArch FROM #DanePomocniczeTmp WHERE IdArch IS NOT NULL AND IdArch NOT IN (SELECT Id FROM #DanePomocnicze)
					OPEN curBr
					FETCH NEXT FROM curBr INTO @IdArch
					WHILE @@FETCH_STATUS = 0
					BEGIN						
						INSERT INTO #DanePomocnicze (Id)
						SELECT TOP 1 ISNULL(IdArch, Id) FROM #DanePomocniczeTmp
						WHERE Id = @IdArch OR IdArch = @IdArch
						ORDER BY (DATEPART(yy, RealCreatedOn) + DATEPART(mm, RealCreatedOn) + DATEPART(dd, RealCreatedOn)) DESC, ValidFrom DESC
						
						FETCH NEXT FROM curBr INTO @IdArch
					END
					CLOSE curBr
					DEALLOCATE curBr;
					
					--pobranie ilosci cech dla relacji
					SET @RelacjeCechyIlosc = (SELECT COUNT(1) FROM #DanePomocnicze);	
					
					INSERT INTO #IloscElementowWBazie (Ilosc, TypElementu)
					VALUES (@RelacjeCechyIlosc, 'RelationAttributes');	
					
---------- ROLE ---------

					DELETE FROM #DanePodstawowe;
					DELETE FROM #DanePodstawoweTmp;
					
					SET @Query = 'INSERT INTO #DanePodstawoweTmp (Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn)
					SELECT Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn					
					FROM [Role] 
					WHERE 1=1 ' + @StandardWhere;
	
					--PRINT @Query;
					EXECUTE sp_executesql @Query;

					INSERT INTO #DanePodstawowe (Id)
					SELECT b.Id FROM #DanePodstawoweTmp b WHERE b.IdArch IS NULL AND NOT EXISTS (SELECT b2.Id From #DanePodstawoweTmp b2 WHERE b2.Id = b.IdArchLink);

					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','curBr') > 0 
					BEGIN
						 CLOSE curBr
						 DEALLOCATE curBr
					END
			
					DECLARE curBr CURSOR LOCAL FOR 
					SELECT DISTINCT IdArch FROM #DanePodstawoweTmp WHERE IdArch IS NOT NULL AND IdArch NOT IN (SELECT Id FROM #DanePodstawowe)
					OPEN curBr
					FETCH NEXT FROM curBr INTO @IdArch
					WHILE @@FETCH_STATUS = 0
					BEGIN						
						INSERT INTO #DanePodstawowe (Id)
						SELECT TOP 1 Id FROM #DanePodstawoweTmp
						WHERE Id = @IdArch OR IdArch = @IdArch
						ORDER BY (DATEPART(yy, RealCreatedOn) + DATEPART(mm, RealCreatedOn) + DATEPART(dd, RealCreatedOn)) DESC, ValidFrom DESC
						
						FETCH NEXT FROM curBr INTO @IdArch
					END
					CLOSE curBr
					DEALLOCATE curBr;
					
					--pobranie ilosci ról
					SET @RoleIlosc = (SELECT COUNT(1) FROM #DanePodstawowe);	
					
					INSERT INTO #IloscElementowWBazie (Ilosc, TypElementu)
					VALUES (@RoleIlosc, 'Role');
										
---------- SŁOWNIKI ---------

					DELETE FROM #DanePodstawowe;
					DELETE FROM #DanePodstawoweTmp;
					
					SET @Query = 'INSERT INTO #DanePodstawoweTmp (Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn)
					SELECT Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn					
					FROM [Slowniki] 
					WHERE 1=1 ' + @StandardWhere;
	
					--PRINT @Query;
					EXECUTE sp_executesql @Query;

					INSERT INTO #DanePodstawowe (Id)
					SELECT ISNULL(b.IdArch, b.Id) From #DanePodstawoweTmp b WHERE b.IdArch IS NULL AND NOT EXISTS (SELECT b2.Id From #DanePodstawoweTmp b2 WHERE b2.Id = b.IdArchLink);

					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','curBr') > 0 
					BEGIN
						 CLOSE curBr
						 DEALLOCATE curBr
					END
			
					DECLARE curBr CURSOR LOCAL FOR 
					SELECT DISTINCT IdArch FROM #DanePodstawoweTmp WHERE IdArch IS NOT NULL AND IdArch NOT IN (SELECT Id FROM #DanePodstawowe)
					OPEN curBr
					FETCH NEXT FROM curBr INTO @IdArch
					WHILE @@FETCH_STATUS = 0
					BEGIN						
						INSERT INTO #DanePodstawowe (Id)
						SELECT TOP 1 ISNULL(IdArch, Id) FROM #DanePodstawoweTmp
						WHERE Id = @IdArch OR IdArch = @IdArch
						ORDER BY (DATEPART(yy, RealCreatedOn) + DATEPART(mm, RealCreatedOn) + DATEPART(dd, RealCreatedOn)) DESC, ValidFrom DESC
						
						FETCH NEXT FROM curBr INTO @IdArch
					END
					CLOSE curBr
					DEALLOCATE curBr;
					
					--pobranie ilosci ról
					SET @SlownikiIlosc = (SELECT COUNT(1) FROM #DanePodstawowe);	
					
					INSERT INTO #IloscElementowWBazie (Ilosc, TypElementu)
					VALUES (@SlownikiIlosc, 'Dictionary');					
					
---------- WPISY SŁOWNIKÓW ---------
					SET @SlownikiWpisyIlosc = 0;

					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','curSl') > 0 
					BEGIN
						 CLOSE curSl
						 DEALLOCATE curSl
					END
			
					--pobranie nazw slownikow - nazw tabel
					DECLARE curSl CURSOR LOCAL FOR 
					SELECT Nazwa FROM dbo.[Slowniki] WHERE Id IN (SELECT Id FROM #DanePodstawowe)
					OPEN curSl
					FETCH NEXT FROM curSl INTO @NazwaTabeli
					WHILE @@FETCH_STATUS = 0
					BEGIN
					
						DELETE FROM #DanePomocniczeTmp;
						DELETE FROM #DanePomocnicze;
					
						SET @Query = '
						IF OBJECT_ID (N''[_Slownik_' + @NazwaTabeli + ']'', N''U'') IS NOT NULL
						BEGIN
							INSERT INTO #DanePomocniczeTmp (Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn)
							SELECT Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn					
							FROM [_Slownik_' + @NazwaTabeli + ']
							WHERE 1=1 ' + @StandardWhere + '
						END';
			
						--PRINT @Query;
						EXECUTE sp_executesql @Query;

						INSERT INTO #DanePomocnicze (Id)
						SELECT b.Id FROM #DanePomocniczeTmp b WHERE b.IdArch IS NULL AND NOT EXISTS (SELECT b2.Id From #DanePomocniczeTmp b2 WHERE b2.Id = b.IdArchLink);
						
						--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
						IF Cursor_Status('local','curBr') > 0 
						BEGIN
							 CLOSE curBr
							 DEALLOCATE curBr
						END
				
						DECLARE curBr CURSOR LOCAL FOR 
						SELECT DISTINCT IdArch FROM #DanePomocniczeTmp WHERE IdArch IS NOT NULL AND IdArch NOT IN (SELECT Id FROM #DanePomocnicze)
						OPEN curBr
						FETCH NEXT FROM curBr INTO @IdArch
						WHILE @@FETCH_STATUS = 0
						BEGIN						
							INSERT INTO #DanePomocnicze (Id)
							SELECT TOP 1 ISNULL(IdArch, Id) FROM #DanePomocniczeTmp
							WHERE Id = @IdArch OR IdArch = @IdArch
							ORDER BY (DATEPART(yy, RealCreatedOn) + DATEPART(mm, RealCreatedOn) + DATEPART(dd, RealCreatedOn)) DESC, ValidFrom DESC
							
							FETCH NEXT FROM curBr INTO @IdArch
						END
						CLOSE curBr
						DEALLOCATE curBr;
									
						--pobranie ilosci wpisów slownika
						SET @SlownikiWpisyIlosc += (SELECT COUNT(1) FROM #DanePomocnicze);										
						
						FETCH NEXT FROM curSl INTO @NazwaTabeli
					END
					CLOSE curSl
					DEALLOCATE curSl
					
					INSERT INTO #IloscElementowWBazie (Ilosc, TypElementu)
					VALUES (@SlownikiWpisyIlosc, 'DictionaryEntry');					

---------- TYP STRUKTURY_OBIEKT ---------

					DELETE FROM #DanePodstawowe;
					DELETE FROM #DanePodstawoweTmp;
					
					SET @Query = 'INSERT INTO #DanePodstawoweTmp (Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn)
					SELECT Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn					
					FROM [TypStruktury_Obiekt] 
					WHERE 1=1 ' + @StandardWhere;
	
					--PRINT @Query;
					EXECUTE sp_executesql @Query;

					INSERT INTO #DanePodstawowe (Id)
					SELECT ISNULL(b.IdArch, b.Id) FROM #DanePodstawoweTmp b WHERE b.IdArch IS NULL AND NOT EXISTS (SELECT b2.Id From #DanePodstawoweTmp b2 WHERE b2.Id = b.IdArchLink);

					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','curBr') > 0 
					BEGIN
						 CLOSE curBr
						 DEALLOCATE curBr
					END
			
					DECLARE curBr CURSOR LOCAL FOR 
					SELECT DISTINCT IdArch FROM #DanePodstawoweTmp WHERE IdArch IS NOT NULL AND IdArch NOT IN (SELECT Id FROM #DanePodstawowe)
					OPEN curBr
					FETCH NEXT FROM curBr INTO @IdArch
					WHILE @@FETCH_STATUS = 0
					BEGIN						
						INSERT INTO #DanePodstawowe (Id)
						SELECT TOP 1 ISNULL(IdArch, Id) FROM #DanePodstawoweTmp
						WHERE Id = @IdArch OR IdArch = @IdArch
						ORDER BY (DATEPART(yy, RealCreatedOn) + DATEPART(mm, RealCreatedOn) + DATEPART(dd, RealCreatedOn)) DESC, ValidFrom DESC
						
						FETCH NEXT FROM curBr INTO @IdArch
					END
					CLOSE curBr
					DEALLOCATE curBr;
					
					--pobranie ilosci typów struktury obiekt
					SET @TypStrukturyObiektIlosc = (SELECT COUNT(1) FROM #DanePodstawowe);	
					
					INSERT INTO #IloscElementowWBazie (Ilosc, TypElementu)
					VALUES (@TypStrukturyObiektIlosc, 'StructureType');
					
---------- TYP STRUKTURY ---------

					DELETE FROM #DanePomocnicze;
					DELETE FROM #DanePomocniczeTmp;
					
					SET @Query = 'INSERT INTO #DanePomocniczeTmp (Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn)
					SELECT Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn					
					FROM [TypStruktury] 
					WHERE TypStruktury_Obiekt_Id IN (SELECT Id FROM #DanePodstawowe) ' + @StandardWhere;
	
					--PRINT @Query;
					EXECUTE sp_executesql @Query;

					INSERT INTO #DanePomocnicze (Id)
					SELECT ISNULL(b.IdArch, b.Id) FROM #DanePomocniczeTmp b WHERE b.IdArch IS NULL AND NOT EXISTS (SELECT b2.Id From #DanePomocniczeTmp b2 WHERE b2.Id = b.IdArchLink);

					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','curBr') > 0 
					BEGIN
						 CLOSE curBr
						 DEALLOCATE curBr
					END
			
					DECLARE curBr CURSOR LOCAL FOR 
					SELECT DISTINCT IdArch FROM #DanePomocniczeTmp WHERE IdArch IS NOT NULL AND IdArch NOT IN (SELECT Id FROM #DanePomocnicze)
					OPEN curBr
					FETCH NEXT FROM curBr INTO @IdArch
					WHILE @@FETCH_STATUS = 0
					BEGIN						
						INSERT INTO #DanePomocnicze (Id)
						SELECT TOP 1 ISNULL(IdArch, Id) FROM #DanePomocniczeTmp
						WHERE Id = @IdArch OR IdArch = @IdArch
						ORDER BY (DATEPART(yy, RealCreatedOn) + DATEPART(mm, RealCreatedOn) + DATEPART(dd, RealCreatedOn)) DESC, ValidFrom DESC
						
						FETCH NEXT FROM curBr INTO @IdArch
					END
					CLOSE curBr
					DEALLOCATE curBr;
					
					--pobranie ilosci typów struktury
					SET @TypStrukturyIlosc = (SELECT COUNT(1) FROM #DanePomocnicze);	
					
					INSERT INTO #IloscElementowWBazie (Ilosc, TypElementu)
					VALUES (@TypStrukturyIlosc, 'CouplerStructureType');							
					
---------- STRUKTURA/STRUKTURA_OBIEKT ---------

					DELETE FROM #DanePomocnicze;
					DELETE FROM #DanePomocniczeTmp;
					
					SET @Query = 'INSERT INTO #DanePomocniczeTmp (Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn)
					SELECT Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn					
					FROM [Struktura_Obiekt] 
					WHERE TypStruktury_Obiekt_Id IN (SELECT Id FROM #DanePodstawowe) ' + @StandardWhere;
	
					--PRINT @Query;
					EXECUTE sp_executesql @Query;

					INSERT INTO #DanePomocnicze (Id)
					SELECT ISNULL(b.IdArch, b.Id) FROM #DanePomocniczeTmp b WHERE b.IdArch IS NULL AND NOT EXISTS (SELECT b2.Id From #DanePomocniczeTmp b2 WHERE b2.Id = b.IdArchLink);

					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','curBr') > 0 
					BEGIN
						 CLOSE curBr
						 DEALLOCATE curBr
					END
			
					DECLARE curBr CURSOR LOCAL FOR 
					SELECT DISTINCT IdArch FROM #DanePomocniczeTmp WHERE IdArch IS NOT NULL AND IdArch NOT IN (SELECT Id FROM #DanePomocnicze)
					OPEN curBr
					FETCH NEXT FROM curBr INTO @IdArch
					WHILE @@FETCH_STATUS = 0
					BEGIN						
						INSERT INTO #DanePomocnicze (Id)
						SELECT TOP 1 ISNULL(IdArch, Id) FROM #DanePomocniczeTmp
						WHERE Id = @IdArch OR IdArch = @IdArch
						ORDER BY (DATEPART(yy, RealCreatedOn) + DATEPART(mm, RealCreatedOn) + DATEPART(dd, RealCreatedOn)) DESC, ValidFrom DESC
						
						FETCH NEXT FROM curBr INTO @IdArch
					END
					CLOSE curBr
					DEALLOCATE curBr;
					
					--pobranie ilosci struktur
					SET @StrukturaIlosc = (SELECT COUNT(1) FROM #DanePomocnicze);	
					
					INSERT INTO #IloscElementowWBazie (Ilosc, TypElementu)
					VALUES (@StrukturaIlosc, 'Structure');					
					
---------- UZYTKOWNICY ---------

					DELETE FROM #DanePodstawowe;
					DELETE FROM #DanePodstawoweTmp;
					
					SET @Query = 'INSERT INTO #DanePodstawoweTmp (Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn)
					SELECT Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn					
					FROM [Uzytkownicy] 
					WHERE 1=1 ' + @StandardWhere;
	
					--PRINT @Query;
					EXECUTE sp_executesql @Query;

					INSERT INTO #DanePodstawowe (Id)
					SELECT ISNULL(b.IdArch, b.Id) FROM #DanePodstawoweTmp b WHERE b.IdArch IS NULL AND NOT EXISTS (SELECT b2.Id From #DanePodstawoweTmp b2 WHERE b2.Id = b.IdArchLink);

					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','curBr') > 0 
					BEGIN
						 CLOSE curBr
						 DEALLOCATE curBr
					END
			
					DECLARE curBr CURSOR LOCAL FOR 
					SELECT DISTINCT IdArch FROM #DanePodstawoweTmp WHERE IdArch IS NOT NULL AND IdArch NOT IN (SELECT Id FROM #DanePodstawowe)
					OPEN curBr
					FETCH NEXT FROM curBr INTO @IdArch
					WHILE @@FETCH_STATUS = 0
					BEGIN						
						INSERT INTO #DanePodstawowe (Id)
						SELECT TOP 1 ISNULL(IdArch, Id) FROM #DanePodstawoweTmp
						WHERE Id = @IdArch OR IdArch = @IdArch
						ORDER BY (DATEPART(yy, RealCreatedOn) + DATEPART(mm, RealCreatedOn) + DATEPART(dd, RealCreatedOn)) DESC, ValidFrom DESC
						
						FETCH NEXT FROM curBr INTO @IdArch
					END
					CLOSE curBr
					DEALLOCATE curBr;
					
					--pobranie ilosci użytkowników
					SET @UzytkownicyIlosc = (SELECT COUNT(1) FROM #DanePodstawowe);	
					
					INSERT INTO #IloscElementowWBazie (Ilosc, TypElementu)
					VALUES (@UzytkownicyIlosc, 'User');

---------- TYPY OBIEKTU ---------

					DELETE FROM #DanePodstawowe;
					DELETE FROM #DanePodstawoweTmp;
					
					SET @Query = 'INSERT INTO #DanePodstawoweTmp (Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn)
					SELECT TypObiekt_ID, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn					
					FROM [TypObiektu] 
					WHERE 1=1 ' + @StandardWhere;
	
					--PRINT @Query;
					EXECUTE sp_executesql @Query;

					INSERT INTO #DanePodstawowe (Id)
					SELECT ISNULL(b.IdArch, b.Id) FROM #DanePodstawoweTmp b WHERE b.IdArch IS NULL AND NOT EXISTS (SELECT b2.Id From #DanePodstawoweTmp b2 WHERE b2.Id = b.IdArchLink);

					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','curBr') > 0 
					BEGIN
						 CLOSE curBr
						 DEALLOCATE curBr
					END
			
					DECLARE curBr CURSOR LOCAL FOR 
					SELECT DISTINCT IdArch FROM #DanePodstawoweTmp WHERE IdArch IS NOT NULL AND IdArch NOT IN (SELECT Id FROM #DanePodstawowe)
					OPEN curBr
					FETCH NEXT FROM curBr INTO @IdArch
					WHILE @@FETCH_STATUS = 0
					BEGIN						
						INSERT INTO #DanePodstawowe (Id)
						SELECT TOP 1 ISNULL(IdArch, Id) FROM #DanePodstawoweTmp
						WHERE Id = @IdArch OR IdArch = @IdArch
						ORDER BY (DATEPART(yy, RealCreatedOn) + DATEPART(mm, RealCreatedOn) + DATEPART(dd, RealCreatedOn)) DESC, ValidFrom DESC
						
						FETCH NEXT FROM curBr INTO @IdArch
					END
					CLOSE curBr
					DEALLOCATE curBr;
					
					--pobranie ilosci typów obiektu
					SET @TypObiektuIlosc = (SELECT COUNT(1) FROM #DanePodstawowe);	
					
					INSERT INTO #IloscElementowWBazie (Ilosc, TypElementu)
					VALUES (@TypObiektuIlosc, 'UnitType');
					
---------- ILOSC OBIEKTOW DANEGO TYPU/ILOSC CECH OBIEKTOW ---------

					SET @ObiektyIlosc = 0;
					SET @ObiektyCechyIlosc = 0;

					--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
					IF Cursor_Status('local','curSl') > 0 
					BEGIN
						 CLOSE curSl
						 DEALLOCATE curSl
					END
			
					--pobranie nazw typów obiektów - nazw tabel
					DECLARE curSl CURSOR LOCAL FOR 
					SELECT Nazwa FROM dbo.[TypObiektu] WHERE TypObiekt_Id IN (SELECT Id FROM #DanePodstawowe)
					OPEN curSl
					FETCH NEXT FROM curSl INTO @NazwaTabeli
					WHILE @@FETCH_STATUS = 0
					BEGIN
					
				---- Ilosc obiektow ----	
					
						DELETE FROM #DanePomocniczeTmp;
						DELETE FROM #DanePomocnicze;
					
						SET @Query = '
						IF OBJECT_ID (N''[_' + @NazwaTabeli + ']'', N''U'') IS NOT NULL
						BEGIN
							INSERT INTO #DanePomocniczeTmp (Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn)
							SELECT Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn					
							FROM [_' + @NazwaTabeli + ']
							WHERE 1=1 ' + @StandardWhere + '
						END';
			
						--PRINT @Query;
						EXECUTE sp_executesql @Query;

						INSERT INTO #DanePomocnicze (Id)
						SELECT b.Id FROM #DanePomocniczeTmp b WHERE b.IdArch IS NULL AND NOT EXISTS (SELECT b2.Id From #DanePomocniczeTmp b2 WHERE b2.Id = b.IdArchLink);
						
						--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
						IF Cursor_Status('local','curBr') > 0 
						BEGIN
							 CLOSE curBr
							 DEALLOCATE curBr
						END
				
						DECLARE curBr CURSOR LOCAL FOR 
						SELECT DISTINCT IdArch FROM #DanePomocniczeTmp WHERE IdArch IS NOT NULL AND IdArch NOT IN (SELECT Id FROM #DanePomocnicze)
						OPEN curBr
						FETCH NEXT FROM curBr INTO @IdArch
						WHILE @@FETCH_STATUS = 0
						BEGIN						
							INSERT INTO #DanePomocnicze (Id)
							SELECT TOP 1 ISNULL(IdArch, Id) FROM #DanePomocniczeTmp
							WHERE Id = @IdArch OR IdArch = @IdArch
							ORDER BY (DATEPART(yy, RealCreatedOn) + DATEPART(mm, RealCreatedOn) + DATEPART(dd, RealCreatedOn)) DESC, ValidFrom DESC
							
							FETCH NEXT FROM curBr INTO @IdArch
						END
						CLOSE curBr
						DEALLOCATE curBr;
									
						--pobranie ilosci wpisów slownika
						SET @ObiektyIlosc += (SELECT COUNT(1) FROM #DanePomocnicze);
						
				---- Ilosc cech obiektow ----		
						DELETE FROM #DanePomocniczeTmp;
						DELETE FROM #DanePomocnicze;
					
						SET @Query = '
						IF OBJECT_ID (N''[_' + @NazwaTabeli + '_Cechy_Hist]'', N''U'') IS NOT NULL
						BEGIN
							INSERT INTO #DanePomocniczeTmp (Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn)
							SELECT Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn					
							FROM [_' + @NazwaTabeli + '_Cechy_Hist]
							WHERE 1=1 ' + @StandardWhere + '
						END';
			
						--PRINT @Query;
						EXECUTE sp_executesql @Query;

						INSERT INTO #DanePomocnicze (Id)
						SELECT b.Id FROM #DanePomocniczeTmp b WHERE b.IdArch IS NULL AND NOT EXISTS (SELECT b2.Id From #DanePomocniczeTmp b2 WHERE b2.Id = b.IdArchLink);
						
						--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
						IF Cursor_Status('local','curBr') > 0 
						BEGIN
							 CLOSE curBr
							 DEALLOCATE curBr
						END
				
						DECLARE curBr CURSOR LOCAL FOR 
						SELECT DISTINCT IdArch FROM #DanePomocniczeTmp WHERE IdArch IS NOT NULL AND IdArch NOT IN (SELECT Id FROM #DanePomocnicze)
						OPEN curBr
						FETCH NEXT FROM curBr INTO @IdArch
						WHILE @@FETCH_STATUS = 0
						BEGIN						
							INSERT INTO #DanePomocnicze (Id)
							SELECT TOP 1 ISNULL(IdArch, Id) FROM #DanePomocniczeTmp
							WHERE Id = @IdArch OR IdArch = @IdArch
							ORDER BY (DATEPART(yy, RealCreatedOn) + DATEPART(mm, RealCreatedOn) + DATEPART(dd, RealCreatedOn)) DESC, ValidFrom DESC
							
							FETCH NEXT FROM curBr INTO @IdArch
						END
						CLOSE curBr
						DEALLOCATE curBr;
									
						--pobranie ilosci wpisów slownika
						SET @ObiektyCechyIlosc += (SELECT COUNT(1) FROM #DanePomocnicze);						
																
						
						FETCH NEXT FROM curSl INTO @NazwaTabeli
					END
					CLOSE curSl
					DEALLOCATE curSl
					
					INSERT INTO #IloscElementowWBazie (Ilosc, TypElementu)
					VALUES (@ObiektyIlosc, 'Unit');
					
					INSERT INTO #IloscElementowWBazie (Ilosc, TypElementu)
					VALUES (@ObiektyCechyIlosc, 'UnitAttributes');
					
								
					-- przygotowanie XMLa wynikowego
					SET @Query = '
					SET @xmlTemp = (
						SELECT Ilosc AS "@Count"
							 , TypElementu AS "@EntityType"
						FROM #IloscElementowWBazie
						ORDER BY TypElementu
						FOR XML PATH(''Statistic''), ROOT(''Statistics'') )'
					
					--PRINT @query;
					EXECUTE sp_executesql @query, N'@xmlTemp xml OUTPUT', @xmlTemp = @xmlResponse OUTPUT					
					
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Database_GetStatistics', @Wiadomosc = @ERRMSG OUTPUT 
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Database_GetStatistics', @Wiadomosc = @ERRMSG OUTPUT
			
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH		
		END
		
	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Database_GetStatistics"';
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
	
	SET @XMLDataOut += '>'	
	
	IF @ERRMSG iS NULL OR @ERRMSG = ''		
		SET @XMLDataOut += ISNULL(CAST(@xmlResponse AS nvarchar(MAX)), '');
	ELSE
		SET @XMLDataOut += '<Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/>';
	
	SET @XMLDataOut += '</Response>'; 
	
	--usuwanie tabel tymczasowych, jesli istnieja
	IF OBJECT_ID('tempdb..#DanePodstawoweTmp') IS NOT NULL
		DROP TABLE #DanePodstawoweTmp
		
	IF OBJECT_ID('tempdb..#DanePodstawowe') IS NOT NULL
		DROP TABLE #DanePodstawowe
		
	IF OBJECT_ID('tempdb..#DanePomocnicze') IS NOT NULL
		DROP TABLE #DanePomocnicze
		
	IF OBJECT_ID('tempdb..#DanePomocniczeTmp') IS NOT NULL
		DROP TABLE #DanePomocniczeTmp
		
	IF OBJECT_ID('tempdb..#IloscElementowWBazie') IS NOT NULL
		DROP TABLE #IloscElementowWBazie
		
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut
		
	--sp_helpdb THBZasobyDemo
END
