
-- =============================================
-- Author:		DK
-- Description:	Czysci tabele na dane tymczasowe uzywane przy wyliczaniu zuzycia.
-- =============================================
CREATE PROCEDURE [dbo].[ClearTempTables]
AS
BEGIN
	
	DELETE FROM dbo.Alg_ObiektyCechy;
	DELETE FROM dbo.Alg_ObiektyRelacje;
	DELETE FROM dbo.Alg_Obiekty;
	DELETE FROM dbo.Alg_Cechy;
	DELETE FROM dbo.Alg_TypyRelacji;
END