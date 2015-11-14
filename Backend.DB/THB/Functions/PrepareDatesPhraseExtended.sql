-- =============================================
-- Author:		DK
-- Create date: 2013-02-14
-- Last modified on: --
-- Description:	Przygotowanie frazy związanej z datami - filtracja na date aplikacji - czas obowiazywania + ew flaga czy usuniety.
-- =============================================
CREATE FUNCTION [THB].[PrepareDatesPhraseExtended]
(
	@Alias varchar(5) = NULL,
	@AppDate datetime,
	@AddDeleteStatement bit = 1
)
RETURNS nvarchar(MAX)
AS
BEGIN

	DECLARE @Where nvarchar(MAX) = ''
		
	IF @AppDate IS NULL
		SET @AppDate = GETDATE()
	
	--jesli podano alias tabeli to dodanie go do zapytania
	IF @Alias IS NULL
		SET @Alias = ''
	ELSE
		SET @Alias += '.';
		
	IF @AppDate IS NOT NULL
		SET @Where += ' AND (' + @Alias + [THB].[GetDateFromFilterColumn]() + ' <= ''' + CONVERT(varchar, @AppDate, 112) + ' 23:59:59'')' 		

	-- jesli aktualna data na walidacje to znajdowanie tylko najnowszego wpisu i nie usunietego
	IF @AddDeleteStatement = 1
		SET @Where += ' AND (' + @Alias + 'IsDeleted = 0 OR (' + @Alias + 'IsDeleted = 1 AND ' + @Alias + 'DeletedFrom > ''' + CONVERT(varchar, @AppDate, 109) + '''))';	
	
	RETURN @Where

END
