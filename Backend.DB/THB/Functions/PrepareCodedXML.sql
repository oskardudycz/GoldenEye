-- =============================================
-- Author:		DK
-- Create date: 2012-11-08
-- Description:	Funckja zamienia XMLowe znaki >, <. na ich kodowane odpowiedniki.
-- =============================================
CREATE FUNCTION [THB].[PrepareCodedXML]
(
	@ValString nvarchar(MAX)
)
RETURNS nvarchar(MAX)
AS
BEGIN
	DECLARE @Value nvarchar(MAX);

	SET @Value = @ValString;
	
	SET @Value = REPLACE(@Value, '&', '&amp;');
	SET @Value = REPLACE(@Value, '''', '&apos;');
	SET @Value = REPLACE(@Value, '<', '&lt;');
	SET @Value = REPLACE(@Value, '>', '&gt;');
	SET @Value = REPLACE(@Value, '"', '&quot;');
	
	RETURN @Value

END
