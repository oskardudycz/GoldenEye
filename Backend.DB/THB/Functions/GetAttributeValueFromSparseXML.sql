-- =============================================
-- Author:		DK
-- Create date: 2013-01-27
-- Description:	Funckja zwraca przefiltrowana wartosc cechy z ColumnsSeta zawierającego wszystkie wartości kolumn SPARSE.
-- =============================================
CREATE FUNCTION [THB].[GetAttributeValueFromSparseXML]
(
    @ColumnsSet xml
)
RETURNS xml
AS
BEGIN
	DECLARE @resultStr nvarchar(300),
			@result xml;

	--pobranie wartosci cechy (elementy zaczynajace sie od Val
	SELECT @resultStr = CAST(@ColumnsSet.query('./*[(fn:local-name()!=''ValidTo'') and (fn:local-name()!=''IsValidForAlgorithm'') and (fn:contains(fn:local-name(.), ''Val''))][1]') AS nvarchar(300))   --'./*[fn:contains(fn:local-name(.), ''Val'')][1]') AS nvarchar(300))
	
	IF @resultStr = ''
		SET @result = NULL;
	ELSE
		SET @result = CAST(@resultStr AS xml);

	RETURN @result;
END

