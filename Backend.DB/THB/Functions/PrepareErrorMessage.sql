-- =============================================
-- Author:		DK
-- Create date: 30-03-2012
-- Description:	Funckja zamienia " na '.
-- =============================================
CREATE FUNCTION [THB].[PrepareErrorMessage]
(
	@Error nvarchar(MAX)
)
RETURNS nvarchar(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @safeQuery nvarchar(MAX);

	SET @safeQuery = REPLACE(@Error, '"', '''');
	
	RETURN @safeQuery
END