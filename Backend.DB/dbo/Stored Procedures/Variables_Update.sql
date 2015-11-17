
-- =============================================
-- Author:		DW
-- Create date: <Create Date,,>
-- Description: Ustawia informacje dla zmiennych
-- =============================================
CREATE PROCEDURE [dbo].[Variables_Update]
(
	@Nazwa nvarchar(100)
	,@Grupa nvarchar(100)
	,@Wartosc nvarchar(255) 
)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Variables
	SET VarValue =@Wartosc
	WHERE Varname = @Nazwa
	AND VarGroup=@Grupa
	AND IsValid=1
END

