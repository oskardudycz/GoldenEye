


-- =============================================
-- Author:		DW
-- Create date: 27.05
-- Description:	zwraca informacje z tabeli Variables
-- =============================================
CREATE PROCEDURE [dbo].[Variables_PodajInfo]
(
	@VarName nvarchar(50)
	,@VarGroup nvarchar(50)
	,@Info	nvarchar(500) OUTPUT
	,@Type nvarchar(50) OUTPUT

)
AS
BEGIN

	SELECT @Info = VarValue
		, @Type = varType
	FROM Variables WITH (NOLOCK) 
	WHERE VarName = @VarName
	AND VarGroup=@VarGroup

END



