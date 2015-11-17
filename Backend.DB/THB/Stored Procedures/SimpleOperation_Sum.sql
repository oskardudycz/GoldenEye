-- =============================================
-- Author:		DK
-- Create date: 2012-10-15
-- Last modified on: --
-- Description:	Wylicza sumę dla 2 podanych argumentów

-- XML wejsciowy w postaci:

	--<Request UserId="1" AppDate="2012-01-01T11:34:33" >
	--	<Scalar Lp="1" Value="2"/>
	--	<Relation Lp="2" Id="5" AttributeId="5"/>
	--</Request>

-- XM wyjsciowy w postaci:

--<?xml version="1.0" encoding="utf-8"?>
--<Response ResponseType="SimpleOperation_Sum" AppDate="2012-01-01">
--	<Result>
--		<Value>23</Value>
--	</Result>
--</Response>

-- =============================================
CREATE PROCEDURE [THB].[SimpleOperation_Sum]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @inputXml nvarchar(MAX) = '',
		@statusS int,
		@StatusW int,
		@StatusP int,
		@AppDate datetime,
		@DataProgramu datetime,
		@MaUprawnienia bit,
		@BranchId int,
		@RequestType nvarchar(50) = 'SimpleOperation_Sum',
		@UserId int,
		@ERRMSG nvarchar(MAX),
		@xml_data xml,
		@xmlOk bit
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_SimpleOperationBase', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
	
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
		
			--wyciaganie danych z XMLa
			SELECT @DataProgramu = C.value('./@AppDate', 'datetime')
					,@UserId = C.value('./@UserId', 'int')
					,@BranchId = C.value('./@BranchId', 'int')
					,@StatusS = C.value('./@StatusS', 'int')
					,@StatusP = C.value('./@StatusP', 'int')
					,@StatusW = C.value('./@StatusW', 'int')
			FROM @xml_data.nodes('/Request') T(C)

			-- pobranie daty na podstawie przekazanego AppDate
			SELECT @AppDate = THB.PrepareAppDate(@DataProgramu);
			
			--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji select
			EXEC [THB].[CheckUserPermission]
				@Operation = N'GET',
				@UserId = @UserId,
				@BranchId = @BranchId,
				@Result = @MaUprawnienia OUTPUT
			
			IF @MaUprawnienia = 1
			BEGIN
			
				SET @inputXml = '';
				
				-- pobranie danych elementow , argumentow operacji
				SELECT @inputXml += CAST(x.query('.') AS nvarchar(MAX))
				FROM @xml_data.nodes('/Request/*') e(x)
				
				--przygotowanie xmla przeslanego do wlasciwej metody wyliczajacej
				SET @inputXml = CAST (
					(SELECT @AppDate AS '@AppDate'
						,@UserId AS '@UserId'
						,@BranchId AS '@BranchId'
						,@RequestType AS '@RequestType'
						,@StatusS AS '@StatusS'
						,@StatusP AS '@StatusP'
						,@StatusW AS '@StatusW'
						, (SELECT @inputXml)
					FROM @xml_data.nodes('/Request') e(x)	
					FOR XML PATH('Request')) AS nvarchar(MAX));
			
				-- zamiana znaczkow ;gt na > itp
				SET @inputXml = [THB].[PrepareXMLValue](@inputXml);
		
				-- wywolanie procedury liczacej prosta operacje
				EXEC [THB].[SimpleOperation]
					@XMLDataIn = @inputXml,
					@XMLDataOut = @XMLDataOut OUTPUT

			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UserId, @Val2 = @RequestType, @Wiadomosc = @ERRMSG OUTPUT	
		
			END TRY
			BEGIN CATCH
				SET @ERRMSG = @@ERROR;
				SET @ERRMSG += ' ';
				SET @ERRMSG += ERROR_MESSAGE();
			END CATCH
		END
		
	-- reczne przygotowanie XMLa zwrotnego jesli jakis blad
	IF @ERRMSG IS NOT NULL AND LEN(@ERRMSG) > 0
	BEGIN
		SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="' + @RequestType + '"'
	
		IF @DataProgramu IS NOT NULL
			SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
		
		SET @XMLDataOut += '>';
		
		SET @XMLDataOut += '<Result><Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '"/></Result></Response>';
	END

END
