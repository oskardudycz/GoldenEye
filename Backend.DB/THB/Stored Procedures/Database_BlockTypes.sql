-- =============================================
-- Author:		DK
-- Create date: 2013-02-04
-- Last modified on: 2013-03-19
-- Description:	Zapisuje dane dla flagi zablokowany dla Typow obiektów i typów cech

-- XML Wejsciowy w postaci:

-- <Request RequestType="Database_BlockTypes" UserId="1" AppDate="2012-02-09T12:45:33" Block="true"/>
	
-- XML wyjsciowy w postaci:

	--<?xml version="1.0" encoding="utf-8"?>
	--<Response ResponseType="Database_BlockTypes" AppDate="2012-03-19" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="file:///C:/Users/dkral/Desktop/THB/THB_XSD_Ver9/trunk/4.UnitTypes/4.3.Response.xsd">
	--	<Result>
	--		<Value>true</Value>
	--	</Result>
	--</Response>

-- =============================================
CREATE PROCEDURE [THB].[Database_BlockTypes]
(
	@XMLDataIn nvarchar(MAX),
	@XMLDataOut nvarchar(MAX) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DataProgramu datetime,
		@RequestType nvarchar(100),
		@UzytkownikID int,
		@BranzaID int,
		@ERRMSG nvarchar(255),
		@xml_data xml,
		@xmlOk bit,
		@Block bit,
		@RowsChanged bit = 0,
		@MaUprawnienia bit = 0

	BEGIN TRY
		SET @ERRMSG = '';
		
		--walidacja poprawnosci XMLa
		EXEC [dbo].[ValidateXML] @XSDSchemaName = 'Schema_Database_BlockTypes', @XmlData = @XMLDataIn, @Success = @xmlOk OUTPUT, @ERRMSG = @ERRMSG OUTPUT
		
		IF @xmlOk = 0
		BEGIN			
			SET @ERRMSG = @ERRMSG
		END
		ELSE
		BEGIN	
			SET @xml_data = CAST(@XMLDataIn AS xml);
							
			--wyciaganie daty, uzytkownika, typu zadania i nazwy slownika
			SELECT @DataProgramu = C.value('./@AppDate', 'datetime')
					,@RequestType = C.value('./@RequestType', 'nvarchar(100)')
					,@UzytkownikID = C.value('./@UserId', 'int')
					,@BranzaID = C.value('./@BranchId', 'int')
					,@Block = C.value('./@Block', 'bit')
			FROM @xml_data.nodes('/Request') T(C);
			
						
			IF @RequestType = 'Database_BlockTypes'
			BEGIN
			
				-- pobranie daty modyfikacji na podstawie przekazanego AppDate
				--SELECT @DataModyfikacjiApp = THB.PrepareAppDate(@DataProgramu);
				
				--sprawdzenie czy uzytkownik ma uprawnienia do wykonania operacji select
				EXEC [THB].[CheckUserPermission]
					@Operation = N'SAVE',
					@UserId = @UzytkownikID,
					@BranchId = @BranzaId,
					@Result = @MaUprawnienia OUTPUT
				
				IF @MaUprawnienia = 1
				BEGIN
				
					BEGIN TRANSACTION T1_Database_BlockTypes;

					--zmiany robimy przy wylaczonych trigerach na update
					--Typy obiektow
					DISABLE TRIGGER [WartoscZmiany_TypObiektu_UPDATE] ON dbo.[TypObiektu];

					UPDATE dbo.TypObiektu SET
						IsBlocked = @Block;
					
					IF @@ROWCOUNT > 0
						SET @RowsChanged = 1;
					
					--typy cech
					ENABLE TRIGGER [WartoscZmiany_TypObiektu_UPDATE] ON dbo.[TypObiektu];	
					DISABLE TRIGGER [WartoscZmiany_Cechy_UPDATE] ON dbo.[Cechy];

					UPDATE dbo.Cechy SET
						IsBlocked = @Block;
						
					IF @@ROWCOUNT > 0
						SET @RowsChanged = 1;

					--typy relacji
					ENABLE TRIGGER [WartoscZmiany_Cechy_UPDATE] ON dbo.[Cechy];
					DISABLE TRIGGER [WartoscZmiany_TypRelacji_UPDATE] ON dbo.[TypRelacji];
					
					UPDATE dbo.[TypRelacji] SET
						IsBlocked = @Block;
						
					IF @@ROWCOUNT > 0
						SET @RowsChanged = 1;
					
					--slowniki
					ENABLE TRIGGER [WartoscZmiany_TypRelacji_UPDATE] ON dbo.[TypRelacji];
					DISABLE TRIGGER [WartoscZmiany_Slowniki_UPDATE] ON dbo.[Slowniki];
					
					UPDATE dbo.[Slowniki] SET
						IsBlocked = @Block;
						
					IF @@ROWCOUNT > 0
						SET @RowsChanged = 1;
					
					--jednostki miary
					ENABLE TRIGGER [WartoscZmiany_Slowniki_UPDATE] ON dbo.[Slowniki];
					DISABLE TRIGGER [WartoscZmiany_JednostkiMiary_UPDATE] ON dbo.[JednostkiMiary];

					UPDATE dbo.[JednostkiMiary] SET
						IsBlocked = @Block;
						
					IF @@ROWCOUNT > 0
						SET @RowsChanged = 1;
					
					--typy struktury
					ENABLE TRIGGER [WartoscZmiany_JednostkiMiary_UPDATE] ON dbo.[JednostkiMiary];
					DISABLE TRIGGER [WartoscZmiany_TypStruktura_Obiekt_UPDATE] ON dbo.[TypStruktury_Obiekt];

					UPDATE dbo.[TypStruktury_Obiekt] SET
						IsBlocked = @Block;
						
					IF @@ROWCOUNT > 0
						SET @RowsChanged = 1;
					
					--struktury
					ENABLE TRIGGER [WartoscZmiany_TypStruktura_Obiekt_UPDATE] ON dbo.[TypStruktury_Obiekt];
					DISABLE TRIGGER [WartoscZmiany_Struktura_Obiekt_UPDATE] ON dbo.[Struktura_Obiekt];	

					UPDATE dbo.[Struktura_Obiekt] SET
						IsBlocked = @Block;
						
					IF @@ROWCOUNT > 0
						SET @RowsChanged = 1;

					ENABLE TRIGGER [WartoscZmiany_Struktura_Obiekt_UPDATE] ON dbo.[Struktura_Obiekt];				
	
					COMMIT TRAN T1_Database_BlockTypes

				END
				ELSE
					EXEC [THB].[GetErrorMessage] @Nazwa = N'OPERATION_FORBIDDEN', @Grupa = N'PROC_RESULT', @Val1 = @UzytkownikID, @Val2 = N'Database_BlockTypes', @Wiadomosc = @ERRMSG OUTPUT
			END
			ELSE
				EXEC [THB].[GetErrorMessage] @Nazwa = N'WRONG_REQUEST_TYPE', @Grupa = N'PROC_RESULT', @Val1 = N'Database_BlockTypes', @Wiadomosc = @ERRMSG OUTPUT
		END
			
	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
		
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN T1_UnitTypes_Save
		END
	END CATCH 
	
	--przygotowanie XMLa wyjsciowego		
	SET @XMLDataOut = '<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Database_BlockTypes"';
	
	IF @DataProgramu IS NOT NULL
		SET @XMLDataOut += ' AppDate="' + CONVERT(nvarchar(20), @DataProgramu, 23) + '"';
		
	SET @XMLDataOut += '>';
		
	IF @ERRMSG IS NULL OR @ERRMSG = '' 	
	BEGIN
		IF @RowsChanged = 1
			SET @XMLDataOut += '<Result><Value>true</Value></Result>';
		ELSE
			SET @XMLDataOut += '<Result><Value/></Result>';
	END
	ELSE
	BEGIN
		SET @XMLDataOut += '<Result><Error ErrorMessage="' + [THB].[PrepareErrorMessage](@ERRMSG) + '">'		
		SET @XMLDataOut += '</Error></Result>';
	END		
	
	SET @XMLDataOut += '</Response>';
	
	--zapis do logow
	EXEC [THB].[Logs_Save]
		@XMLDataIn = @XMLDataIn,
		@XmlDataOut = @XMLDataOut	
			
END
