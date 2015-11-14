-- =============================================
-- Author:		DK
-- Create date: 2012-12-24
-- Last modified on: 2013-02-25
-- Description:	Pobiera wartosc cechy podanej jako ValRef i zwraca XMLa z jej danymi
-- =============================================
CREATE PROCEDURE [THB].[GetRefAttributeValue]
(
	@ValRef varchar(200),
	@StatusS int,
	@StatusW int,
	@StatusP int,
	@AppDate datetime,
	@UserId int,
	@BranchId int,
	@GetFullData bit,
	@Value nvarchar(2000) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @StandardWhere nvarchar(MAX),
			@DataProgramu datetime,
			@Query nvarchar(MAX) = '',
			@CechyWidoczneDlaUzytkownika nvarchar(MAX),
			@LowerTypeName varchar(30),
			@NazwaTypuObiektu nvarchar(300),
			@XmlValue xml,
			@TableName nvarchar(MAX),
			@DateFromColumnName nvarchar(100),			
			@ValRefAsXml xml,
			@Id int,
			@TypeId int,
			@AttributeTypeId int,
			@Type varchar(30),
			@CechaObiektuId int,
			@CechaHasAlternativeHistory bit,
			@CechaStatusS int,
			@WartoscString nvarchar(MAX),
			@CechaCzyDanaOsobowa bit,
			@CechaIsStatus bit,
			@CzySlownik bit,
			@CechaTyp varchar(50),
			@CechaWartosc nvarchar(MAX),
			@CechaWartoscXML nvarchar(MAX),
			@NazwaSlownika nvarchar(500),
			@CechaTypId int,
			@DataLinka datetime			
	
	BEGIN TRY
	
		--usuniecie tabel tymczasowych
		IF OBJECT_ID('tempdb..#GetRefValue_CechyFinal') IS NOT NULL
			DROP TABLE #GetRefValue_CechyFinal

		CREATE TABLE #GetRefValue_CechyFinal(Id int);
		
		--zamiana znakow specjalnych na odpowiedniki XMLowe
		SET @ValRef = [THB].PrepareXMLValue(@ValRef);		
		SET @ValRefAsXML = CAST(@ValRef AS xml);

		-- pobranie daty na podstawie przekazanego AppDate
		SELECT @DataProgramu = THB.PrepareAppDate(@AppDate);	

		--pobranie nazwy kolumny po ktorej filtrowane sa daty
		SET @DateFromColumnName = [THB].[GetDateFromFilterColumn]();			
		
		--dodanie frazy statusow na filtracje jesli trzeba
		SET @StandardWhere = [THB].[PrepareStatusesPhrase] ('ch3', @StatusS, @StatusP, @StatusW);
		
		--dodanie frazy na daty
		SET @StandardWhere += [THB].[PrepareDatesPhrase] ('ch3', @AppDate);

		SELECT @Type = C.value('local-name(.)', 'varchar(MAX)')
				,@Id = C.value('./@Id', 'int')
				,@TypeId = C.value('./@TypeId', 'int')
				,@AttributeTypeId = C.value('./@AttributeTypeId', 'int')
				,@DataLinka = C.value('./@Date', 'datetime')
		FROM @ValRefAsXML.nodes('/*') T(C) 	

--SELECT @Type, @Id, @TypeId, @AttributeTypeId
	
		-- pobranie Id cech do ktorych uzytkownik ma dostep
		EXEC [THB].[GetUserAttributeTypes]
			@Alias = 'ch3',
			@DataProgramu = @DataProgramu,
			@UserId = @UserId,
			@BranchId = @BranchId,
			@AtributeTypesWhere = @CechyWidoczneDlaUzytkownika OUTPUT
	
		SET @LowerTypeName = LOWER(@Type);

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
			INSERT INTO #GetRefValue_CechyFinal (Id)
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
		
		--dodanie warunku na dokladna wartosc obowiazywania cechy
		IF @DataLinka IS NOT NULL
			--SET @Query += ' AND ch3.' + @DateFromColumnName + ' = ''' + CONVERT(nvarchar(50), @DataLinka, 109) + '''';
			SET @Query += [THB].[PrepareDatesPhrase] ('ch3', @DataLinka);								
								
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
		
--SELECT * FROM #GetRefValue_CechyFinal
		
		-- pobranie danych cechy
		SELECT TOP 1 @CechaStatusS = StatusS, @CechaCzyDanaOsobowa = CzyJestDanaOsobowa, @CechaIsStatus = IsStatus, 
			@CzySlownik = CzySlownik, @CechaTypId = TypID
		FROM dbo.Cechy
		WHERE Cecha_ID = @AttributeTypeId
		ORDER BY ObowiazujeOd DESC
		
		SET @Query = '
			SELECT @XmlValue = THB.GetAttributeValueFromSparseXML(ColumnsSet), @CechaObiektuId = Id, @WartoscString = ValString, 
				@CechaHasAlternativeHistory = IsAlternativeHistory
		'
		
		SET @Query += '
			FROM ' + @TableName + '
			WHERE Id = (SELECT TOP 1 Id FROM #GetRefValue_CechyFinal)'
			
		--PRINT @Query;
		EXECUTE sp_executesql @Query, N'@XmlValue xml OUTPUT, @CechaObiektuId int OUTPUT, @WartoscString nvarchar(MAX) OUTPUT, @CechaHasAlternativeHistory bit OUTPUT', 
		@XmlValue = @XmlValue OUTPUT, @CechaObiektuId = @CechaObiektuId OUTPUT, @WartoscString = @WartoscString OUTPUT, @CechaHasAlternativeHistory = @CechaHasAlternativeHistory OUTPUT

		IF @XmlValue IS NOT NULL
		BEGIN
			SELECT @Value = C.value('text()[1]', 'varchar(20)')
			FROM @XmlValue.nodes('/*') AS t(c)
		END
		ELSE
		BEGIN
			SET @Value = @WartoscString;
		END
	
		--jesli nie znaleziono cechy to przypisanie wartosci domyslnej
		IF @Value IS NULL
		BEGIN
			--RAISERROR (N'Nie znaleziono wartości dla podanej cechy.', 10, 1);

			SET @Value = NULL;
		END
		ELSE
		BEGIN
			--zwrocenie wyniku jako XML z wartosciami Attribute
			SET @Query = 'SELECT @Value = CAST((SELECT c.[Id] AS "@Id"
									,c.[CechaID] AS "@TypeId"
									,c.[Priority] AS "@Priority"
									,c.[UIOrder] AS "@UIOrder"
									,ISNULL(c.[LastModifiedOn], c.[CreatedOn]) AS "@LastModifiedOn"'
		
			--jesli pobieranie wszystkich danych
			IF @GetFullData = 1							
			BEGIN							
				SET @Query += '		,c.[IsDeleted] AS "@IsDeleted"
									,c.[DeletedFrom] AS "@DeletedFrom"
									,c.[DeletedBy] AS "@DeletedBy"
									,c.[CreatedOn] AS "@CreatedOn"
									,c.[CreatedBy] AS "@CreatedBy"
									,c.[LastModifiedBy] AS "@LastModifiedBy"
									,c.[ObowiazujeOd] AS "History/@EffectiveFrom"
									,c.[ObowiazujeDo] AS "History/@EffectiveTo"
									,ISNULL(c.[IsMainHistFlow], 0) AS "History/@IsMainHistFlow"
									,ISNULL(c.[IsAlternativeHistory], 0) AS "History/@IsAlternativeHistory"
									,c.[IsStatus] AS "Statuses/@IsStatus"
									,c.[StatusS] AS "Statuses/@StatusS"
									,c.[StatusSFrom] AS "Statuses/@StatusSFrom"
									,c.[StatusSTo] AS "Statuses/@StatusSTo"
									,c.[StatusSFromBy] AS "Statuses/@StatusSFromBy"
									,c.[StatusSToBy] AS "Statuses/@StatusSToBy"
									,c.[StatusW] AS "Statuses/@StatusW"
									,c.[StatusWFrom] AS "Statuses/@StatusWFrom"
									,c.[StatusWTo] AS "Statuses/@StatusWTo"
									,c.[StatusWFromBy] AS "Statuses/@StatusWFromBy"
									,c.[StatusWToBy] AS "Statuses/@StatusWToBy"
									,c.[StatusP] AS "Statuses/@StatusP"
									,c.[StatusPFrom] AS "Statuses/@StatusPFrom"
									,c.[StatusPTo] AS "Statuses/@StatusPTo"
									,c.[StatusPFromBy] AS "Statuses/@StatusPFromBy"
									,c.[StatusPToBy] AS "Statuses/@StatusPToBy"'
			END
										
			--sprawdzenie czy cecha zawiera dane osobowe i ma status wiekszy niz status usera
			IF @CechaIsStatus = 1 AND @CechaCzyDanaOsobowa = 1 AND @CechaStatusS > @StatusS
			BEGIN
				SET @Query += ', ''' + THB.GetHiddenValue() + ''' AS "ValHidden/@Value"'
			END
			ELSE
			BEGIN									
				-- przygotowanie danych/wartosci cechy
				IF @XmlValue IS NOT NULL
				BEGIN								
					SELECT	@CechaTyp = C.value('local-name(.)', 'varchar(MAX)')
							,@CechaWartosc = C.value('text()[1]', 'nvarchar(MAX)')
							,@CechaWartoscXML = CAST(C.query('/ValXml/*') AS nvarchar(MAX))								
					FROM @XmlValue.nodes('/*') AS t(c)
					
					IF @CechaTyp = 'ValXml'
						SET @CechaWartosc = [THB].[PrepareCodedXML](@CechaWartoscXML);
						
				END
				ELSE
				BEGIN
					IF @WartoscString IS NOT NULL
					BEGIN
						SET @CechaWartosc = @WartoscString;
						SET @CechaTyp = 'ValString';
					END								
				END						
			
				IF @CechaWartosc IS NOT NULL AND @CechaTyp IS NOT NULL
				BEGIN
					
					IF @CzySlownik = 0 AND @CechaTyp <> 'ValDictionary'
					BEGIN
						IF @CechaHasAlternativeHistory = 0 OR @CechaHasAlternativeHistory IS NULL
						BEGIN
							SET @Query += ', ''' + [THB].[PrepareXMLValue](@CechaWartosc) + ''' AS "' + @CechaTyp + '/@Value"'										
						END
						ELSE
						BEGIN
						
							SET @Query += ', ( SELECT ''' + [THB].[PrepareXMLValue](@CechaWartosc) + ''' AS "@Value"
										,( SELECT TOP 1 ISNULL(c2.[ZmianaOd], c2.[CreatedOn]) AS "@ChangeFrom"
											,c2.[ZmianaDo] AS "@ChangeTo"
											,ISNULL(c2.[ObowiazujeOd], c2.[CreatedOn]) AS "@EffectiveFrom"
											,c2.[ObowiazujeDo] AS "@EffectiveTo"
											,ISNULL(c2.[IsMainHistFlow], 0) AS "@IsMainHistFlow"
											FROM #CechyObiektu c2
											WHERE c2.[Id] <> ' + CAST(@CechaObiektuId AS varchar) + ' AND c2.TypObiektuId = ' + CAST(@TypeId AS varchar) 
												+ ' AND c2.ObiektId = ' + CAST(@Id AS varchar) + ' AND c.[CechaId] = c2.[CechaId]
											FOR XML PATH(''History''), TYPE)
										FOR XML PATH(''' + @CechaTyp + '''), TYPE)'
						END										
					END
					ELSE
					BEGIN
						-- pobranie nazwy slownika skojarzonego z cecha
						SET @NazwaSlownika = (SELECT Nazwa FROM [Slowniki] WHERE Id = @CechaTypId);
						
						IF @CechaHasAlternativeHistory = 0 OR @CechaHasAlternativeHistory IS NULL
						BEGIN
							SET @Query += ', ' + CAST(@CechaWartosc AS varchar) + ' AS "ValDictionary/@ElementId"    
									, ' + CAST(@CechaTypId AS varchar) + ' AS "ValDictionary/@Id"'
									
							IF @NazwaSlownika IS NOT NULL
								SET @Query += ', (SELECT Nazwa FROM [_Slownik_' + @NazwaSlownika + '] WHERE ID = ' + CAST(@CechaWartosc AS varchar) + ') AS "ValDictionary/@DisplayValue"'
						END
						ELSE
						BEGIN
							SET @Query += ', ( SELECT' + CAST(@CechaWartosc AS varchar) + ' AS "@ElementId"  
										, ' + CAST(@CechaTypId AS varchar) + ' AS "@Id"'
										
							IF @NazwaSlownika IS NOT NULL
								SET @Query += ', (SELECT Nazwa FROM [_Slownik_' + @NazwaSlownika + '] WHERE ID = ' + CAST(@CechaWartosc AS varchar) + ') AS "@DisplayValue"'
								
							SET @Query += ', (SELECT TOP 1 ISNULL(c2.[ZmianaOd], c2.[CreatedOn]) AS "@ChangeFrom"
											,c2.[ZmianaDo] AS "@ChangeTo"
											,ISNULL(c2.[ObowiazujeOd], c2.[CreatedOn]) AS "@EffectiveFrom"
											,c2.[ObowiazujeDo] AS "@EffectiveTo"
											,ISNULL(c2.[IsMainHistFlow], 0) AS "@IsMainHistFlow"
											FROM #CechyObiektu c2
												WHERE c2.[Id] <> ' + CAST(@CechaObiektuId AS varchar) + ' AND c2.TypObiektuId = ' + CAST(@TypeId AS varchar) 
												+ ' AND c2.ObiektId = ' + CAST(@Id AS varchar) + ' AND c.[CechaId] = c2.[CechaId]
											FOR XML PATH(''History''), TYPE)
										)
										FOR XML PATH(''ValDictionary''), TYPE)'															
						END
					END
				END
			END
		END
		
		SET @Query += '
			FROM ' + @TableName + ' c
			WHERE Id = ' + CAST(@CechaObiektuId AS varchar) + '
			FOR XML PATH(''Attribute''), TYPE) AS nvarchar(MAX))'
		
		--PRINT @Query;
		EXECUTE sp_executesql @Query, N'@Value nvarchar(MAX) OUTPUT', @Value = @Value OUTPUT		
	
		--zwrocenie wyniku jako wartosc liczby zmiennoprzecinkowej
		--SET @Value = CAST(CAST(@Value AS decimal(12,5)) AS varchar(20));


	END TRY
	BEGIN CATCH
		--SET @ERRMSG = @@ERROR;
		--SET @ERRMSG += ' ';
		--SET @ERRMSG += ERROR_MESSAGE();
		
		SELECT 'GetRefAttribuetValueError: ' + ERROR_MESSAGE()
		
		SET @Value = NULL;
	END CATCH
	
	--usuniecie tabel tymczasowych
	IF OBJECT_ID('tempdb..#GetRefValue_CechyFinal') IS NOT NULL
		DROP TABLE #GetRefValue_CechyFinal

END
