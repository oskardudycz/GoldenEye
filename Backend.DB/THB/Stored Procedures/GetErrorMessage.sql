
-- =============================================
-- Author:		DK
-- Create date: <Create Date,,>
-- Description: Podaje informacje z Variables na temat podanego bledu jaki zostanie zwrocony do aplikacji.
-- =============================================
CREATE PROCEDURE [THB].[GetErrorMessage]
(
	@Nazwa nvarchar(100)
	,@Grupa nvarchar(100)
	,@Val1 nvarchar(50) = NULL
	,@Val2 nvarchar(50) = NULL
	,@Wiadomosc nvarchar(255) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET @Wiadomosc = '';
	
	DECLARE @TmpString nvarchar(300),
		@FirstIndex int	
	
	SELECT @TmpString = VarValue 
	FROM dbo.Variables
	WHERE Varname = @Nazwa AND VarGroup = @Grupa
	
	IF @TmpString IS NOT NULL
	BEGIN
		EXEC xp_sprintf @Wiadomosc OUTPUT, @TmpString, @Val1, @Val2
	END

END

