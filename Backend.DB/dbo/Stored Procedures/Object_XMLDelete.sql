-- =============================================
-- Author:		DW
-- Create date: 2011
-- Description:	deletes objects
-- =============================================
CREATE PROCEDURE [dbo].[Object_XMLDelete]
(
	@xml_data_in nvarchar(MAX)
	,@soft_delete bit
	
)AS
BEGIN
DECLARE @query nvarchar(max)=''
DECLARE @tableName nvarchar(256)
DECLARE @TypObiektuId INT
--DECLARE @xml_data_in nvarchar(MAX)=N'
--	<root DataProgramu="">
--		<typ_obiekt id="92">
--			<obiekt id="50"/>
--		</typ_obiekt> 	
--	</root>'


DECLARE @xml_data xml
	DECLARE @ParamDefinition nvarchar(512)
	DECLARE @xmlOut xml

SET @xml_data = CAST(@xml_data_in as xml)

	SELECT 
		C.value('../@id','int') as TypObiektID
		,C.value('./@id','int') as ObiektID
		,CASE 
			WHEN C.value('../../@DataProgramu','varchar(20)') ='' THEN NULL
			ELSE C.value('../../@DataProgramu','varchar(20)') END
				
		as DataProgramu
	INTO #Obiekty
	FROM @xml_data.nodes('/root/typ_obiekt/obiekt') T(C)
	
	select * from #Obiekty
	
	DECLARE _cur CURSOR FOR 
	SELECT DISTINCT TypObiektId from #Obiekty
	
	OPEN _cur
	FETCH NEXT FROM _cur INTO @TypObiektuId 
	WHILE @@FETCH_STATUS =0
	BEGIN
	
		SELECT @tableName = t.Nazwa 
		FROM dbo.TypObiektu t 
		WHERE t.TypObiekt_ID = @TypObiektuId
	
		SET @query = 
		N' UPDATE S 
		SET IsDeleted=1
			--,IsValid=0
			--,ValidTo = GETDATE()
			,DeletedFrom = GETDATE()
			,LastModifiedOn= GETDATE()
		FROM [dbo].[_'+@tableName +'] S  JOIN  
		(	
			SELECT'+
			' obj.Id as ''ObiektID'' '+
			' FROM  [dbo].[_'+@tableName +'] obj '+
			' JOIN #Obiekty O ON obj.Id = O.ObiektID'+
			'
			WHERE (obj.IsValid=1 OR obj.IsValid IS NULL)
			AND O.TypObiektID = '+CAST(@TypObiektuId as varchar)+'
			AND 
				(
				O.DataProgramu BETWEEN obj.ZmianaOd AND obj.ZmianaDo AND obj.ZmianaDo IS NOT NULL
				AND obj.ZmianaOd IS NOT NULL  AND O.DataProgramu IS NOT NULL 
				) OR
				(
					O.DataProgramu >= obj.ZmianaOd AND obj.ZmianaDo IS NULL
					AND obj.ZmianaOd IS NOT NULL AND O.DataProgramu IS NOT NULL 
				) OR O.DataProgramu IS NULL
		) D  ON S.Id = D.ObiektID'
		
		PRINT @Query
		EXEC (@query)
		
		SET @query = 
		N' UPDATE S 
		SET IsDeleted=1
			--,IsValid=0
			--,ValidTo = GETDATE()
			,DeletedFrom = GETDATE()
			,LastModifiedOn= GETDATE()
		FROM [dbo].[_'+@tableName+'_Cechy_Hist] S  JOIN  
		(	
			SELECT'+
			' ch.Id as ''CechaID'' '+
			' FROM [dbo].[_'+@tableName+'_Cechy_Hist] ch'+
			' JOIN [dbo].[_'+@tableName +'] obj ON obj.Id = ch.ObiektId'+
			' JOIN #Obiekty O ON obj.Id = O.ObiektID'+
			'
			WHERE (ch.IsValid=1 OR ch.IsValid IS NULL) 
			AND O.TypObiektID = '+CAST(@TypObiektuId as varchar)+'
			AND 
				(
				O.DataProgramu BETWEEN CH.ZmianaOd AND CH.ZmianaDo AND CH.ZmianaDo IS NOT NULL
				AND CH.ZmianaOd IS NOT NULL  AND O.DataProgramu IS NOT NULL 
				) OR
				(
					O.DataProgramu >= CH.ZmianaOd AND CH.ZmianaDo IS NULL
					AND CH.ZmianaOd IS NOT NULL AND O.DataProgramu IS NOT NULL 
				) OR O.DataProgramu IS NULL 
			
		) D  ON S.Id = D.CechaID'
		
		PRINT @Query
		EXEC (@query)
		
		
		UPDATE RCH 
		SET 
			IsDeleted=1
			--,IsValid=0
			--,ValidTo = GETDATE()
			,DeletedFrom = GETDATE()
			,LastModifiedOn= GETDATE()
		FROM dbo.Relacja_Cecha_Hist RCH JOIN  dbo.Relacje R 
		On RCH.RelacjaID = R.Id
		JOIN #Obiekty O 
		ON R.ObiektID_L = O.ObiektID AND R.TypObiektuID_L = @TypObiektuId
		OR  R.TypObiektuID_R = @TypObiektuId AND R.ObiektID_R = O.ObiektID 
		WHERE 
		(
			O.DataProgramu BETWEEN RCH.ZmianaOd AND RCH.ZmianaDo AND RCH.ZmianaDo IS NOT NULL
			AND RCH.ZmianaOd IS NOT NULL  AND O.DataProgramu IS NOT NULL 
		) OR
		(
			O.DataProgramu >= RCH.ZmianaOd AND RCH.ZmianaDo IS NULL
			AND RCH.ZmianaOd IS NOT NULL AND O.DataProgramu IS NOT NULL 
		) OR O.DataProgramu IS NULL 
		

		UPDATE R 
		SET 
			IsDeleted=1
			--,IsValid=0
			--,ValidTo = GETDATE()
			,DeletedFrom = GETDATE()
			,LastModifiedOn= GETDATE()
		FROM dbo.Relacje R JOIN #Obiekty O
		ON R.ObiektID_L = O.ObiektID AND R.TypObiektuID_L = @TypObiektuId
		OR  R.TypObiektuID_R = @TypObiektuId AND R.ObiektID_R = O.ObiektID 
		WHERE 
		(
			O.DataProgramu BETWEEN R.ZmianaOd AND R.ZmianaDo AND R.ZmianaDo IS NOT NULL
			AND R.ZmianaOd IS NOT NULL  AND O.DataProgramu IS NOT NULL 
		) OR
		(
			O.DataProgramu >= R.ZmianaOd AND R.ZmianaDo IS NULL
			AND R.ZmianaOd IS NOT NULL AND O.DataProgramu IS NOT NULL 
		) OR O.DataProgramu IS NULL 

		
		FETCH NEXT FROM _cur INTO @TypObiektuId 
	END
	CLOSE _cur
	DEALLOCATE _cur
	
	DROP TABLE #Obiekty




END
