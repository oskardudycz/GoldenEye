CREATE PROCEDURE [dbo].[XmlJobs]
	@xml_doc XML
AS
DECLARE @query varchar(512)
BEGIN
	SET NOCOUNT ON;
	
	SET  @query = 'test'
	 
	print(CAST(@xml_doc as nvarchar))
	
END
