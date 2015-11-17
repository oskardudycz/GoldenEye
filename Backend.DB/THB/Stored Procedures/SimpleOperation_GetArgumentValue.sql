-- =============================================
-- Author:		DK
-- Create date: 2012-10-15
-- Last modified on: 2012-12-04
-- Description:	Pobiera wartosc cechy bioracej udzial w wyliczeniach
-- =============================================
CREATE PROCEDURE [THB].[SimpleOperation_GetArgumentValue]
(
	@Id int,
	@TypeId int,
	@AttributeTypeId int,
	@AttributeValue varchar(20),
	@Type varchar(20),
	@StatusS int,
	@StatusW int,
	@StatusP int,
	@AppDate datetime,
	@UserId int,
	@BranchId int,
	@Value nvarchar(20) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DefaultValue varchar(5) = '0',
			@StandardWhere nvarchar(MAX),
			@DataProgramu datetime,
			@Query nvarchar(MAX) = '',
			@CechyWidoczneDlaUzytkownika nvarchar(MAX),
			@LowerTypeName varchar(30),
			@NazwaTypuObiektu nvarchar(300),
			@IdArch int,
			@XmlValue xml,
			@TableName nvarchar(MAX),
			@DateFromColumnName nvarchar(100)
	
--	BEGIN TRY
		--usuniecie tabel tymczasowych
		IF OBJECT_ID('tempdb..#GetValue_CechyFinal') IS NOT NULL
			DROP TABLE #GetValue_CechyFinal

		CREATE TABLE #GetValue_CechyFinal(Id int);
	
		-- pobranie daty na podstawie przekazanego AppDate
		SELECT @DataProgramu = THB.PrepareAppDate(@AppDate);	

		--pobranie nazwy kolumny po ktorej filtrowane sa daty
		SET @DateFromColumnName = [THB].[GetDateFromFilterColumn]();			
		
		--dodanie frazy statusow na filtracje jesli trzeba
		SET @StandardWhere = [THB].[PrepareStatusesPhrase] ('ch3', @StatusS, @StatusP, @StatusW);
		
		--dodanie frazy na daty
		SET @StandardWhere += [THB].[PrepareDatesPhrase] ('ch3', @AppDate);
	
		-- pobranie Id cech do ktorych uzytkownik ma dostep
		EXEC [THB].[GetUserAttributeTypes]
			@Alias = 'ch3',
			@DataProgramu = @DataProgramu,
			@UserId = @UserId,
			@BranchId = @BranchId,
			@AtributeTypesWhere = @CechyWidoczneDlaUzytkownika OUTPUT
	
		SET @LowerTypeName = LOWER(@Type);

		-- jesli skalar to przepisanie wartosci na wyjscie
		IF @LowerTypeName = 'scalar'
		BEGIN
		
			IF @AttributeValue IS NOT NULL AND ISNUMERIC(@AttributeValue) = 1
				SET @Value = @AttributeValue;
			ELSE
				SET @Value = @DefaultValue;
		END
		ELSE IF @LowerTypeName = 'relation' OR @LowerTypeName = 'unit'
		BEGIN
		
			IF @LowerTypeName = 'relation'
			BEGIN
				SET @TableName = '[dbo].[Relacja_Cecha_Hist]';
			END
			ELSE IF @LowerTypeName = 'unit'
			BEGIN
				-- pobranie nazwy typu obiektu
				SELECT @NazwaTypuObiektu = Nazwa
				FROM dbo.[TypObiektu]
				WHERE (TypObiekt_ID = @TypeId Or IdArch = @TypeId) AND IsValid = 1 AND IsDeleted = 0;
				
				SET @TableName = '[dbo].[_' + @NazwaTypuObiektu + '_Cechy_Hist]';
			
			END				
		
			SET @Query = '
				INSERT INTO #GetValue_CechyFinal (Id)
				SELECT allData.Id FROM
				(
					SELECT ch.Id, ROW_NUMBER() OVER(PARTITION BY ISNULL(ch.IdArch, ch.Id) ORDER BY ch.Id ASC) AS Rn
					FROM ' + @TableName + ' ch
					INNER JOIN
					(
						SELECT ISNULL(ch2.IdArch, ch2.Id) AS RowID, MAX(RealCreatedOn) AS MaxRealCreatedOn, ch2.' + @DateFromColumnName + ' AS MaxDate
						FROM ' + @TableName + ' ch2								 
						INNER JOIN 
						(
							SELECT ISNULL(ch3.IdArch, ch3.Id) AS RowID, MAX(ch3.' + @DateFromColumnName + ') AS MaxDate
							FROM ' + @TableName + ' ch3'								
						
			SET @Query += '
							JOIN dbo.[Cechy] c ON (c.Cecha_ID = ch3.CechaID)
							WHERE ch3.IsMainHistFlow = 1 AND ch3.CechaId = ' + CAST(@AttributeTypeId AS varchar)
			
			IF @LowerTypeName = 'relation'
				SET @Query += ' AND ch3.RelacjaId = ' + CAST(@Id AS varchar) + @StandardWhere;
			ELSE
				SET @Query += ' AND ch3.ObiektId = ' + CAST(@Id AS varchar) + @StandardWhere;									
									
			SET @Query += '
							GROUP BY ISNULL(ch3.IdArch, ch3.Id)
						) latest
						ON ISNULL(ch2.IdArch, ch2.Id) = latest.RowID AND ch2.' + @DateFromColumnName + ' = latest.MaxDate
						WHERE ch2.IsMainHistFlow = 1
						GROUP BY ISNULL(ch2.IdArch, ch2.Id), ch2.' + @DateFromColumnName + '					
					) latestWithMaxDate
					ON  ISNULL(ch.IdArch, ch.Id) = latestWithMaxDate.RowID AND ch.RealCreatedOn = latestWithMaxDate.MaxRealCreatedOn AND ch.' + @DateFromColumnName + ' = latestWithMaxDate.MaxDate
					WHERE ch.IsMainHistFlow = 1
				) allData
				WHERE allData.Rn = 1'	
				
				
			EXECUTE sp_executesql @Query;	
		
		
	/*		--pobranie danych pasujacych branz do tabeli tymczasowej							
			SET @Query = 'INSERT INTO #GetValue_CechyTmp (Id, IdArch, IdArchLink, ValidFrom, ValidTo, RealCreatedOn)
					SELECT ch.Id, ch.IdArch, ch.IdArchLink, ch.ValidFrom, ch.ValidTo, ch.RealCreatedOn'
			
			IF @LowerTypeName = 'relation'
			BEGIN
				SET @Query += '		
					FROM [dbo].[Relacja_Cecha_Hist] ch';
			END
			ELSE
			BEGIN

			END
			
			SET @Query += '
					JOIN dbo.[Cechy] c ON (c.Cecha_ID = ch.CechaID)
					WHERE ch.CechaId = ' + CAST(@AttributeTypeId AS varchar)
			
			IF @LowerTypeName = 'relation'
				SET @Query += ' AND ch.RelacjaId = ' + CAST(@Id AS varchar) + @StandardWhere;
			ELSE
				SET @Query += ' AND ch.ObiektId = ' + CAST(@Id AS varchar) + @StandardWhere;
				
			----filtracja po cechach ktore moze widziec uzytkownik
			--IF @CechyWidoczneDlaUzytkownika IS NOT NULL
			--	SET @Query += @CechyWidoczneDlaUzytkownika;
			
			--PRINT @Query;*/
		--	EXECUTE sp_executesql @Query;
			
			
			--wybranie cechy najbardziej aktualnej w podanym czasie
	/*		INSERT INTO #GetValue_CechyFinal (Id)
			SELECT b.Id From #GetValue_CechyTmp b WHERE b.IdArch IS NULL AND NOT EXISTS (SELECT b2.Id From #GetValue_CechyTmp b2 WHERE b2.Id = b.IdArchLink);			
		
			--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
			IF Cursor_Status('local','curBr') > 0 
			BEGIN
				 CLOSE curBr
				 DEALLOCATE curBr
			END
	
			DECLARE curBr CURSOR LOCAL FOR 
			SELECT DISTINCT IdArch FROM #GetValue_CechyTmp WHERE IdArch IS NOT NULL AND IdArch NOT IN (SELECT Id FROM #GetValue_CechyFinal)
			OPEN curBr
			FETCH NEXT FROM curBr INTO @IdArch
			WHILE @@FETCH_STATUS = 0
			BEGIN						
				INSERT INTO #GetValue_CechyFinal(Id)
				SELECT TOP 1 Id FROM #GetValue_CechyTmp
				WHERE Id = @IdArch OR IdArch = @IdArch
				ORDER BY (DATEPART(yy, RealCreatedOn) + DATEPART(mm, RealCreatedOn) + DATEPART(dd, RealCreatedOn)) DESC, ValidFrom DESC
				
				SELECT  Id, ValidFrom, (DATEPART(yy, RealCreatedOn) + DATEPART(mm, RealCreatedOn) + DATEPART(dd, RealCreatedOn)) FROM #GetValue_CechyTmp
				WHERE Id = @IdArch OR IdArch = @IdArch
				ORDER BY DATEPART(yy, RealCreatedOn) DESC, DATEPART(mm, RealCreatedOn) DESC, DATEPART(dd, RealCreatedOn) DESC, ValidFrom DESC
				
				FETCH NEXT FROM curBr INTO @IdArch
			END
			CLOSE curBr
			DEALLOCATE curBr;
			
SELECT * FROM #GetValue_CechyTmp */
--SELECT * FROM #GetValue_CechyFinal
			
			SET @Query = '
				SELECT @XmlValue = ColumnsSet'
				
			IF @LowerTypeName = 'relation'
			BEGIN
				SET @Query += '
				FROM Relacja_Cecha_Hist'
			END
			ELSE
			BEGIN
				SET @Query += '
				FROM [dbo].[_' + @NazwaTypuObiektu + '_Cechy_Hist]';
			END
			
			SET @Query += '
				WHERE Id = (SELECT TOP 1 Id FROM #GetValue_CechyFinal)'
				
			--PRINT @Query;
			EXECUTE sp_executesql @Query, N'@XmlValue xml OUTPUT', @XmlValue = @XmlValue OUTPUT
			
			SELECT @Value = C.value('text()[1]', 'nvarchar(200)')
			FROM @XmlValue.nodes('/*') AS t(c)
			
			--jesli nie znaleziono cechy to przypisanie wartosci domyslnej
			IF @Value IS NULL
				SET @Value = @DefaultValue
		
		END


	--END TRY
	--BEGIN CATCH
	--	SET @ERRMSG = @@ERROR;
	--	SET @ERRMSG += ' ';
	--	SET @ERRMSG += ERROR_MESSAGE();
	--END CATCH
	
	--usuniecie tabel tymczasowych
	IF OBJECT_ID('tempdb..#GetValue_CechyFinal') IS NOT NULL
		DROP TABLE #GetValue_CechyFinal

END
