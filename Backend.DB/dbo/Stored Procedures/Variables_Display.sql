
-- =============================================
-- Author:		DW
-- Create date: <Create Date,,>
-- Description: Podaje informacje z Variables
-- =============================================
CREATE PROCEDURE [dbo].[Variables_Display]
(
	@Nazwa nvarchar(100)
	,@Grupa nvarchar(100)
	,@Wartosc nvarchar(255) OUTPUT
	,@Typ nvarchar(50) OUTPUT

)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT @Wartosc = VarValue 
	,@Typ= VarType
	FROM dbo.Variables
	WHERE Varname = @Nazwa
	AND VarGroup=@Grupa
	AND IsValid=1

END

