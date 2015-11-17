-- =============================================
-- Author:		DK
-- Create date: 2012-04-27
-- Description:	Sprawdza czy podany obiekt struktury jest poprawny i wazny

-- =============================================
CREATE PROCEDURE [THB].[CheckStructureRootNode]
(
	@StructureId int,
	@StartDate date,
	@EndDate date,
	@Success bit OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @StructureExists bit = 0,
	@Query nvarchar(MAX) = '';
		
	SET @Success = 0;
	
	--sprawdzenie czy struktura obiekt o podanym Id istnieje i jest "wazny"
	SET @Query = '
	IF EXISTS (SELECT Id FROM dbo.Struktura_Obiekt WHERE Id = ' + CAST(@StructureId AS varchar) + ' AND IdArch IS NULL AND IsValid = 1 AND IsDeleted = 0
				AND (ValidFrom <= ''' + CONVERT(varchar, @StartDate, 112) + ' 23:59:59'' AND (ValidTo IS NULL OR ValidTo >= ''' + CONVERT(varchar, @EndDate, 112) + ' 00:00:00'' )))
		SET @StructureExistsTmp = 1';
	
	--PRINT @Query;	
	EXECUTE sp_executesql @Query, N'@StructureExistsTmp bit OUTPUT', @StructureExistsTmp = @StructureExists OUTPUT

	IF @StructureExists = 1
	BEGIN
		--jesli struktura istnieje i ma co najmniej 1 relacje to zwrocenie true
		SET @Query = '
		IF (SELECT COUNT(1) FROM dbo.Struktura WHERE StrukturaObiektId = ' + CAST(@StructureId AS varchar) + ' AND IsValid = 1 AND IsDeleted = 0
			AND (ValidFrom <= ''' + CONVERT(varchar, @StartDate, 112) + ' 23:59:59'' AND (ValidTo IS NULL OR ValidTo >= ''' + CONVERT(varchar, @EndDate, 112) + ' 00:00:00'' ))) > 0
			SET @SuccessTmp = 1';
			
		EXECUTE sp_executesql @Query, N'@SuccessTmp bit OUTPUT', @SuccessTmp = @Success OUTPUT

	END
	
	--IF @StructureExists = 1
	--BEGIN
	--	--jesli struktura istnieje i ma co najmniej 1 relacje to zwrocenie true
	--	IF (SELECT COUNT(1) FROM dbo.Struktura WHERE StrukturaObiektId = @StructureId AND IsValid = 1 AND IsDeleted = 0) > 0
	--		SET @Success = 1;
	--END

END
