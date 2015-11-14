-- =============================================
-- Author:		DK
-- Create date: 2012-10-24
-- Last modified on: 2012-12-11
-- Description:	Wylicza wynik działania oraz ew przypisuje do wskazanej cechy.

-- XML wejsciowy w postaci:

	--<Request UserId="1" AppDate="2012-01-01T11:34:33" RequestType="CompositeArithmeticOperation">
	--<OperationData>
	--	<CompositeOperation Operation="Sum" Level="1">
	--		<SimpleValue Lp="1">
	--			<Scalar Value="2"/>
	--		</SimpleValue>
	--		<SimpleValue Lp="2">
	--			<Scalar Value="5"/>
	--		</SimpleValue>
	--	</CompositeOperation>
	--</OperationData>
	--</Request>

-- XM wyjsciowy w postaci:

--<?xml version="1.0" encoding="utf-8"?>
--<Response ResponseType="CompositArithmeticOperation" AppDate="2012-01-01">
--	<Result>
--		<Value>6</Value>
--	</Result>
--</Response>

-- =============================================
CREATE PROCEDURE [THB].[CompositeArithmeticOperation]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @StatusS int,
		@StatusW int,
		@StatusP int,
		@AppDate datetime,
		@DataProgramu datetime,
		@MaUprawnienia bit,
		@BranchId int,
		@RequestType nvarchar(50),
		@UserId int,
		@ERRMSG nvarchar(MAX),
		@xml_data xml,
		@xmlOk bit,
		@StartXml xml,
		@ResultValueArg1 varchar(100),
		@ResultValueArg2 varchar(100),
		@Operation varchar(3),
		@RequestXmlForSimpleOperation nvarchar(MAX),
		@ResponseFromSimpleOperation nvarchar(MAX),
		@XmlTmp xml,
		@WartoscWyliczen varchar(100),
		@TargetAttributeId int,
		@TargedObjectId int,
		@TargetObjectTypeId int,
		@TargetRelationId int
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_CompositeArithmeticOperation', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
	
		IF @xmlOk = 0
		BEGIN
			-- co zrobic jak nie poprawna walidacja XML
			SET @ERRMSG = @ERRMSG;
		END
		ELSE
		BEGIN
		
			--usuwanie tabel tymczasowych, jesli istnieja
			IF OBJECT_ID('tempdb..#DaneDoObliczen') IS NOT NULL
				DROP TABLE #DaneDoObliczen
				
			IF OBJECT_ID('tempdb..#WartosciPosrednie') IS NOT NULL
				DROP TABLE #WartosciPosrednie
				
			IF OBJECT_ID('tempdb..#IdentyfikatoryComposite') IS NOT NULL
				DROP TABLE #IdentyfikatoryComposite
				
			IF OBJECT_ID('tempdb..#IdentyfikatorySimple') IS NOT NULL
				DROP TABLE #IdentyfikatorySimple
				
			CREATE TABLE #DaneDoObliczen (Id int PRIMARY KEY IDENTITY(1,1), Lp int, Arg int, Level int, Identyfikator int, XmlValue xml, IsComposite bit, Operation varchar(3));
			CREATE TABLE #WartosciPosrednie (Id int PRIMARY KEY IDENTITY(1,1), Arg int, Level int, Result int, Value varchar(50));
			CREATE TABLE #IdentyfikatoryComposite (Id int PRIMARY KEY IDENTITY(1,1), Arg int);
			CREATE TABLE #IdentyfikatorySimple (Id int PRIMARY KEY IDENTITY(1,1), Arg int);
			
			BEGIN TRY
		
			--poprawny XML wejsciowy
			SET @xml_data = CAST(@XMLDataIn AS xml);
		
			--wyciaganie danych z XMLa
			SELECT @DataProgramu = C.value('./@AppDate', 'datetime')
					,@UserId = C.value('./@UserId', 'int')
					,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
					,@BranchId = C.value('./@BranchId', 'int')
					,@StatusS = C.value('./@StatusS', 'int')
					,@StatusP = C.value('./@StatusP', 'int')
					,@StatusW = C.value('./@StatusW', 'int')
			FROM @xml_data.nodes('/Request') T(C)

			IF @RequestType = 'CompositeArithmeticOperation'
			BEGIN 
			
				-- pobranie daty modyfikacji na podstawie przekazanego AppDate
				SELECT @AppDate = THB.PrepareAppDate(@DataProgramu);
			
				--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji select
				EXEC [THB].[CheckUserPermission]
					@Operation = N'GET',
					@UserId = @UserId,
					@BranchId = @BranchId,
					@Result = @MaUprawnienia OUTPUT
				
				IF @MaUprawnienia = 1
				BEGIN
				
					--odczytanie danych obiektu/relacji do ktorego ma byc przypisany wynik obliczen
					SELECT @TargetRelationId = C.value('./@Id', 'int')
						,@TargetAttributeId = C.value('./@AttributeTypeId', 'int')
					FROM @xml_data.nodes('/Request/OperationData/Relation') T(C)
					
					IF @TargetRelationId IS NULL
					BEGIN
						SELECT @TargedObjectId = C.value('./@Id', 'int')
							,@TargetObjectTypeId = C.value('./@TypeId', 'int')
							,@TargetAttributeId = C.value('./@AttributeTypeId', 'int')
						FROM @xml_data.nodes('/Request/OperationData/Unit') T(C)
					END										
					
					--utworzenie XMLa poczatkowego po odcieciu elementu korzenia - Request
					SELECT @StartXml = x.query('.')
					FROM @xml_data.nodes('/Request/OperationData/CompositeOperation') e(x);
				--	FROM @xml_data.nodes('/Request/*[2]') e(x);				
	
					--wstawienie danych do tabeli roboczej odnosnie kolejnych operacji i ich argumentow
					EXEC [THB].[PrepareOperationsData]
							@XMLDataIn = @StartXml,
							@Level = 0,
							@Argument = NULL
	
