-- =============================================
-- Author:		DK
-- Created on: 2012-06-07
-- Last modified on: 2012-10-26
-- Description:	Sprawdza czy uzytkownik posiada prawa do wykonania danej operacji
-- =============================================
CREATE PROCEDURE [THB].[CheckUserPermission]
(
	@Operation varchar(10),  --SAVE, DELETE, GET, CHANGE HISTORY
	@UserId int,
	@BranchId int,
	@Result bit OUTPUT
)
AS
BEGIN
	SET @Result = 0;
	
	DECLARE @Nazwa nvarchar(64) = '',
		@SimpleOperation bit = 1,
		@Operation1Txt nvarchar(20),
		@Operation2Txt nvarchar(20),
		@ComplexOperationHalfSuccess bit		
	
	SET @Operation = LOWER(@Operation);
	
	IF @Operation = 'save'
	BEGIN
		SET @SimpleOperation = 0;
		SET @Operation1Txt = 'insert';
		SET @Operation2Txt = 'update';
	END
	ELSE IF @Operation = 'get'
		SET @Operation1Txt = 'select'
	ELSE IF @Operation = 'delete'
		SET @Operation1Txt = 'delete'
	ELSE IF @Operation = 'change history'
		SET @Operation1Txt = 'change history'
	
	IF OBJECT_ID('tempdb..#OperacjeCheckUser') IS NOT NULL
		DROP TABLE #OperacjeCheckUser
		
	CREATE TABLE #OperacjeCheckUser(Id int, Nazwa nvarchar(50), Opis nvarchar(200));

	--wyciagniecie operacji do jakich ma dostep uzytkownik na podstawie roli
	
	--jesli uzytkownikn nazlezy do roli superadminow lub adminow
	IF EXISTS(SELECT rgu.Rola FROM RolaGrupaUzytkownikow rgu
		JOIN [Role] r ON (r.Id = rgu.Rola)
		JOIN GrupaUzytkownikowUzytkownik guu ON (guu.GrupaUzytkownikow = rgu.GrupaUzytkownikow)
		WHERE guu.Uzytkownik = @UserId AND r.Rank < 2) -- tylko administatorzy lub superadministratorzy
	BEGIN
		
		INSERT INTO #OperacjeCheckUser
		SELECT DISTINCT o.Id, o.Nazwa, o.Opis --, ro.Branza
		FROM dbo.[Operacje] o
		WHERE o.IdArch IS NULL AND o.IsValid = 1 AND o.IsDeleted = 0;
	END
	ELSE
	BEGIN	
		INSERT INTO #OperacjeCheckUser
		SELECT DISTINCT o.Id, o.Nazwa, o.Opis --, ro.Branza
		FROM Operacje o
		JOIN RolaOperacja ro ON (o.Id = ro.Operacja)
		JOIN RolaGrupaUzytkownikow rgu ON (rgu.Rola = ro.Rola)
		JOIN GrupaUzytkownikowUzytkownik guu ON (guu.GrupaUzytkownikow = rgu.GrupaUzytkownikow)
		WHERE guu.Uzytkownik = @UserId AND o.IdArch IS NULL AND o.IsValid = 1 AND o.IsDeleted = 0;  --AND ro.Branza = @BranchId
	END
	
--	SELECT @UserId, @BranchId
--	SELECT * FROM #OperacjeCheckUser
	
	--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
	IF Cursor_Status('local','cur') > 0 
	BEGIN
		 CLOSE cur
		 DEALLOCATE cur
	END

	DECLARE cur CURSOR LOCAL FOR 
		SELECT Nazwa FROM #OperacjeCheckUser
	OPEN cur
	FETCH NEXT FROM cur INTO @Nazwa
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--jesli usuniecie lub pobranie danych
		IF @SimpleOperation = 1
		BEGIN
			IF LOWER(@Nazwa) = @Operation1Txt
			BEGIN
				SET @Result = 1;
				RETURN;
			END
		END
		ELSE
		BEGIN
			--zapis danych
			IF LOWER(@Nazwa) = @Operation1Txt OR LOWER(@Nazwa) = @Operation2Txt
			BEGIN
				IF @ComplexOperationHalfSuccess = 1
				BEGIN				
					SET @Result = 1;
					RETURN;
				END
				ELSE
					SET @ComplexOperationHalfSuccess = 1;
			END
		END	
	
		FETCH NEXT FROM cur INTO @Nazwa
	END
	CLOSE cur
	DEALLOCATE cur
	
	IF OBJECT_ID('tempdb..#OperacjeCheckUser') IS NOT NULL
		DROP TABLE #OperacjeCheckUser

END