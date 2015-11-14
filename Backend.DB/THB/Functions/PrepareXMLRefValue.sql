-- =============================================
-- Author:		DK
-- Create date: 2012-12-24
-- Description:	Funckja zamienia XMLowe znaki specjalne na ich odpowiedniki >, <.
-- =============================================
CREATE FUNCTION [THB].[PrepareXMLRefValue]
(
	@ValString nvarchar(MAX)
)
RETURNS nvarchar(MAX)
AS
BEGIN
	DECLARE @Value nvarchar(MAX);

	SET @Value = @ValString;
	
	SET @Value = REPLACE(@Value, '&lt;Attribute', '<Attribute');
	SET @Value = REPLACE(@Value, '&gt;&lt;Val', '><Val');
	SET @Value = REPLACE(@Value, '&gt;&lt;/Attribute&gt;', '></Attribute>');
	SET @Value = REPLACE(@Value, '&gt;&lt;History', '><History');
	SET @Value = REPLACE(@Value, '&gt;&lt;Statuses', '><Statuses');
	
	
	
	
	RETURN @Value

END
