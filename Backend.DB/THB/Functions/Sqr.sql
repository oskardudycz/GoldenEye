-- =============================================
-- Author:		DK
-- Create date: 2012-11-15
-- Description:	Wylicza kwadrat podanej liczby
-- =============================================
CREATE FUNCTION [THB].Sqr
(
	@Arg int
)
RETURNS int
AS
BEGIN
	DECLARE @Result int

	SET @Result = @Arg * @Arg;

	RETURN @Result

END
