
------------------------------------------------------------------------------
-- wylacza lub wlacza triger na tabeli z cechami podanego obiektu
CREATE PROCEDURE [Tmp].[ActivateTriggerForAttributes]
(
	@UnitTypeName nvarchar(500),
	@Enable bit
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @Query nvarchar(MAX),
			@Action varchar(10)
			
	IF @Enable = 1
		SET @Action = 'ENABLE';
	ELSE
		SET @Action = 'DISABLE';
	
	--wlaczenie triggera na update
	SET @Query = '
		IF OBJECT_ID (N''[_' + @UnitTypeName + '_Cechy_Hist]'', N''U'') IS NOT NULL
		BEGIN
			' + @Action + ' TRIGGER dbo.[WartoscZmiany_' + @UnitTypeName + '_Cechy_Hist_UPDATE] ON dbo.[_' + @UnitTypeName + '_Cechy_Hist];
		END'
			
	--PRINT @Query;
	EXECUTE sp_executesql @Query;
				
END;

