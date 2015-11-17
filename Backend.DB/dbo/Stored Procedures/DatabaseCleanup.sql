
-- =============================================
-- Author:		DW
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[DatabaseCleanup]
AS
BEGIN
	DELETE FROM [dbo].[Logi]
	DELETE FROM [dbo].[Slowniki]
	delete from [dbo].[Relacja_Cecha_Hist]
	DELETE FROM [dbo].[Struktura]
	delete from [dbo].[Struktura_Algorytmy]
	delete from [dbo].[Struktura_Obiekt]
	delete from [dbo].[TypObiektu_Relacje_Cechy]
	delete from [dbo].[TypObiektu_Relacje]
	delete from [dbo].[TypObiektu_Cechy]
	delete from [dbo].[Relacje]
	delete from [dbo].[TypRelacji]
	delete from [dbo].[Relacja_Typ]
	delete from [dbo].[TypRelacji_Cechy]
	delete from [dbo].[TypStruktury_Obiekt]
	delete from [dbo].[TypStruktury]
	delete from [dbo].[Branze_Cechy]
	delete from [dbo].[Alg_TypyRelacji]
	delete from [dbo].[Alg_ObiektyRelacje]
	delete from [dbo].[Alg_ObiektyCechy]
	delete from [dbo].[Alg_Cechy]
	delete from [dbo].[Alg_Obiekty]
	DELETE FROM [dbo].[Cechy]
	delete from [dbo].[TypObiektu]
	delete from [dbo].[Branze] WHERE [Id]>0


	EXEC dbo.Database_Identity_Reseed

END

