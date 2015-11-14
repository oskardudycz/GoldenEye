-- Last modified on: 2013-01-24
CREATE PROCEDURE [THB].[UpdateTriggersForDictionary]
(
	@OldName nvarchar(255),
	@NewName nvarchar(255)
)
AS 
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @str nvarchar(MAX) = '';
	
	BEGIN TRY
	
		SET @str = 'IF (SELECT name FROM sys.triggers WHERE name = ''WartoscZmiany_Slownik_' + @OldName + '_UPDATE'') IS NOT NULL		
						DROP TRIGGER [dbo].[WartoscZmiany_Slownik_' + @OldName + '_UPDATE];
					
					IF (SELECT name FROM sys.triggers WHERE name = ''WartoscZmiany_Slownik_' + @OldName + '_INSERT'') IS NOT NULL	
						DROP TRIGGER [dbo].[WartoscZmiany_Slownik_' + @OldName + '_INSERT];'			
		
		--PRINT @str;
		EXEC(@str);
		
		SET @str='			
				CREATE TRIGGER [dbo].[WartoscZmiany_Slownik_' + @NewName + '_UPDATE]
				   ON [dbo].[_Slownik_' + @NewName + '] 
				   AFTER UPDATE
				AS 
				BEGIN
					SET NOCOUNT ON;
					
					--IF(UPDATE(IsDeleted)) RETURN;

					DECLARE @ID int, @Nazwa nvarchar(200), @NazwaSkrocona nvarchar(50), @NazwaPelna nvarchar(200), @Uwagi nvarchar(MAX), @WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int
						,@ZmianaOd datetime, @ZmianaDo datetime, @ObowiazujeOD datetime, @ObowiazujeDo datetime, @TypId int, @WaznyOdNEW datetime, @UtworzonyPrzezNEW int, @CzyWaznyNEW bit
						,@hist int, @NazwaNEW nvarchar(64), @DataModyfikacjiApp datetime, @RealCreatedOn datetime, @RealLastModifiedOn datetime, @IsStatus bit, @StatusS int, @StatusW int 
						,@StatusP int, @StatusSBy int, @StatusPBy int, @StatusWBy int, @StatusSFrom datetime, @StatusPFrom datetime, @StatusWFrom datetime				

					DECLARE curSl_UPDATE CURSOR FOR
						SELECT ID, Nazwa, NazwaSkrocona, NazwaPelna, Uwagi, ValidFrom, CreatedBy, IdArchLink, ObowiazujeOd, ObowiazujeDo, TypId,
							IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom 
						FROM deleted
					OPEN curSl_UPDATE 
					FETCH NEXT FROM curSl_UPDATE INTO @ID, @Nazwa, @NazwaSkrocona, @NazwaPelna, @Uwagi, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOd, @ObowiazujeDo, @TypId,
						@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
					WHILE @@fetch_status = 0
					BEGIN
					
						SELECT @WaznyodNEW = ValidFrom, @CzyWaznyNEW = IsValid, @UtworzonyPrzezNEW = LastModifiedBy, @NazwaNEW = Nazwa,
						@DataModyfikacjiApp = LastModifiedOn, @RealCreatedOn = RealCreatedOn, @RealLastModifiedOn = RealLastModifiedOn
						FROM inserted WHERE ID = @ID
					
						IF(@CzyWaznyNEW = 1 AND NOT UPDATE(IsAlternativeHistory))
						BEGIN
							
							INSERT INTO [dbo].[_Slownik_' + @NewName + ']
							   ([IdArch],IdArchLink, Nazwa, NazwaSkrocona, NazwaPelna, Uwagi, [IsValid], [ValidFrom], [ValidTo], [CreatedOn], [CreatedBy], [LastModifiedOn], 
							   [LastModifiedBy], ObowiazujeOd, ObowiazujeDo, TypId, RealCreatedOn, RealLastModifiedOn,
							   IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom, StatusSTo, StatusPTo, StatusWTo, StatusSToBy, StatusPToBy, StatusWToBy)					    
							SELECT @ID,ISNULL(@IdArchLink,@ID), @Nazwa, @NazwaSkrocona, @NazwaPelna, @Uwagi, 0, @WaznyOd, @DataModyfikacjiApp, @WaznyOd, @UtworzonyPrzez  
								,@DataModyfikacjiApp, @UtworzonyPrzezNEW, @ObowiazujeOd, @ObowiazujeDo, @TypId, @RealCreatedOn, @RealLastModifiedOn,
								@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, 
								CASE
									WHEN @StatusSFrom IS NOT NULL THEN @DataModyfikacjiApp
									ELSE NULL
								END,
								CASE
									WHEN @StatusPFrom IS NOT NULL THEN @DataModyfikacjiApp
									ELSE NULL
								END,
								CASE
									WHEN @StatusWFrom IS NOT NULL THEN @DataModyfikacjiApp
									ELSE NULL
								END,
								CASE
									WHEN @StatusSFrom IS NOT NULL THEN @UtworzonyPrzezNEW
									ELSE NULL
								END,
								CASE
									WHEN @StatusPFrom IS NOT NULL THEN @UtworzonyPrzezNEW
									ELSE NULL
								END,
								CASE
									WHEN @StatusWFrom IS NOT NULL THEN @UtworzonyPrzezNEW
									ELSE NULL
								END'  

			SET @str += '
							SELECT @hist = @@IDENTITY

							UPDATE [dbo].[_Slownik_' + @NewName + ']
							SET ValidFrom = @WaznyOdNEW
							,[CreatedBy] = @UtworzonyPrzezNEW
							,LastModifiedOn = NULL
							,LastModifiedBy = NULL
							,CreatedOn = ISNULL(@DataModyfikacjiApp, @WaznyodNEW)
							,RealCreatedOn = ISNULL(@RealLastModifiedOn, @RealCreatedOn)
							,RealDeletedFrom = NULL
							,RealLastModifiedOn = NULL
							,IdArchLink = @hist
							,IdArch = NULL
							WHERE ID = @ID
						END
					
						FETCH NEXT FROM curSl_UPDATE into @ID, @Nazwa, @NazwaSkrocona, @NazwaPelna, @Uwagi, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOd, @ObowiazujeDo, @TypId,
							@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
					END
					
					CLOSE curSl_UPDATE
					DEALLOCATE curSl_UPDATE	
				END'
				
		--PRINT @str
		EXEC(@str)
		
		SET @str = 'CREATE TRIGGER [dbo].[WartoscZmiany_Slownik_'+ @NewName +'_INSERT]
				   ON  [dbo].[_Slownik_' + @NewName + '] 
				   AFTER INSERT
				AS 
				BEGIN
					declare @ID int, @Nazwa nvarchar(64)
					,@WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int
					,@ObowiazujeOD datetime, @ObowiazujeDo datetime

					Declare @maxDt date = ''9999-12-31''
					
					select @ID = ID , @IdArchLink = IdArchLink
					FROM inserted

					IF (@IdArchLink IS NULL)
					BEGIN
						IF EXISTS(
							SELECT S1.Nazwa,
							  S1.ID AS key1, S1.ObowiazujeOd AS start1, S1.ObowiazujeDo AS end1,
							  S2.ID AS key2, S2.ObowiazujeOd AS start2, S2.ObowiazujeDo AS end2
							FROM inserted AS S1
							  JOIN [dbo].[_Slownik_'+ @NewName +']  AS S2
								ON  S2.Nazwa = S1.Nazwa
								AND (COALESCE(S2.ObowiazujeDo,@maxDt) >= COALESCE(S1.ObowiazujeOd,@maxDt)
									 AND COALESCE(S2.ObowiazujeOd, @maxDt) <= COALESCE(S1.ObowiazujeDo,@maxDt))
							WHERE S1.Id = @id AND S1.ID <> S2.ID
						)	
						BEGIN						
						
							UPDATE [dbo].[_Slownik_'+ @NewName +'] SET 
							IsAlternativeHistory = 1
							, IsMainHistFlow = 0
							WHERE Id = @id
						
						END
					END
				END'
				
			--PRINT @str
			EXEC(@str)
		END TRY
		BEGIN CATCH
			SELECT ERROR_MESSAGE();
		END CATCH
END


