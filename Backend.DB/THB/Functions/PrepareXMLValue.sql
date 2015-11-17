-- =============================================
-- Author:		DK
-- Create date: <Create Date, ,>
-- Description:	Funckja zamienia XMLowe znaki specjalne na ich odpowiedniki >, <.
-- =============================================
CREATE FUNCTION [THB].[PrepareXMLValue]
(
	@ValString nvarchar(MAX)
)
RETURNS nvarchar(MAX)
AS
BEGIN
	DECLARE @Value nvarchar(MAX);

	SET @Value = @ValString;
	
	SET @Value = REPLACE(@Value, '&amp;', '&');
	SET @Value = REPLACE(@Value, '&apos;', '''');
	SET @Value = REPLACE(@Value, '&lt;', '<');
	SET @Value = REPLACE(@Value, '&gt;', '>');
	SET @Value = REPLACE(@Value, '&quot;', '"');
	
	RETURN @Value

END
