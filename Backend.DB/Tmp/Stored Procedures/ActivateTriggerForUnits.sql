------------------------------------------------------------
-- wylacza lub wlacza triger na tabeli z cechami podanego obiektu
CREATE PROCEDURE [Tmp].[ActivateTriggerForUnits]
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
	BEGIN
		SET @Query = '	ENABLE TRIGGER dbo.[WartoscZmiany_' + @UnitTypeName + '_UPDATE] ON dbo.[_' + @UnitTypeName + '];
						--SET IDENTITY_INSERT dbo.[_' + @UnitTypeName + '] OFF;'
	END
	ELSE
	BEGIN
		SET @Query = '	DISABLE TRIGGER dbo.[WartoscZmiany_' + @UnitTypeName + '_UPDATE] ON dbo.[_' + @UnitTypeName + '];
						--SET IDENTITY_INSERT dbo.[_' + @UnitTypeName + '] ON;'
	END
			
	--PRINT @Query;
	EXECUTE sp_executesql @Query;
				
END;

