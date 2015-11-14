-- =============================================
-- Author:		DK
-- Create date: 2012-09-21
-- Last modified on: --
-- Description:	Przygotowanie frazy związanej ze statusami dla zapytań związanych z cechami.
-- =============================================
CREATE FUNCTION [THB].[PrepareStatusesPhraseForAttributes]
(
	@Alias varchar(5) = NULL,
	@StatusS int,
	@StatusP int,
	@StatusW int
)
RETURNS nvarchar(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @where nvarchar(MAX) = '';
	
	IF @Alias IS NULL
		SET @Alias = ''
	ELSE
		SET @Alias += '.';

	IF @StatusS IS NOT NULL OR @StatusW IS NOT NULL OR @StatusP IS NOT NULL
	BEGIN
		SET @where += ' AND (' + @Alias + 'IsStatus = 0 OR (' + @Alias + 'IsStatus = 1';
		
		--IF @StatusS IS NOT NULL
		--	SET @where += ' AND (' + @Alias + 'StatusS <= ' + CAST(@StatusS AS varchar) + ' OR ' + @Alias + 'StatusS IS NULL)';
			
		IF @StatusW IS NOT NULL
			SET @where += ' AND (' + @Alias + 'StatusW <= ' + CAST(@StatusW AS varchar) + ' OR ' + @Alias + 'StatusW IS NULL)';

		IF @StatusP IS NOT NULL
			SET @where += ' AND (' + @Alias + 'StatusP <= ' + CAST(@StatusP AS varchar) + ' OR ' + @Alias + 'StatusP IS NULL)';
			
		SET @where += '))';
	END
	
	RETURN @where

END
