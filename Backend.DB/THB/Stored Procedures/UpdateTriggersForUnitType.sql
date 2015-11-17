-- DK
-- Last modified on: 2013-03-01
CREATE PROCEDURE [THB].[UpdateTriggersForUnitType]
(
	@OldName nvarchar(500),
	@NewName nvarchar(500),
	@UnitTypeId int
)
AS 
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @str nvarchar(MAX) = '',
		@CzyHistoria bit = 0,
		@CzyTabela bit = 0
	
--	BEGIN TRY

		SELECT @CzyTabela = Tabela, @CzyHistoria = CzyPrzechowujeHistorie
		FROM dbo.TypObiektu
		WHERE TypObiekt_ID = @UnitTypeId;		
		
		--zmiana nazw kluczy
		DECLARE @OldTableName nvarchar(600) = '_' + @OldName,
			@NewTableName nvarchar(600) = '_' + @NewName,
			@CurrentConstraintName nvarchar(600),
			@NewConstraintName nvarchar(600),
			@Prefix nvarchar(600),
			@FullTableName nvarchar(650)	
				
		--zmiana kluczy w tabeli z danymi jesli istnieje
		--IF OBJECT_ID (@OldTableName, N'U') IS NOT NULL
		BEGIN
			SET @Prefix = 'dbo.[' + @NewTableName + '].';
			
			--zmiana nazw kluczy i indeksow
			SET @CurrentConstraintName = 'PK2' + @OldTableName
			SET @NewConstraintName = 'PK2' + @NewTableName
			
			EXEC sp_rename @CurrentConstraintName, @NewConstraintName		
			
			SET @CurrentConstraintName = 'FK' + @OldTableName + '_IdArch';
			SET @NewConstraintName = 'FK' + @NewTableName + '_IdArch';
			
			EXEC sp_rename @CurrentConstraintName, @NewConstraintName
			
			SET @CurrentConstraintName = 'FK' + @OldTableName + '_IdArchLink';
			SET @NewConstraintName = 'FK' + @NewTableName + '_IdArchLink';
			
			EXEC sp_rename @CurrentConstraintName, @NewConstraintName
			
			SET @CurrentConstraintName = @Prefix + '[PK' + @OldTableName + ']'
			SET @NewConstraintName = 'PK' + @NewTableName
			
			EXEC sp_rename @CurrentConstraintName, @NewConstraintName, 'INDEX';
		END
		
		--tabele z cechami
		SET @OldTableName = '_' + @OldName + '_Cechy_Hist';
		SET @NewTableName = '_' + @NewName + '_Cechy_Hist';
		SET @Prefix = 'dbo.[' + @NewTableName + '].';
		
		--IF OBJECT_ID (@OldTableName, N'U') IS NOT NULL
		BEGIN
			--zmiana nazw kluczy i indeksow
			SET @CurrentConstraintName = 'PK2' + @OldTableName
			SET @NewConstraintName = 'PK2' + @NewTableName
			
			EXEC sp_rename @CurrentConstraintName, @NewConstraintName
			
			SET @CurrentConstraintName = 'FK' + @OldTableName + '_IdArch';
			SET @NewConstraintName = 'FK' + @NewTableName + '_IdArch';
			
			EXEC sp_rename @CurrentConstraintName, @NewConstraintName
			
			SET @CurrentConstraintName = 'FK' + @OldTableName + '_IdArchLink';
			SET @NewConstraintName = 'FK' + @NewTableName + '_IdArchLink';
			
			EXEC sp_rename @CurrentConstraintName, @NewConstraintName
			
			--TODO kolejne kolumny: CechaId, ObiektId, CalculatedByAlgorithm
			SET @FullTableName = 'dbo.[' + @NewTableName + ']';
			SET @CurrentConstraintName = 'FK' + @OldTableName + '_CechaId';
			SET @NewConstraintName = 'FK' + @NewTableName + '_CechaId';
			
			--wykonanie polecenia jesli dany klucz istnieje
			IF EXISTS (SELECT name FROM sys.foreign_keys WHERE name = @CurrentConstraintName AND parent_object_id = OBJECT_ID(@FullTableName))
			BEGIN
				EXEC sp_rename @CurrentConstraintName, @NewConstraintName
			END
			
			SET @CurrentConstraintName = 'FK' + @OldTableName + '_ObiektId';
			SET @NewConstraintName = 'FK' + @NewTableName + '_ObiektId';
			
			--wykonanie polecenia jesli dany klucz istnieje
			IF EXISTS (SELECT name FROM sys.foreign_keys WHERE name = @CurrentConstraintName AND parent_object_id = OBJECT_ID(@FullTableName))
			BEGIN
				EXEC sp_rename @CurrentConstraintName, @NewConstraintName
			END
				
			SET @CurrentConstraintName = 'FK' + @OldTableName + '_CalculatedByAlgorithm';
			SET @NewConstraintName = 'FK' + @NewTableName + '_CalculatedByAlgorithm';
			
			--wykonanie polecenia jesli dany klucz istnieje
			IF EXISTS (SELECT name FROM sys.foreign_keys WHERE name = @CurrentConstraintName AND parent_object_id = OBJECT_ID(@FullTableName))
			BEGIN
				EXEC sp_rename @CurrentConstraintName, @NewConstraintName
			END			
			
			SET @CurrentConstraintName = @Prefix + '[PK' + @OldTableName + ']'
			SET @NewConstraintName = 'PK' + @NewTableName
			
			EXEC sp_rename @CurrentConstraintName, @NewConstraintName, 'INDEX';
		END	
		
		
	
		SET @str = 'IF (SELECT name FROM sys.triggers WHERE name = ''WartoscZmiany_' + @OldName + '_UPDATE'') IS NOT NULL
						DROP TRIGGER [dbo].[WartoscZmiany_' + @OldName + '_UPDATE];
					
					IF (SELECT name FROM sys.triggers WHERE name = ''WartoscZmiany_' + @OldName + '_INSERT'') IS NOT NULL
						DROP TRIGGER [dbo].[WartoscZmiany_' + @OldName + '_INSERT];'			
		
		--PRINT @str;
		EXEC(@str);
		
		SET @str='CREATE TRIGGER [dbo].[WartoscZmiany_' + @NewName + '_UPDATE]
				   ON  [dbo].[_' + @NewName + '] 
				   AFTER UPDATE
				AS 
				BEGIN
					SET NOCOUNT ON;
					
					--IF(UPDATE(IsDeleted)) RETURN;

					DECLARE @ID int, @Nazwa nvarchar(64), @WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int, @Wersja int
					,@ObowiazujeOd datetime, @ObowiazujeDo datetime, @WaznyOdNEW datetime, @UtworzonyPrzezNEW int, @CzyWaznyNEW bit
					,@NazwaNEW nvarchar(64), @DataModyfikacjiApp datetime, @RealCreatedOn datetime, @RealLastModifiedOn datetime, @hist int
					,@IsStatus bit, @StatusS int, @StatusW int, @StatusP int, @StatusSBy int, @StatusPBy int, @StatusWBy int 
					,@StatusSFrom datetime, @StatusPFrom datetime, @StatusWFrom datetime	

					DECLARE cur_TypObiektuInst_UPDATE CURSOR FOR
						SELECT Id, Nazwa, ValidFrom, CreatedBy, IdArchLink, ObowiazujeOd, ObowiazujeDo,
							IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom
						FROM deleted
					OPEN cur_TypObiektuInst_UPDATE 
					FETCH NEXT FROM cur_TypObiektuInst_UPDATE INTO @ID, @Nazwa, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo,
						@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
					WHILE @@fetch_status = 0
					BEGIN
					
						SELECT @WaznyodNEW = ValidFrom, @CzyWaznyNEW = IsValid, @UtworzonyPrzezNEW = LastModifiedBy, @NazwaNEW = Nazwa,
							@DataModyfikacjiApp = LastModifiedOn, @RealCreatedOn = RealCreatedOn, @RealLastModifiedOn = RealLastModifiedOn
						FROM inserted WHERE ID = @ID
					
						IF @CzyWaznyNEW = 1 --AND NOT UPDATE(IsAlternativeHistory))
						BEGIN
							
							INSERT INTO [dbo].[_' + @NewName + ']
							   ([IdArch], IdArchLink, Nazwa, [IsValid], [ValidFrom], [ValidTo], [CreatedOn], [CreatedBy], [LastModifiedOn], [LastModifiedBy], 
							   ObowiazujeOD, ObowiazujeDo, RealCreatedOn, RealLastModifiedOn,
							   IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, 
							   StatusWFrom, StatusSTo, StatusPTo, StatusWTo, StatusSToBy, StatusPToBy, StatusWToBy)
					   '
					   
					   SET @str += ' 
							SELECT @ID,ISNULL(@IdArchLink,@ID), @Nazwa, 0, @WaznyOd, @DataModyfikacjiApp, @WaznyOd, @UtworzonyPrzez, @DataModyfikacjiApp, @UtworzonyPrzezNEW, 
								@ObowiazujeOD, @ObowiazujeDo, @RealCreatedOn, @RealLastModifiedOn,
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
								END

							SELECT @hist = @@IDENTITY

							UPDATE [dbo].[_' + @NewName + ']
							SET ValidFrom = @DataModyfikacjiApp
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
					
							FETCH NEXT FROM cur_TypObiektuInst_UPDATE INTO @ID, @Nazwa, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo,
								@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
					END
					
					CLOSE cur_TypObiektuInst_UPDATE
					DEALLOCATE cur_TypObiektuInst_UPDATE	
				END	'
				
		--PRINT @str
		EXEC(@str)
		
		SET @str='	
			CREATE TRIGGER [dbo].[WartoscZmiany_' + @NewName + '_INSERT]
				   ON  [dbo].[_' + @NewName + '] 
				   AFTER INSERT
				AS 
				BEGIN
					declare @ID int, @Nazwa nvarchar(64)
					,@WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int, @Wersja int
					,@ZmianaOd datetime, @ZmianaDo datetime, @ObowiazujeOD datetime
					,@ObowiazujeDo datetime

					Declare @maxDt date = ''9999-12-31''
					
					select @ID = ID, @IdArchLink = IdArchLink
					FROM inserted

					IF (@IdArchLink IS NULL)
					BEGIN
						IF EXISTS(
							SELECT S1.Nazwa,
							  S1.ID AS key1, S1.ObowiazujeOd AS start1, S1.ObowiazujeDo AS end1,
							  S2.ID AS key2, S2.ObowiazujeOd AS start2, S2.ObowiazujeDo AS end2
							FROM inserted AS S1
							  JOIN [dbo].[_' + @NewName + '] AS S2
								ON  S2.Nazwa = S1.Nazwa
								AND (COALESCE(S2.ObowiazujeDo, @maxDt) >= COALESCE(S1.ObowiazujeOd, @maxDt)
									 AND COALESCE(S2.ObowiazujeOd, @maxDt) <= COALESCE(S1.ObowiazujeDo, @maxDt))
							WHERE S1.Id = @id AND S1.ID <> S2.ID
						)	
						BEGIN						
						
							UPDATE [dbo].[_' + @NewName + '] 
							SET IsAlternativeHistory=1
							, IsMainHistFlow=0
							WHERE Id = @id						
						END
					END
				END	'
						
			--PRINT @str
			--EXEC(@str);
			
			IF @CzyHistoria = 1 AND @CzyTabela = 0
			BEGIN
			
				SET @str = 'IF (SELECT name FROM sys.triggers WHERE name = ''WartoscZmiany_' + @OldName + '_Cechy_Hist_UPDATE'') IS NOT NULL
								DROP TRIGGER [dbo].[WartoscZmiany_' + @OldName + '_Cechy_Hist_UPDATE];
							
							IF (SELECT name FROM sys.triggers WHERE name = ''WartoscZmiany_' + @OldName + '_Cechy_Hist_INSERT'') IS NOT NULL	
								DROP TRIGGER [dbo].[WartoscZmiany_' + @OldName + '_Cechy_Hist_INSERT];'			

				--PRINT @str;
				EXEC(@str);
			
				SET @str='
