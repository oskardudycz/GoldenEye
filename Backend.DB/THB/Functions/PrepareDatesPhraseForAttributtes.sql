-- =============================================
-- Author:		DK
-- Create date: 2012-11-08
-- Last modified on: 2013-02-12
-- Description:	Przygotowanie frazy związanej z datami - filtracja na date aplikacji.
-- =============================================
CREATE FUNCTION [THB].[PrepareDatesPhraseForAttributtes]
(
	@Alias varchar(5) = NULL,
	@AppDate datetime
)
RETURNS nvarchar(MAX)
AS
BEGIN

	DECLARE @Where nvarchar(MAX) = '',
		@ActualDate bit
	
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
	SET @Where += ' AND (' + @Alias + 'IsDeleted = 0 OR (' + @Alias + 'IsDeleted = 1 AND ' + @Alias + 'DeletedFrom > ''' + CONVERT(varchar, @AppDate, 109) + '''))';	

	--IF @AppDate IS NOT NULL
	--	SET @Where += ' AND (' + @Alias + 'ValidFrom <= ''' + CONVERT(varchar, @AppDate, 112) + ' 23:59:59'' AND (' + @Alias + 
	--		'ValidTo IS NULL OR ' + @Alias + 'ValidTo >= ''' + CONVERT(varchar, @AppDate, 112) + ' 00:00:00'' )) ' 		

	---- jesli aktualna data na walidacje to znajdowanie tylko najnowszego wpisu i nie usunietego
	--IF @ActualDate = 1
	--	SET @Where += ' AND ' + @Alias + 'IsDeleted = 0';	
	
	RETURN @Where

END
