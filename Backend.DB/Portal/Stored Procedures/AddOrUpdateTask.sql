CREATE PROCEDURE [Portal].[AddOrUpdateTask]
	@Id INT, 
	@XMLDataIn NVARCHAR(MAX),
	@XMLDataOut NVARCHAR(MAX) OUTPUT
AS
	DECLARE @IdsMappings TABLE
	(
		Id INT,
		AttributeId INT
	);


	INSERT INTO @IdsMappings
	SELECT 
		zc.Id      AS Id, 
		c.Cecha_ID AS AttributeId
	FROM [dbo].[_Zlecenie  nietabelaryczne_Cechy_Hist] zc
	INNER JOIN [dbo].[Cechy] c
		ON zc.CechaID = c.Cecha_ID
	WHERE ObiektId = @Id

	SELECT @XMLDataIn = REPLACE(@XMLDataIn, 'Attribute Id="0" TypeId="' + CAST(m.AttributeId AS NVARCHAR(MAX)) + '"', 
		'Attribute Id="' + CAST(m.Id AS NVARCHAR(MAX)) + '" TypeId="' + CAST(m.AttributeId AS NVARCHAR(MAX)) + '"')
	FROM @IdsMappings AS m

	EXEC [THB].[Units_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut OUTPUT;
RETURN 0
