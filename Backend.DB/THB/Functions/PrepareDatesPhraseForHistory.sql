-- =============================================
-- Author:		DK
-- Create date: 2012-11-08
-- Last modified on: 2012-11-22
-- Description:	Przygotowanie frazy związanej z datami - filtracja na date aplikacji - czas obowiazywania.
-- =============================================
CREATE FUNCTION [THB].[PrepareDatesPhraseForHistory]
(
	@Alias varchar(5) = NULL,
	@AppDate datetime
)
RETURNS nvarchar(MAX)
AS
BEGIN

	DECLARE @Where nvarchar(MAX) = '',
		@ActualDate bit
	
	--jesli podano alias tabeli to dodanie go do zapytania
	IF @Alias IS NULL
		SET @Alias = ''
	ELSE
		SET @Alias += '.';
		
	SELECT @ActualDate = THB.IsActualDate(@AppDate);

	IF @AppDate IS NOT NULL
		SET @Where += ' AND (' + @Alias + [THB].[GetDateFromFilterColumn]() + ' <= ''' + CONVERT(varchar, @AppDate, 112) + ' 23:59:59'')' 		

	-- jesli aktualna data na walidacje to znajdowanie tylko najnowszego wpisu i nie usunietego
	--IF @ActualDate = 1
	--	SET @Where += ' AND ' + @Alias + 'IsDeleted = 0';	
	
	RETURN @Where

END
