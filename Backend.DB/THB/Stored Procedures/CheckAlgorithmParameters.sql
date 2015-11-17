-- =============================================
-- Author:		DK
-- Create date: 2012-07-24
-- Description:	Weryfikuje dane na podstawie podanych parametrow do procedury
-- =============================================
CREATE PROCEDURE [THB].[CheckAlgorithmParameters]
(
	@BranzaId int,
	@IdStruktury int,
	@IdCechaC1 int = NULL, -- cecha zbierana
	@IdCechaC3 int = NULL, -- cecha wagowa
	@CheckCechaC1 bit = 1,
	@CheckCechaC3 bit = 0,
	@DataStart date,
	@DataEnd date, 
	@ERRMSG nvarchar(MAX) OUTPUT,
	@Success bit OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Query nvarchar(MAX) = '',
		@RootIsValid bit = 0,
		@ModelIsValid bit = 0,
		@BranchIsOk bit = 0,
		@RootObiektId int,
		@RootTypObiektuId int

	BEGIN TRY
	
		SET @ERRMSG = NULL;
		SET @Success = 1;
		
				
		IF @CheckCechaC1 = 1 AND (@IdCechaC1 IS NULL OR @IdCechaC1 < 1)
		BEGIN
			SET @ERRMSG = 'Nieprawidłowe dane uruchomieniowe (nie podano danych cechy C1 - zbieranej).';
			SET @Success = 0;
			RETURN;
		END
		
		IF @CheckCechaC3 = 1 AND (@IdCechaC3 IS NULL OR @IdCechaC3 < 1)
		BEGIN
			SET @ERRMSG = 'Nieprawidłowe dane uruchomieniowe (nie podano danych cechy C3 - wagowej).';
			SET @Success = 0;
			RETURN;
		END								

		--weryfikacja podanego zakresu dat
		IF @DataStart IS NOT NULL AND @DataEnd IS NOT NULL AND @DataEnd < @DataStart
		BEGIN
			SET @ERRMSG = 'Nieprawidłowe dane uruchomieniowe (podano nieprawidłowy zakres dat).';
			SET @Success = 0;
			RETURN;
		END
					
		--sprawdzenie czy podano tylko jedna date z 2
		IF (@DataStart IS NOT NULL AND @DataEnd IS NULL) OR (@DataEnd IS NOT NULL AND @DataStart IS NULL)
		BEGIN
			SET @ERRMSG = 'Nieprawidłowe dane uruchomieniowe (podano datę tylko dla jednego końca okresu: datę początkową lub końcową).';
			SET @Success = 0;
			RETURN;
		END
					
		--weryfikacja poprawnosci branzy
		IF @BranzaId IS NOT NULL
		BEGIN
			SET @Query = 'IF EXISTS (SELECT Id FROM Branze WHERE Id = ' + CAST(@BranzaId AS varchar) + '
				AND (ValidFrom <= ''' + CONVERT(varchar, @DataStart, 112) + ' 23:59:59'' AND (ValidTo IS NULL OR ValidTo >= ''' + CONVERT(varchar, @DataEnd, 112) + ' 00:00:00'' )))
				SET @BranchIsOkTmp = 1';
			
			--PRINT @Query
			EXECUTE sp_executesql @Query, N'@BranchIsOkTmp bit OUTPUT', @BranchIsOkTmp = @BranchIsOk OUTPUT;
			
			IF @BranchIsOk = 0
			BEGIN
				SET @ERRMSG = 'Nieprawidłowe dane uruchomieniowe (podana branża nie istnieje w podanym zakresie dat).';
				SET @Success = 0;
				RETURN;
			END
		END
	
		--weryfikacja czy podany wezel glowny istnieje
		EXEC [THB].[CheckStructureRootNode]
			@StructureId = @IdStruktury,
			@StartDate = @DataStart,
			@EndDate = @DataEnd,
			@Success = @RootIsValid OUTPUT

		IF @RootIsValid = 0
		BEGIN
			--EXEC [THB].[GetErrorMessage] @Nazwa = N'INVALID_ROOT', @Grupa = N'PROC_RESULT', @Wiadomosc = @Tmp_Error OUTPUT
			SET @ERRMSG = 'Nieprawidłowe dane uruchomieniowe (struktura o podanym Id jest nie prawidłowa w podanym zakresie dat lub nie istnieje).';
			SET @Success = 0;
			RETURN;
		END
		
		IF @CheckCechaC1 = 1 AND (SELECT COUNT(1) FROM TypObiektu_Cechy toc JOIN TypStruktury_Obiekt tso ON (toc.TypObiektu_ID = tso.TypObiektuIdRoot)
			JOIN Struktura_Obiekt so ON (tso.Id = so.TypStruktury_Obiekt_Id)
			WHERE so.Id = @IdStruktury AND toc.IdArch IS NULL AND [Priority] = 1 AND toc.IsValid = 1 AND toc.Cecha_ID = @IdCechaC1 AND toc.IsDeleted = 0) < 1  --(toc.Cecha_ID = @IdCechaZbierana OR toc.Cecha_Id = @IdCechaZbierajaca)
		BEGIN
			SET @ERRMSG = 'Nieprawidłowe dane uruchomieniowe (typ obiektu będący korzeniem struktury nie posiada powiązania z podanym typem cechy).';
			SET @Success = 0;
			RETURN;
		END
			
	END TRY
	BEGIN CATCH
		SET @ERRMSG = @@ERROR;
		SET @ERRMSG += ' ';
		SET @ERRMSG += ERROR_MESSAGE();
	END CATCH

END
