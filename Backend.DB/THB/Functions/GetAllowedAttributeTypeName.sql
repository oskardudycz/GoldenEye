-- =============================================
-- Author:		DK
-- Create date: 2013-05-09
-- Description:	Funckja zwraca dozowlona nazwe typu cechy, bez ?! itp
-- =============================================
CREATE FUNCTION [THB].[GetAllowedAttributeTypeName]
(
    @Name nvarchar(500)
)
RETURNS nvarchar(255)
AS
BEGIN
	DECLARE @text nvarchar(500)

	SET @text = REPLACE(@Name, '?', '');
	SET @text = REPLACE(@text, '!', '');

	RETURN @text;
END

