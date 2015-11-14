-- =============================================
-- Author:		DK
-- Create date: 2013-01-27
-- Description:	Funckja zwraca nazwę elementu z XML.
-- =============================================
CREATE FUNCTION [THB].[GetAttributeValueTypeFromSparseXML]
(
    @ColumnsSet xml
)
RETURNS nvarchar(100)
AS
BEGIN
	DECLARE @resultStr nvarchar(100) = NULL,
			@result xml;
			
	SELECT @result = THB.GetAttributeValueFromSparseXML(@ColumnsSet);
	
	IF @result IS NOT NULL
	BEGIN
		SELECT @resultStr = C.value('local-name(.)', 'nvarchar(200)') FROM @result.nodes('/*') AS t(C)
	END

	RETURN @resultStr;
END

