
CREATE FUNCTION [THB].[IsActualDate](@AppDate datetime)
RETURNS bit
AS 
BEGIN
  
  DECLARE @appDateStr varchar(20) = CONVERT ( varchar(20), @AppDate, 102),
		  @serverDateStr varchar(20) = CONVERT ( varchar(20), GETDATE(), 102),
		  @result bit = 0
      
      
  IF @appDateStr = @serverDateStr
	SET @result = 1;

	RETURN @result
END