--SELECT * FROM #DaneDoObliczen ORDER BY Arg, Identyfikator

					--pobranie glownej operacji do wykonania
					SELECT @Operation = Operation
					FROM #DaneDoObliczen WHERE Level = 0;

					-- wykonanie obliczen dla elementu 1 argumentu i jego podelementow
					EXEC [THB].[CalculateCompositeArithmeticMainArgument]
						@Argument = 1,
						@UserId = @UserId,
						@AppDate = @AppDate,
						@StatusS = @StatusS,
						@StatusP = @StatusP,
						@StatusW = @StatusW,
						@BranchId = @BranchId,
						@ResultValue = @ResultValueArg1 OUTPUT

--usuniecie danych z tabeli by identyfikatory dla 2 galezi tez zaczynaly sie od 1
--SELECT * FROM #IdentyfikatoryComposite
--DELETE FROM #IdentyfikatoryComposite;
--SELECT * FROM #IdentyfikatoryComposite;
					
					-- wykonanie obliczen dla elementu 2 argumentu i jego podelementow
					EXEC [THB].[CalculateCompositeArithmeticMainArgument]
						@Argument = 2,
						@UserId = @UserId,
						@AppDate = @AppDate,
						@StatusS = @StatusS,
						@StatusP = @StatusP,
						@StatusW = @StatusW,
						@BranchId = @BranchId,
						@ResultValue = @ResultValueArg2 OUTPUT
		
					--przygotowanie XMLa dla ostatniego dzialania
					EXEC [THB].[PrepareXmlForSimpleOperation]
						@Arg1 = @ResultValueArg1,
						@Arg2 = @ResultValueArg2,
						@Operation = @Operation,
						@UserId = @UserId,
						@AppDate = @AppDate,
						@StatusS = @StatusS,
						@StatusP = @StatusP,
						@StatusW = @StatusW,
						@ResultXml = @RequestXmlForSimpleOperation OUTPUT

--SELECT @ResultValueArg1 AS Arg1, @ResultValueArg2 AS Arg2
--SELECT @RequestXmlForSimpleOperation AS RequestForFinal

					-- wywolanie procedury liczacej prosta operacje
					EXEC [THB].[SimpleOperation]
						@XMLDataIn = @RequestXmlForSimpleOperation,
						@XMLDataOut = @ResponseFromSimpleOperation OUTPUT
				
--SELECT @ResponseFromSimpleOperation AS Response

					SET @XmlTmp = CAST(@ResponseFromSimpleOperation AS xml);					
					SELECT @WartoscWyliczen = @XmlTmp.value('data((/Response/Result/Value)[1])', 'varchar(MAX)');
					
					--przypisanie wartosci do cechy relacji/obiektu						
					EXEC [THB].[WriteResultToAttribute]
						@AppDate = @AppDate,
						@UserId = @UserId,
						@ResultValue = @WartoscWyliczen,
						@AttributeId = @TargetAttributeId,
						@ObjectId = @TargedObjectId,
						@ObjectTypeId = @TargetObjectTypeId,
						@RelationId = @TargetRelationId					
		
				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UserId, @Val2 = N'CompositeArithmeticOperation', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'CompositeArithmeticOperation', @Wiadomosc = @ERRMSG OUTPUT		
		
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH
		END

	--przygotowanie XMLa zwrotnego
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="CompositeArithmeticOperation"'
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
	
	SET @XMLDataOut += '>';
	
	IF @ERRMSG IS NULL OR @ERRMSG = ''
	BEGIN
		SET @XMLDataOut += '<Result><Value>' + @WartoscWyliczen + '</Value></Result>';
	END
	ELSE		
		SET @XMLDataOut += '<Result><Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/></Result>';

	SET @XMLDataOut += '</Response>'
	
	--usuwanie tabel tymczasowych, jesli istnieja
	IF OBJECT_ID('tempdb..#DaneDoObliczen') IS NOT NULL
		DROP TABLE #DaneDoObliczen
		
	IF OBJECT_ID('tempdb..#WartosciPosrednie') IS NOT NULL
		DROP TABLE #WartosciPosrednie

END