CREATE TRIGGER [dbo].[WartoscZmiany_'+ @NewName +'_Cechy_Hist_UPDATE]
   ON  [dbo].[_' + @NewName + '_Cechy_Hist] 
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
						
	DECLARE @ID int, @ObiektID int, @CechaID int, @ValInt int, @ValString nvarchar(max), @ValFloat float, @ValBit bit, @ValDecimal decimal(12,5)
	,@ValDatetime datetime, @ValDate date, @ValTime time, @WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int
	,@ObowiazujeOd datetime, @ObowiazujeDo datetime, @UIOrder smallint, @Priority smallint
	,@VirtualTypeId smallint, @IsValidForAlgorithm bit, @CalculatedByAlgorithm smallint, @AlgorithmRun int
	,@WaznyOdNEW datetime, @UtworzonyPrzezNEW int, @CzyWaznyNEW bit, @ValIntNEW int, @ValStringNEW nvarchar(max), @ValFloatNEW float
	,@ValBitNEW bit, @ValDecimalNEW decimal(12,5), @ValDatetimeNEW datetime, @ValDateNEW date, @ValTimeNEW time
	,@DataModyfikacjiApp datetime, @RealCreatedOn datetime, @RealLastModifiedOn datetime, @hist int
	,@PrzedzialCzasowyId int, @Sledzona bit, @MinDate datetime, @MaxDate datetime, @OldLastModifiedOn datetime 
	,@IsStatus bit, @StatusS int, @StatusW int, @StatusP int, @StatusSBy int, @StatusPBy int, @StatusWBy int 
	,@StatusSFrom datetime, @StatusPFrom datetime, @StatusWFrom datetime, @StatusPCechy int, @NewObowiazujeDo datetime, @MinDateObowiazuje datetime, @MaxDateObowiazuje datetime
	,@IsAlternativeHistory bit, @IsMainHistFlow bit, @NewObowiazujeOd datetime, @NewIsMainHistFlow bit, @ValDictionary int, @ValXml xml, @ValRef xml,
	@CreatedOn datetime, @LastModifiedOn datetime, @ZmienionyPrzez int
	
	DECLARE cur_ObiektInst_Cechy_UPDATE CURSOR FOR
		SELECT ID, ObiektID, CechaID, ValInt, ValString, ValFloat, ValBit ,ValDecimal, ValDatetime, ValDate, ValTime, ValDictionary, ValXml, ValRef,
			ValidFrom, CreatedBy, IdArchLink, ObowiazujeOd, ObowiazujeDo, UIOrder, [Priority], VirtualTypeId, IsValidForAlgorithm,
			CalculatedByAlgorithm, AlgorithmRun, ISNULL(LastModifiedOn, CreatedOn), IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, 
			StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom, IsAlternativeHistory, IsMainHistFlow, CreatedOn, LastModifiedOn, LastModifiedBy
		FROM deleted
	OPEN cur_ObiektInst_Cechy_UPDATE	
	FETCH NEXT FROM cur_ObiektInst_Cechy_UPDATE INTO @ID, @ObiektID, @CechaID, @ValInt, @ValString, @ValFloat, @ValBit, @ValDecimal, @ValDatetime, @ValDate, @ValTime, 
		@ValDictionary, @ValXml, @ValRef, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo, 
		@UIOrder, @Priority, @VirtualTypeId, @IsValidForAlgorithm, @CalculatedByAlgorithm, @AlgorithmRun, @OldLastModifiedOn,
		@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, @IsAlternativeHistory, @IsMainHistFlow, @CreatedOn, @LastModifiedOn, @ZmienionyPrzez
	WHILE @@fetch_status = 0
	BEGIN
	
		SELECT @WaznyodNEW = ValidFrom, @CzyWaznyNEW = IsValid, @UtworzonyPrzezNEW = LastModifiedBy, @NewObowiazujeOd = ObowiazujeOd, @NewIsMainHistFlow = IsMainHistFlow,
			@DataModyfikacjiApp = LastModifiedOn, @RealCreatedOn = RealCreatedOn, @RealLastModifiedOn = RealLastModifiedOn, @NewObowiazujeDo = ObowiazujeDo
		FROM inserted WHERE ID = @ID
		
		--pobranie przedzialu czasowego z danych cechy oraz jej charakteru chwilowego
		SELECT @PrzedzialCzasowyId = PrzedzialCzasowyId, @Sledzona = Sledzona, @StatusPCechy = StatusP
		FROM Cechy
		WHERE Cecha_ID = @CechaID;
	
		IF @CzyWaznyNEW = 1
		BEGIN'
	
		SET @str += '						
			--okreslamy granice przedzialu tylko jesli ustawiono typ przedzialu dla cechy
			IF @PrzedzialCzasowyId IS NOT NULL
			BEGIN
				--pobranie przedzialu czasowego dla przedzialu czasowego modyfikowanego typu cechy i daty aplikacji
				EXEC [THB].[PrepareTimePeriods]
					@AppDate = @DataModyfikacjiApp,
					@TimeIntervalId = @PrzedzialCzasowyId,
					@MinDate = @MinDate OUTPUT,
					@MaxDate = @MaxDate OUTPUT
			END
			ELSE
			BEGIN
				--brak jednostki czasu wiec zapisujemy kazda zmiane
				SET @Sledzona = 1;
			END
			
			--jesli ma byc zapisywana kazda zmiana wartosci cechy (charakter chwilowy) lub wartosc nie miesci sie w podanym przedziale czasowym
			IF @NewIsMainHistFlow <> @IsMainHistFlow OR @ObowiazujeOd <> @NewObowiazujeOd OR @Sledzona = 1 OR @StatusPCechy >= 5 
				OR @OldLastModifiedOn < @MinDate OR @OldLastModifiedOn > @MaxDate
			BEGIN
			
				--EXEC [THB].[PrepareTimeForPrevPeriod]
				--	@AppDate = @DataModyfikacjiApp,
				--	@TimeIntervalId = @PrzedzialCzasowyId,
				--	@MinDate = @MinDateObowiazuje OUTPUT,
				--	@MaxDate = @MaxDateObowiazuje OUTPUT
					
				--kolumna narazie nie uzywana	
				SET @MaxDateObowiazuje = NULL
				
				--podmiana wartosci daty ostatniej modyfikacji i osoby modyfikujacej
				IF @Sledzona = 1
				BEGIN
					SET @LastModifiedOn = @DataModyfikacjiApp;
					SET @ZmienionyPrzez = @UtworzonyPrzezNEW;
				END							
			
				INSERT INTO [dbo].[_' + @NewName + '_Cechy_Hist]
				   ([IdArch], IdArchLink, [ObiektId], [CechaID], [ValInt], [ValString], [ValFloat], [ValBit], [ValDecimal], [ValDatetime], [ValDate], [ValTime], [ValDictionary], [ValXml], [ValRef]
				   ,[IsValid], [ValidFrom], [ValidTo], [CreatedOn], [CreatedBy], [LastModifiedOn], [LastModifiedBy], ObowiazujeOd, ObowiazujeDo, 
				   UIOrder, [Priority], VirtualTypeId, IsValidForAlgorithm, CalculatedByAlgorithm, AlgorithmRun,
				   RealCreatedOn, RealLastModifiedOn, IsAlternativeHistory, IsMainHistFlow, IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, 
				   StatusWFrom, StatusSTo, StatusPTo, StatusWTo, StatusSToBy, StatusPToBy, StatusWToBy)';
		    
		SET @str += '
				SELECT @Id, ISNULL(@IdArchLink, @ID), @ObiektID, @CechaID, @ValInt, @ValString, @ValFloat, @ValBit, @ValDecimal, @ValDatetime, @ValDate, @ValTime, @ValDictionary, @ValXml, @ValRef 
					, 0, @WaznyOd, @WaznyodNEW, @CreatedOn, @UtworzonyPrzez, @LastModifiedOn, @ZmienionyPrzez, @ObowiazujeOd, @MaxDateObowiazuje, --@ObowiazujeOd, @ObowiazujeDo, 
					@UIOrder, @Priority, @VirtualTypeId, @IsValidForAlgorithm, @CalculatedByAlgorithm, @AlgorithmRun,
					@RealCreatedOn, @RealLastModifiedOn, @IsAlternativeHistory, @IsMainHistFlow, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom,
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
					END 

				SELECT @hist = @@IDENTITY								
	
				UPDATE [dbo].[_' + @NewName + '_Cechy_Hist]
				SET ValidFrom = @WaznyodNEW
				,[CreatedBy] = @UtworzonyPrzezNEW
				--,[ObowiazujeOd] = @MinDate
				--,[ObowiazujeDo] = @NewObowiazujeDo
				,LastModifiedOn = NULL
				,LastModifiedBy = NULL
				,CreatedOn = ISNULL(@DataModyfikacjiApp, @WaznyodNEW)
				,RealCreatedOn = ISNULL(@RealLastModifiedOn, @RealCreatedOn)
				,RealDeletedFrom = NULL
				,RealLastModifiedOn = NULL
				,IdArchLink = @hist
				,IdArch = NULL
				WHERE ID = @ID'
				
		SET @str += '
			END
			ELSE IF (@ObowiazujeOd = @NewObowiazujeOd AND @OldLastModifiedOn >= @MinDate AND @OldLastModifiedOn <= @MaxDate) --zapis cech na podstawie przedzialow czasowych
			BEGIN
									
				--sprawdzenie czy data ostatniej modyfikacji miesci sie w przedziale czasowym wg nowej daty modyfikacji, jesli tak to tylko update rekordu
				--bez tworzenia wpisow historycznych
				UPDATE [dbo].[_' + @NewName + '_Cechy_Hist]
				SET ValidFrom = @DataModyfikacjiApp
				,[CreatedBy] = @UtworzonyPrzezNEW
				WHERE ID = @ID
			
			END
		END
	
		FETCH NEXT FROM cur_ObiektInst_Cechy_UPDATE INTO @ID, @ObiektID, @CechaID, @ValInt, @ValString, @ValFloat, @ValBit, @ValDecimal, @ValDatetime, @ValDate, @ValTime, 
			@ValDictionary, @ValXml, @ValRef, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo, 
			@UIOrder, @Priority, @VirtualTypeId, @IsValidForAlgorithm, @CalculatedByAlgorithm, @AlgorithmRun, @OldLastModifiedOn,
			@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, @IsAlternativeHistory, @IsMainHistFlow, @CreatedOn, @LastModifiedOn, @ZmienionyPrzez
	END
	
	CLOSE cur_ObiektInst_Cechy_UPDATE
	DEALLOCATE cur_ObiektInst_Cechy_UPDATE	
