-- =============================================
-- Author:		DK
-- Create date: 2013-02-14
-- Last modified on: --
-- Description:	Przygotowanie frazy związanej z datami - filtracja na date aplikacji - czas obowiazywania + ew flaga czy usuniety.
-- =============================================
CREATE FUNCTION [THB].[PrepareDatesPhraseFor2DatesExtended]
(
	@Alias varchar(5) = NULL,
	@StartDate datetime,
	@EndDate datetime,
	@AddDeleteStatement bit = 1
)
RETURNS nvarchar(MAX)
AS
BEGIN

	DECLARE @Where nvarchar(MAX) = ''
		
	IF @StartDate IS NULL AND @EndDate IS NULL
		RETURN @Where;
		
	IF @StartDate IS NULL AND @EndDate IS NOT NULL
		SET @StartDate = @EndDate;
		
	IF @StartDate IS NOT NULL AND @EndDate IS NULL
		SET @EndDate = @StartDate;
	
	--jesli podano alias tabeli to dodanie go do zapytania
	IF @Alias IS NULL
		SET @Alias = ''
	ELSE
		SET @Alias += '.';
		
		SET @Where += ' AND (' + @Alias + [THB].[GetDateFromFilterColumn]() + ' >= ''' + CONVERT(varchar, @StartDate, 112) + ' 23:59:59'' AND ' + 
			@Alias + [THB].[GetDateFromFilterColumn]() + ' <= ''' + CONVERT(varchar, @EndDate, 112) + ' 23:59:59'')' 		

	-- jesli aktualna data na walidacje to znajdowanie tylko najnowszego wpisu i nie usunietego
	IF @AddDeleteStatement = 1
		SET @Where += ' AND (' + @Alias + 'IsDeleted = 0 OR (' + @Alias + 'IsDeleted = 1 AND ' + @Alias + 'DeletedFrom > ''' + CONVERT(varchar, @EndDate, 109) + '''))';	
	
	RETURN @Where

END
