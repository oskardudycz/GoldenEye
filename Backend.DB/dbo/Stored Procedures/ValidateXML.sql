-- =============================================
-- Author:		DK
-- Create date: 2012-2-23
-- Description:	Procedura walidujaca dokument XML
-- =============================================
CREATE PROCEDURE [dbo].[ValidateXML]
(
	@XSDSchemaName nvarchar(50), 
	@XmlData nvarchar(MAX),
	@Success bit OUT,
	@ERRMSG nvarchar(255) OUT
)
AS
BEGIN	
	DECLARE @vQuery nvarchar(MAX)
	SET @Success = 0;
	
	--podejrzenie definicji schematu
	--SELECT xml_schema_namespace(N'dbo', @XSDSchemaName))
	
	--sprawdzenie czy xsd o podanej nazwie istnieje
	IF EXISTS (SELECT name FROM sys.xml_schema_collections where name = @XSDSchemaName)  
	BEGIN
		SET @vQuery =  N'		
			BEGIN TRY
				DECLARE @x XML(' + @XSDSchemaName + ');
				SELECT @x = ''' + @XmlData + '''
				
				IF @x IS NOT NULL
					SET @successVar = 1;
				ELSE
					SET @successVar = 0;
			END TRY
			BEGIN CATCH
				SET @successVar = 0;
				SET @ERRMSGTemp = error_message();
			END CATCH'; 			

		--PRINT @vQuery
		EXECUTE sp_executesql @vQuery, N'@successVar bit OUT, @ERRMSGTemp nvarchar(255) OUT', @successVar = @Success OUT, @ERRMSGTemp = @ERRMSG OUT
	END
	ELSE
	BEGIN
		SET @ERRMSG = 'Schemat XSD o podanej nazwie nie istnieje.';		
	END
	
END
