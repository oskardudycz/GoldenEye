-- =============================================
-- Author:		DW
-- Create date: 2012-02-06
-- Description:	Pobiera cechy, które moze zobaczyc dane cechy
-- =============================================
CREATE FUNCTION Uzytkownik_UprawnieniaCechy_Pobierz 
(	
	@UserID INT
)
RETURNS TABLE 
AS
RETURN 
(

		SELECT DISTINCT CechaId FROM Branze_Cechy BC
		WHERE BC.BranzaId IN(
			select Branza from RolaOperacja
			where Rola IN 
				(
					Select R.Rola 
					From RolaGrupaUzytkownikow R 
					WHERE R. GrupaUzytkownikow IN 
						(
							SELECT G.GrupaUzytkownikow 
							FROM GrupaUzytkownikowUzytkownik G		
							WHERE G.Uzytkownik  =@UserID
						)
				)	
			AND Operacja = (Select Id 
							from Operacje O 
							WHERE O.Nazwa='SELECT'
							AND IdArch IS NULL)	
			)
		AND BC.IdArch IS NULL


)
