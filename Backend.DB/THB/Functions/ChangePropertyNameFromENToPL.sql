-- =============================================
-- Author:		DK
-- Description:	Zmienia nazwe propertisu podanego po angieslku na polska nazwe kolumny w bazie danych
-- =============================================
CREATE FUNCTION THB.ChangePropertyNameFromENToPL
(
	@PropertyName nvarchar(300)
)
RETURNS nvarchar(300)
AS
BEGIN
	DECLARE @Result nvarchar(300) = @PropertyName;

	--Zamiana angielskich nazw Propertisow na polkie nazwy kolumn w bazie
	SET @Result = REPLACE(@Result, 'FirstName', 'Imie');
	SET @Result = REPLACE(@Result, 'LastName', 'Nazwisko');
	SET @Result = REPLACE(@Result, 'Password', 'Haslo');
	SET @Result = REPLACE(@Result, 'IsActive', 'Aktywny');
	SET @Result = REPLACE(@Result, 'IsDomain', 'Domenowy');
	SET @Result = REPLACE(@Result, 'ShortName', 'NazwaSkrocona');
	SET @Result = REPLACE(@Result, 'SQLName', 'NazwaSQL');						
	SET @Result = REPLACE(@Result, 'UIName', 'Nazwa_UI');
	SET @Result = REPLACE(@Result, 'Name', 'Nazwa');
	SET @Result = REPLACE(@Result, 'Description', 'Opis');					
	SET @Result = REPLACE(@Result, 'TypeId', 'TypID');
	SET @Result = REPLACE(@Result, 'IsDictionary', 'CzySlownik');
	SET @Result = REPLACE(@Result, 'IsRequired', 'CzyWymagana');					
	SET @Result = REPLACE(@Result, 'IsEmpty', 'CzyPusta');
	SET @Result = REPLACE(@Result, 'IsQuantifiable', 'CzyWyliczana');
	SET @Result = REPLACE(@Result, 'IsProcessed', 'CzyPrzetwarzana');					
	SET @Result = REPLACE(@Result, 'IsFiltered', 'CzyFiltrowana');
	SET @Result = REPLACE(@Result, 'IsPersonalData', 'CzyJestDanaOsobowa');
	SET @Result = REPLACE(@Result, 'IsUserAttribute', 'CzyCechaUzytkownika');	
	SET @Result = REPLACE(@Result, 'ChangeFrom', 'ZmianaOd');					
	SET @Result = REPLACE(@Result, 'ChangeTo', 'ZmianaDo');
	SET @Result = REPLACE(@Result, 'EffectiveFrom', 'ObowiazujeOd');
	SET @Result = REPLACE(@Result, 'EffectiveTo', 'ObowiazujeDo');
	SET @Result = REPLACE(@Result, 'Comment', 'Uwagi');
	SET @Result = REPLACE(@Result, 'Version', 'Wersja');
	SET @Result = REPLACE(@Result, 'IsTable', 'Tabela');
	SET @Result = REPLACE(@Result, 'IsTraced', 'Sledzona');
	SET @Result = REPLACE(@Result, 'TimeIntervalId', 'PrzedzialCzasowyId');
	SET @Result = REPLACE(@Result, 'TemporaryValue', 'CharakterChwilowy');	
	
	SET @Result = REPLACE(@Result, 'DataTypeId', 'TypId');
	
	SET @Result = REPLACE(@Result, 'StructureTypeId', 'TypStruktury_Obiekt_Id');
	SET @Result = REPLACE(@Result, 'ObjectId', 'Obiekt_Id');
	
	RETURN @Result

END
