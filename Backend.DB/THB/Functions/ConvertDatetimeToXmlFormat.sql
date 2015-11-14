-- =============================================
-- Author:		DK
-- Create date: 2013-04-15
-- Description:	Funckja zamienia date w formacie stringowym z bazy na format XMLa.
-- =============================================
CREATE FUNCTION [THB].[ConvertDatetimeToXmlFormat]
(
    @DatetimeInString nvarchar(100)
)
RETURNS nvarchar(100)
AS
BEGIN
	DECLARE @datetime datetime = CAST(@DatetimeInString AS datetime),
			@dateAfterConverting nvarchar(100)
	
	SET @dateAfterConverting = CONVERT(nvarchar(20), @datetime, 126)

	RETURN @dateAfterConverting;
END

