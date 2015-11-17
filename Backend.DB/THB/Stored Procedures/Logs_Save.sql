-- =============================================
-- Author:		DK
-- Create date: 2013-02-11
-- Description:	Zapisuje do logów dane wywolanie procedury
-- =============================================
CREATE PROCEDURE [THB].[Logs_Save]
(
	@XMLDataIn nvarchar(MAX),
	@XmlDataOut nvarchar(MAX) 
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @XmlIn xml,
		@XmlOut xml,
		@IsError bit,
		@ErrorMessage nvarchar(MAX),
		@SaveOnlyErrors bit = 1;

	BEGIN TRY

		--usuniecie danych kodowania znakow
		SET @XMLDataIn = REPLACE(@XMLDataIn, '<?xml version="1.0" encoding="utf-8"?>', '');
		SET @XMLDataOut = REPLACE(@XMLDataOut, '<?xml version="1.0" encoding="utf-8"?>', '');

		SET @XmlIn = CAST(@XMLDataIn AS xml);
		SET @XmlOut = CAST(@XMLDataOut AS xml);
		
		--proba pobrania tresci komunikatu bledu wprost za elementem Response
		SELECT @ErrorMessage = C.value('./@ErrorMessage', 'nvarchar(MAX)')
		FROM @XmlOut.nodes('/Response/Error') T(c)
		
		--proba pobrania komunkatu bledu w elemencie Result
		IF @ErrorMessage IS NULL OR @ErrorMessage = ''
		BEGIN
			SELECT @ErrorMessage = C.value('./@ErrorMessage', 'nvarchar(MAX)')
			FROM @XmlOut.nodes('/Response/Result/Error') T(c)
		END		
		
		IF @ErrorMessage IS NULL OR @ErrorMessage = ''
			SET @IsError = 0;
		ELSE
			SET @IsError = 1;
		
		IF (@SaveOnlyErrors = 1 AND @IsError = 1) OR @SaveOnlyErrors = 0
		BEGIN
			INSERT INTO Logi(XmlIn,XmlOut,IsError)
			VALUES (@XmlIn, @XmlOut, @IsError);
		END
			
	END TRY
	BEGIN CATCH
		PRINT 'Error przy zapisie logów'		
	END CATCH 

END
