-- =============================================
-- Author:		DK
-- Create date: 2012-10-25
-- Last modified on: 2012-12-11
-- Description:	Wylicza wynik działania oraz ew przypisuje do wskazanej cechy.
-- =============================================
CREATE PROCEDURE [THB].[CalculateCompositeArithmeticMainArgument]
(
	@Argument int,
	@UserId int,
	@AppDate datetime,
	@StatusS int,
	@StatusP int,
	@StatusW int,
	@BranchId int,
	@ResultValue varchar(100) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ERRMSG nvarchar(MAX),
		@CurrentLevel int = 0,
		@Arg1Xml xml,
		@Arg2Xml xml,
		@Operation varchar(3),
		@RequestXmlForSimpleOperation nvarchar(MAX),
		@ResponseFromSimpleOperation nvarchar(MAX),
		@FunctionName varchar(50),
		@ElementName nvarchar(100),
		@XmlTmp xml,
		@Lp int,
		@WartoscWyliczen varchar(100),
		@FillResponse bit = 1,
		@CurrentIdentyfikator int,
		@MaxIdentyfikator int,
		@ResultIn int,
		@ResultTo int
		
		--utworenie tabeli jesli nie istnieje			
		IF OBJECT_ID('tempdb..#WartosciPosrednie') IS NULL
			CREATE TABLE #WartosciPosrednie (Id int PRIMARY KEY IDENTITY(1,1), Arg int, Level int, Result int, Value varchar(50));
			
		--BEGIN TRY

		IF @Argument > 2
			SET @Argument = 2;
					
		----rozpoczecie przetwarzania danych		
		SELECT @MaxIdentyfikator = MAX(Identyfikator)
		FROM #DaneDoObliczen
		WHERE Arg = @Argument;

		SET @CurrentIdentyfikator = @MaxIdentyfikator;
		
		WHILE @CurrentIdentyfikator > 0
		BEGIN

			--wyzerowanie zmiennych
			SET @Arg1Xml = NULL;
			SET @Arg2Xml = NULL;
			
			--pobranie danych lewego i prawego argumentu dzialania arytmetycznego
			SELECT @Arg1Xml = XmlValue,
				@Operation = Operation
			FROM #DaneDoObliczen
			WHERE Arg = @Argument AND Lp = 1 AND Identyfikator = @CurrentIdentyfikator --Level = @CurrentLevel 

			SELECT @Arg2Xml = XmlValue
				--,@Operation = Operation
			FROM #DaneDoObliczen
			WHERE Arg = @Argument AND Lp = 2 AND Identyfikator = @CurrentIdentyfikator --Level = @CurrentLevel 	
			
			--jesli znaleziono tylko 1 XML to przepisanie jego wartosci do drugiego XMLa
			--IF (@Arg1Xml IS NULL AND @Arg2Xml IS NOT NULL) 
			--	SET @Arg1Xml = @Arg2Xml;			
			
--SELECT @Arg1Xml AS Arg1Main, @Arg2Xml AS Arg2Main		
--SELECT @ElementName AS ElementName, @WartoscWyliczen AS Wartosc
				
			-- jesli oba xmle nie sa puste i sa rozne od siebie
			-- rowne sa wtedy gdy zostal na danym poziomie 1 argument xmlowy, wtedy zostal pobrany 2 razy to samo
			IF @Arg1Xml IS NOT NULL AND @Arg2Xml IS NOT NULL AND THB.[CompareXml] (@Arg1Xml, @Arg2Xml) = 1
			BEGIN

				-- przetwarzanie argumentu 1
				SET @ElementName = NULL;
				
				--pobranie nazwy elementów glownych pobranych XMLi, jesli natrafilismy na CompositeOperation, pobieramy wartosc z tabeli roboczej poziomu wyzej
				SELECT @ElementName = c.value('local-name(.)', 'varchar(100)'),
						@FunctionName = c.value('./@Name', 'varchar(50)'),
						@ResultIn = c.value('./@ResultIn', 'int'),
						@ResultTo = c.value('./@ResultTo', 'int')
				FROM @Arg1Xml.nodes('/*') AS t(c)
		
				IF @ElementName = 'CompositeOperation'
				BEGIN
					SELECT TOP 1 @WartoscWyliczen = Value
					FROM #WartosciPosrednie
					WHERE Arg = @Argument AND Result = @ResultIn
					ORDER By Id DESC
					
					SET @Arg1Xml = CAST('<SimpleValue Lp="1"><Scalar Value="' + @WartoscWyliczen + '"/></SimpleValue>' AS xml);
				END
				ELSE IF @ElementName = 'Function'
				BEGIN
					
					EXEC [THB].[CalculateFunction]
						@XmlArg = @Arg1Xml,
						@UserId = @UserId,
						@AppDate = @AppDate,
						@StatusS = @StatusS,
						@StatusP = @StatusP,
						@StatusW = @StatusW,
						@BranchId = @BranchId,
						@ResultValue = @WartoscWyliczen OUTPUT
					
					--jesli wynik rozny od NULL to wstawienie do tabeli roboczej
					IF @WartoscWyliczen IS NOT NULL
					BEGIN
						INSERT INTO #WartosciPosrednie (Arg, Level, Result, Value)
						VALUES(@Argument, @CurrentLevel, ISNULL(@ResultTo, @CurrentIdentyfikator), @WartoscWyliczen); 
					END
						
					SET @Arg1Xml = CAST('<SimpleValue Lp="1"><Scalar Value="' + @WartoscWyliczen + '"/></SimpleValue>' AS xml);
					
				END
		
				SET @ElementName = NULL;
				
				-- przetwarzanie argumentu 2		
				SELECT @ElementName = c.value('local-name(.)', 'varchar(100)'),
						@FunctionName = c.value('./@Name', 'varchar(50)'),
						@ResultIn = c.value('./@ResultIn', 'int'),
						@ResultTo = c.value('./@ResultTo', 'int')
				FROM @Arg2Xml.nodes('/*') AS t(c)
			
				IF @ElementName = 'CompositeOperation'
				BEGIN
					SELECT TOP 1 @WartoscWyliczen = Value
					FROM #WartosciPosrednie
					WHERE Arg = @Argument AND Result = @ResultIn
					ORDER By Id DESC
					
					SET @Arg2Xml = CAST('<SimpleValue Lp="2"><Scalar Value="' + @WartoscWyliczen + '"/></SimpleValue>' AS xml);
				END
				ELSE IF @ElementName = 'Function'
				BEGIN
					
					EXEC [THB].[CalculateFunction]
						@XmlArg = @Arg2Xml,
						@UserId = @UserId,
						@AppDate = @AppDate,
						@StatusS = @StatusS,
						@StatusP = @StatusP,
						@StatusW = @StatusW,
						@BranchId = @BranchId,
						@ResultValue = @WartoscWyliczen OUTPUT
					
					--jesli wynik rozny od NULL to wstawienie do tabeli roboczej
					IF @WartoscWyliczen IS NOT NULL
					BEGIN
						INSERT INTO #WartosciPosrednie (Arg, Level, Result, Value)
						VALUES(@Argument, @CurrentLevel, ISNULL(@ResultTo, @CurrentIdentyfikator), @WartoscWyliczen); 
					END
						
					SET @Arg2Xml = CAST('<SimpleValue Lp="2"><Scalar Value="' + @WartoscWyliczen + '"/></SimpleValue>' AS xml);
						
				END
				
--SELECT @Operation AS Operation, @Arg1Xml AS Arg1PoWerA, @Arg2Xml AS Arg2PoWerA		
				
				--przygotowanie XMLa wejsciowego dla procedury obliczajacej
				EXEC [THB].[PrepareXmlForSimpleOperation]
					@Arg1 = @Arg1Xml,
					@Arg2 = @Arg2Xml,
					@Operation = @Operation,
					@UserId = @UserId,
					@AppDate = @AppDate,
					@StatusS = @StatusS,
					@StatusP = @StatusP,
					@StatusW = @StatusW,
					@ResultXml = @RequestXmlForSimpleOperation OUTPUT

--SELECT @RequestXmlForSimpleOperation
				
				-- wywolanie procedury liczacej prosta operacje
				EXEC [THB].[SimpleOperation]
					@XMLDataIn = @RequestXmlForSimpleOperation,
					@XMLDataOut = @ResponseFromSimpleOperation OUTPUT

				SET @XmlTmp = CAST(@ResponseFromSimpleOperation AS xml);					
				SELECT @WartoscWyliczen = @XmlTmp.value('data((/Response/Result/Value)[1])', 'varchar(MAX)');
				
--SELECT @WartoscWyliczen AS Wynik;
				
				--wstawienie wyniku obliczen do tabeli roboczej
				IF @WartoscWyliczen IS NOT NULL
				BEGIN
					INSERT INTO #WartosciPosrednie (Arg, Level, Result, Value)
					VALUES(@Argument, @CurrentLevel, ISNULL(@ResultTo, @CurrentIdentyfikator), @WartoscWyliczen); 
				END
	
			END
			ELSE
			BEGIN
			
				-- zostal tylko 1 element na danym poziomie
				IF @Arg1Xml IS NULL
					SET @Arg1Xml = @Arg2Xml;
					
				-- pobranie nazwy elementu i wartosci atrybutu value
				SELECT @ElementName = c.value('local-name(../.)', 'varchar(100)'),
						@WartoscWyliczen = c.value('./@Value', 'nvarchar(100)'),
						@ResultIn = c.value('./@ResultIn', 'int'),
						@ResultTo = c.value('./@ResultTo', 'int')											
				FROM @Arg1Xml.nodes('/*/*') AS t(c)
			
				--jesli nie znaleziono nzwy elementu z podelementem, pobranie nazwy tylko dla aktualnego rekordu
				IF @ElementName IS NULL
				BEGIN
					SELECT @ElementName = c.value('local-name(./.)', 'varchar(100)')
					FROM @Arg1Xml.nodes('/*') AS t(c)
				END
				
				IF @ElementName = 'SimpleValue'
				BEGIN

					--INSERT INTO #WartosciPosrednie (Arg, Level, Value)
					--VALUES(@Argument, @CurrentLevel, @WartoscWyliczen);
					SET @FillResponse = 0;
					SET @ResultValue = CAST(@Arg1Xml AS nvarchar(MAX));
				
				END
				ELSE IF @ElementName = 'Function'
				BEGIN
		
					EXEC [THB].[CalculateFunction]
						@XmlArg = @Arg1Xml,
						@UserId = @UserId,
						@AppDate = @AppDate,
						@StatusS = @StatusS,
						@StatusP = @StatusP,
						@StatusW = @StatusW,
						@BranchId = @BranchId,
						@ResultValue = @WartoscWyliczen OUTPUT
						
					INSERT INTO #WartosciPosrednie (Arg, Level, Result, Value)
					VALUES(@Argument, @CurrentLevel, ISNULL(@ResultTo, @CurrentIdentyfikator), @WartoscWyliczen); 
				END
				
				BREAK;
			END
					
			--SET @CurrentLevel = @CurrentLevel - 1;
			SET @CurrentIdentyfikator = @CurrentIdentyfikator - 1;
		END
		
--SELECT * FROM #WartosciPosrednie

		IF @FillResponse = 1
		BEGIN
			SELECT TOP 1 @WartoscWyliczen = Value
			FROM #WartosciPosrednie
			WHERE Arg = @Argument
			ORDER BY Id DESC			
							
			SET @ResultValue = '<SimpleValue Lp="' + CAST(@Argument AS varchar) + '"><Scalar Value="' + @WartoscWyliczen + '"/></SimpleValue>';
		END

--SELECT @ResultValue
--		END TRY
--		BEGIN CATCH
--			SET @ERRMSG = @@ERROR;
--			SET @ERRMSG += ' ';
--			SET @ERRMSG += ERROR_MESSAGE();
--		END CATCH

END
