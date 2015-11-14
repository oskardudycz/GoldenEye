-- =============================================
-- Author:		DK
-- Create date: 2013-04-10
-- Lst modified date: 2013-04-19
-- Description:	Funckja zwraca wartość cechy (id liczbowe lub tekstowe).
-- =============================================
CREATE FUNCTION [THB].[GetAttributeFilterValue]
(
    @ColumnsSet xml,
    @StringValue nvarchar(MAX)
)
RETURNS nvarchar(MAX)
AS
BEGIN
	DECLARE @resultStr nvarchar(MAX) = NULL
	
	IF @ColumnsSet IS NOT NULL
	BEGIN
		SELECT @resultStr = THB.GetAttributeValueValueFromSparseXML(@ColumnsSet);
	END
	
	IF @resultStr IS NULL
	BEGIN
		SET @resultStr = @StringValue
	END

	RETURN @resultStr;
END

