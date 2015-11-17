-- =============================================
CREATE PROCEDURE [THB].[AttributeTypes_GetByBranch] 
(
	@AppDate datetime,
	@BranchId int
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @Query nvarchar(MAX)		
		
	SET @Query = '
		SELECT DISTINCT bc.CechaId
		FROM dbo.Branze_Cechy bc
		WHERE BranzaId = ' + CAST(@BranchId AS varchar);
		
		--dodanie frazy na daty
		SET @Query += [THB].[PrepareDatesPhrase] ('bc', @AppDate);
			
	--PRINT @Query;
	EXECUTE sp_executesql @Query;																
	
END