END	'
				
				--PRINT @str
				EXEC(@str)
			
			
				SET @str = 'IF (SELECT name FROM sys.triggers WHERE name = ''WartoscZmiany_' + @OldName + '_Relacje_Hist_UPDATE'') IS NOT NULL
								DROP TRIGGER [dbo].[WartoscZmiany_' + @OldName + '_Relacje_Hist_UPDATE];
					
							IF (SELECT name FROM sys.triggers WHERE name = ''WartoscZmiany_' + @OldName + '_Relacje_Hist_INSERT'') IS NOT NULL
								DROP TRIGGER [dbo].[WartoscZmiany_' + @OldName + '_Relacje_Hist_INSERT];'			

				--PRINT @str;
				EXEC(@str);
				
				SET @str='			
					CREATE TRIGGER [dbo].[WartoscZmiany_'+ @NewName +'_Relacje_Hist_UPDATE]
					   ON  [dbo].[_'+ @NewName +'_Relacje_Hist] 
					   AFTER UPDATE
					AS 
					BEGIN
						SET NOCOUNT ON;

						declare @ID int, @ObiektID int, @CechaID int, @ValInt int
							,@ValString nvarchar(max), @ValFloat float
							,@ValBit bit, @ValDecimal decimal(12,5)
							,@ValDatetime datetime, @ValDate date, @ValTime time
							,@WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int
							,@ZmianaOd datetime, @ZmianaDo datetime, @ObowiazujeOD datetime
							,@ObowiazujeDo datetime, @RelacjaId int

						declare @WaznyOdNEW datetime, @UtworzonyPrzezNEW int, @CzyWaznyNEW bit
							,@ValIntNEW int
							,@ValStringNEW nvarchar(max), @ValFloatNEW float
							,@ValBitNEW bit, @ValDecimalNEW decimal(12,5)
							,@ValDatetimeNEW datetime, @ValDateNEW date, @ValTimeNEW time					

						declare cur cursor for
							select ID, ObiektID, CechaID, ValInt, ValString, ValFloat, ValBit, ValDecimal 
								,ValDatetime, ValDate, ValTime, ValidFrom , CreatedBy, IdArchLink
								, ObowiazujeOD, ObowiazujeDo, RelacjaId 
							FROM deleted
						open cur 
						fetch next from cur into @ID, @ObiektID, @CechaID, @ValInt, @ValString, @ValFloat 
							,@ValBit, @ValDecimal, @ValDatetime, @ValDate, @ValTime, @WaznyOd, @UtworzonyPrzez, @IdArchLink
							, @ObowiazujeOD, @ObowiazujeDo, @RelacjaId
						while @@fetch_status=0
						begin
						
							SELECT @WaznyodNEW = ValidFrom, @CzyWaznyNEW = IsValid, @UtworzonyPrzezNEW = LastModifiedBy
							FROM inserted WHERE ID=@ID
							
							declare @hist int
						
							IF @CzyWaznyNEW=1 --AND NOT UPDATE(IsAlternativeHistory))
							BEGIN
								
								INSERT INTO [dbo].[_' + @NewName + '_Relacje_Hist]
								   ([IdArch], IdArchLink,[ObiektId],[CechaID], [ValInt], [ValString], [ValFloat]
								   ,[ValBit], [ValDecimal],[ValDatetime], [ValDate], [ValTime] ,[IsValid], [ValidFrom], [ValidTo], [CreatedOn], [CreatedBy]
								   ,[LastModifiedOn], [LastModifiedBy], ObowiazujeOD, ObowiazujeDo, RelacjaId)
						    
								SELECT @ID,ISNULL(@IdArchLink,@ID), @ObiektID, @CechaID, @ValInt 
									,@ValString, @ValFloat, @ValBit, @ValDecimal, @ValDatetime, @ValDate, @ValTime 
									,0, @WaznyOd,GETDATE(), @WaznyOd, @UtworzonyPrzez, GETDATE(), @UtworzonyPrzezNEW
									, @ObowiazujeOD, @ObowiazujeDo, @RelacjaId

								SELECT @hist = @@IDENTITY

								UPDATE [dbo].[_' + @NewName + '_Relacje_Hist]
								SET ValidFrom = GETDATE()
								,[CreatedBy] = @UtworzonyPrzezNEW
								,LastModifiedOn = NULL
								,LastModifiedBy = NULL
								,CreatedOn = GETDATE()
								,IdArchLink = @hist
								,IdArch = NULL
								WHERE ID = @ID
							END
						
							fetch next from cur into @ID, @ObiektID, @CechaID, @ValInt, @ValString, @ValFloat 
								,@ValBit, @ValDecimal, @ValDatetime, @ValDate, @ValTime, @WaznyOd, @UtworzonyPrzez, @IdArchLink
								, @ObowiazujeOD, @ObowiazujeDo, @RelacjaId
						END						
						CLOSE cur
						DEALLOCATE cur	
					END
				END	'
				
				--PRINT @str;
				IF OBJECT_ID('[_' + @NewName + '_Relacje_Hist]') IS NOT NULL
					EXEC(@str)
				
				SET @str='		
					CREATE TRIGGER [dbo].[WartoscZmiany_'+ @NewName +'_Relacje_Hist_INSERT]
					   ON  [dbo].[_'+ @NewName +'_Relacje_Hist] 
					   AFTER INSERT
					AS 
					BEGIN
						declare @ID int, @Nazwa nvarchar(64)
						,@WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int, @Wersja int
						,@ZmianaOd datetime, @ZmianaDo datetime, @ObowiazujeOD datetime
						,@ObowiazujeDo datetime

						Declare @maxDt date = ''9999-12-31''
						
						select @ID = ID , @IdArchLink = IdArchLink
						FROM inserted

						IF (@IdArchLink IS NULL)
						BEGIN
							IF EXISTS(
								SELECT S1.ObiektID,S1.CechaID,
								  S1.ID AS key1, S1.ObowiazujeOd AS start1, S1.ObowiazujeDo AS end1,
								  S2.ID AS key2, S2.ObowiazujeOd AS start2, S2.ObowiazujeDo AS end2
								FROM inserted AS S1
								  JOIN [dbo].[_'+ @NewName +'_Relacje_Hist]   AS S2
									ON  S1.ObiektID = S2.ObiektID
									AND S1.CechaID = S2.CechaID
									AND (COALESCE(S2.ObowiazujeDo,@maxDt) >= COALESCE(S1.ObowiazujeOd,@maxDt)
										 AND COALESCE(S2.ObowiazujeOd, @maxDt) <= COALESCE(S1.ObowiazujeDo,@maxDt))
								WHERE S1.Id = @id AND S1.ID <> S2.ID
							)	
							BEGIN						
						
								UPDATE [dbo].[_'+ @NewName +'_Relacje_Hist] 
								SET IsAlternativeHistory=1
								, IsMainHistFlow=0
								WHERE Id=@id
							
							END
						END
					END
				END	'
				
				--PRINT @str
			--	EXEC(@str)				
			
			END
			
		--END TRY
		--BEGIN CATCH
		--	PRINT 'UpdateTrigersForUnitTypesError: ' + ERROR_MESSAGE();
		--END CATCH
END


