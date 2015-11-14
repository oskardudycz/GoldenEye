-- =============================================
-- Author:		DK
-- Create date: 2012-10-24
-- Last modified on: 2012-12-11
-- Description:	Przygotowuje dane do obliczen. Wyciaga je z XMLa i wstawia do tabeli roboczej.
-- =============================================
CREATE PROCEDURE [THB].[PrepareOperationsData]
(
	@XMLDataIn xml,
	@Level int,
	@Argument int = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @inputXml nvarchar(MAX) = '',
		@xmlLevel xml,
		@MaxLevel int = 0,
		@Xml1Arg xml,
		@Xml2Arg xml,
		@IsCompositeOperation bit = 1,
		@ElementName nvarchar(100),
		@OperationName varchar(3),
		@NewLevel int = @Level + 1,
		@IsComposite bit = 0,
		@Lp int = NULL,
		@ERRMSG nvarchar(MAX),
		@Argument1 int,
		@Argument2 int,
		@CompositeIdentyfikator int,
		@IdentyfikatorSimple int,
		@Identyfikator int
		
	--usuwanie tabel tymczasowych, jesli nie istnieja, to jej utworzenie
	IF OBJECT_ID('tempdb..#DaneDoObliczen') IS NULL
	BEGIN		
		CREATE TABLE #DaneDoObliczen (Id int PRIMARY KEY IDENTITY(1,1), Lp int, Arg int, Level int, Identyfikator int, XmlValue xml, IsComposite bit, Operation varchar(3));
		SELECT 'Utworzyl tabele w prepareOperationsData';
	END
		
	BEGIN TRY
	
		BEGIN TRANSACTION T1_PrepareOperations
				
		--pobranie bazowej operacji na najwyzszym poziomie i numeru poziomu (domyslnie 1)
		SELECT @ElementName = c.value('local-name(.)', 'nvarchar(100)'),
			@OperationName = c.value('./@Operation', 'varchar(3)'),
			@Lp = c.value('./@Lp', 'int')
		FROM @XMLDataIn.nodes('/*') AS t(c)
		
		IF @ElementName = 'CompositeOperation'
		BEGIN
			SET @IsComposite = 1;			
		END
		ELSE
			SET @IsComposite = 0;
		
		IF @Level = 0
		BEGIN			
			INSERT INTO #DaneDoObliczen (Lp, Level, Identyfikator, XmlValue, IsComposite, Operation)
			VALUES (@Lp, @Level, @Identyfikator,  @XMLDataIn, @IsComposite, @OperationName);
			
			SET @Argument1 = 1;
			SET @Argument2 = 2;

		END
		ELSE 
		BEGIN
			SET @Argument1 = @Argument;
			SET @Argument2 = @Argument;
		END
		
		IF @IsComposite = 1
		BEGIN
			
			INSERT INTO #IdentyfikatoryComposite(Arg) VALUES (@Argument);			
			SELECT @Identyfikator = COUNT(1) FROM #IdentyfikatoryComposite WHERE Arg = @Argument;
			
		END
		
		SET @Level = @Level + 1;
		SET @Identyfikator = @Identyfikator + 1;

--SELECT @Identyfikator, @TmpIdentyfikator	

		--pobranie dwoch argumentow korzenia - od tego zaczynana jest rekurencja
		SELECT @Xml1Arg = x.query('.')
		FROM @XMLDataIn.nodes('/*/*[1]') e(x);
		
		SELECT @Xml2Arg = x.query('.')
		FROM @XMLDataIn.nodes('/*/*[2]') e(x);

		--przetwarzanie danych 1 argumentu
		IF @Xml1Arg IS NOT NULL
		BEGIN
			SELECT @ElementName = c.value('local-name(.)', 'nvarchar(100)'),
					@Lp = c.value('./@Lp', 'int')
				--@OperationName = c.value('./@Operation', 'varchar(3)'),
				--@Level = c.value('./@Level', 'int')
			FROM @Xml1Arg.nodes('/*') AS t(c)	
			
			IF @ElementName = 'CompositeOperation'
				SET @IsComposite = 1;
			ELSE
				SET @IsComposite = 0;
			
			IF @IsComposite = 1
			BEGIN
				INSERT INTO #IdentyfikatorySimple(Arg) VALUES (@Argument1);			
				SELECT @IdentyfikatorSimple = 1 + COUNT(1) FROM #IdentyfikatorySimple WHERE Arg = @Argument1;
			
				SET @CompositeIdentyfikator = @Identyfikator + 1;
				
				SET @Xml1Arg.modify('insert attribute ResultIn {sql:variable("@IdentyfikatorSimple")} into (//*)[1]');
				SET @Xml1Arg.modify('insert attribute Identyfikator {sql:variable("@Identyfikator")} into (//*)[1]');
			END
			ELSE
			BEGIN
				SET @Xml1Arg.modify('insert attribute ResultTo {sql:variable("@Identyfikator")} into (//*)[1]');
			END	
		

			INSERT INTO #DaneDoObliczen (Lp, Arg, Level, Identyfikator, XmlValue, IsComposite, Operation)
			VALUES (@Lp, @Argument1, @Level, @Identyfikator, @Xml1Arg, @IsComposite, @OperationName);
			
			--wywolanie rekurencyjne dla 1 arg jesli zawiera w sobie zlozone operacje
			IF @ElementName = 'CompositeOperation'
			BEGIN
				EXEC [THB].[PrepareOperationsData]
					@XMLDataIn = @Xml1Arg,
					@Level = @NewLevel,
					@Argument = @Argument1
			END
		END
		
		--przetwarzanie danych 2 argumentu
		IF @Xml2Arg IS NOT NULL
		BEGIN
			SELECT @ElementName = c.value('local-name(.)', 'nvarchar(100)'),
					@Lp = c.value('./@Lp', 'int')
				--@OperationName = c.value('./@Operation', 'varchar(3)'),
				--@Level = c.value('./@Level', 'int')
			FROM @Xml2Arg.nodes('/*') AS t(c)
			
			IF @ElementName = 'CompositeOperation'
				SET @IsComposite = 1;
			ELSE
				SET @IsComposite = 0;
			
			IF @IsComposite = 1
			BEGIN
				INSERT INTO #IdentyfikatorySimple(Arg) VALUES (@Argument1);			
				SELECT @IdentyfikatorSimple = 1 + COUNT(1) FROM #IdentyfikatorySimple WHERE Arg = @Argument1;

				SET @CompositeIdentyfikator = @Identyfikator + 1;
				
				----dodanie atrybutu do xmla
				SET @Xml2Arg.modify('insert attribute ResultIn {sql:variable("@IdentyfikatorSimple")} into (//*)[1]');
				SET @Xml2Arg.modify('insert attribute Identyfikator {sql:variable("@Identyfikator")} into (//*)[1]');

			END
			ELSE
			BEGIN
				SET @Xml2Arg.modify('insert attribute ResultTo {sql:variable("@Identyfikator")} into (//*)[1]');
			END	
						
			INSERT INTO #DaneDoObliczen (Lp, Arg, Level, Identyfikator, XmlValue, IsComposite, Operation)
			VALUES (@Lp, @Argument2, @Level, @Identyfikator, @Xml2Arg, @IsComposite, @OperationName);
			
			--wywolanie rekurencyjne dla 1 arg jesli zawiera w sobie zlozone operacje
			IF @ElementName = 'CompositeOperation'
			BEGIN
				EXEC [THB].[PrepareOperationsData]
					@XMLDataIn = @Xml2Arg,
					@Level = @NewLevel,
					@Argument = @Argument2
			END
		END
		
		COMMIT TRANSACTION T1_PrepareOperations;

	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		SELECT @ERRMSG;
		
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION T1_PrepareOperations;
		END
		
	END CATCH

END
