-- =============================================
-- Author:		DK
-- Create date: 2012-12-27
-- Last modified on: --
-- Description:	Pobiera nazwe kolumny po ktorej bedzie filtrowana data Od.
-- =============================================
CREATE FUNCTION [THB].[GetDateToFilterColumn]
(
)
RETURNS nvarchar(100)
AS
BEGIN
	
	RETURN 'ObowiazujeDo' --'ValidTo'

END
