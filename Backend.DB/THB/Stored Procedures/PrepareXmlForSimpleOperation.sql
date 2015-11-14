-- =============================================
-- Author:		DK
-- Create date: 2012-10-25
-- Last modified on: 2012-11-19
-- Description:	Przygotowuje XML (Request) do przekazania do metody SimpleOperation.
-- =============================================
CREATE PROCEDURE [THB].[PrepareXmlForSimpleOperation]
(
	@Arg1 xml,
	@Arg2 xml,
	@Operation varchar(3),
	@UserId int,
	@AppDate datetime,
	@StatusS int = NULL,
	@StatusP int = NULL,
	@StatusW int = NULL,
	@ResultXml nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @inputXml nvarchar(MAX) = '',
		@XmlArg1 xml,
		@XmlArg2 xml,
		@RequestType nvarchar(100),
		@ERRMSG nvarchar(MAX)
		
	BEGIN TRY
	
		SET @RequestType = 'SimpleOperation_' + ISNULL(@Operation, '');
	
		--pobranie dwoch argumentow korzenia - od tego zaczynana jest rekurencja
		SELECT @XmlArg1 = x.query('.')
		FROM @Arg1.nodes('/*[@Lp=1]/*[1]') e(x)
		
		SELECT @XmlArg2 = x.query('.')
		FROM @Arg2.nodes('/*[@Lp=2]/*[1]') e(x);		

		-- dodanie atrybutow Lp do XMLi
		IF @XmlArg1 IS NOT NULL
		BEGIN
			SET @XmlArg1.modify('insert attribute Lp {"1"} into (//*)[1]');
		END
		
		IF @XmlArg2 IS NOT NULL
		BEGIN
			SET @XmlArg2.modify('insert attribute Lp {"2"} into (//*)[1]');
		END
	

--SELECT @XmlArg1 AS FinalArg1, @XmlArg2 AS FinalArg2, @Operation AS Operation
		
		--przygotowanie xmla przeslanego do wlasciwej metody wyliczajacej
		SET @ResultXml = CAST((SELECT @AppDate AS '@AppDate'
			,@UserId AS '@UserId'
			--,@BranchId AS '@BranchId'
			,@RequestType AS '@RequestType'
			,@StatusS AS '@StatusS'
			,@StatusP AS '@StatusP'
			,@StatusW AS '@StatusW'
			, (SELECT @XmlArg1)
			, (SELECT @XmlArg2)	
		FOR XML PATH('Request')) AS nvarchar(MAX))		

	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		SELECT @ERRMSG;
		
	END CATCH

END
