-- =============================================
-- Author:		DK
-- Create date: 2012-11-08
-- Last modified on: 2013-02-14
-- Description:	Przygotowanie frazy związanej z datami - filtracja na date aplikacji - czas obowiazywania.
-- =============================================
CREATE FUNCTION [THB].[PrepareDatesPhrase]
(
	@Alias varchar(5) = NULL,
	@AppDate datetime
)
RETURNS nvarchar(MAX)
AS
BEGIN
	DECLARE @Where nvarchar(500)
	
	SET @Where = [THB].[PrepareDatesPhraseExtended] (@Alias, @AppDate, 1);
	
	RETURN @Where

END
