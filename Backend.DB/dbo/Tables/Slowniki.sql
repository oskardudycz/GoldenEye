CREATE TABLE [dbo].[Slowniki] (
    [Id]                     INT             IDENTITY (1, 1) NOT NULL,
    [IdArch]                 INT             NULL,
    [IdArchLink]             INT             NULL,
    [Nazwa]                  NVARCHAR (256)  NOT NULL,
    [CzyPrzechowujeHistorie] BIT             DEFAULT ((1)) NULL,
    [IsStatus]               BIT             CONSTRAINT [DF_Slowniki_Cechy_IsStatus] DEFAULT ((0)) NOT NULL,
    [StatusS]                INT SPARSE      NULL,
    [StatusSFrom]            DATETIME SPARSE NULL,
    [StatusSTo]              DATETIME SPARSE NULL,
    [StatusSFromBy]          INT SPARSE      NULL,
    [StatusSToBy]            INT SPARSE      NULL,
    [StatusW]                INT SPARSE      NULL,
    [StatusWFrom]            DATETIME SPARSE NULL,
    [StatusWTo]              DATETIME SPARSE NULL,
    [StatusWFromBy]          INT SPARSE      NULL,
    [StatusWToBy]            INT SPARSE      NULL,
    [StatusP]                INT SPARSE      NULL,
    [StatusPFrom]            DATETIME SPARSE NULL,
    [StatusPTo]              DATETIME SPARSE NULL,
    [StatusPFromBy]          INT SPARSE      NULL,
    [StatusPToBy]            INT SPARSE      NULL,
    [ObowiazujeOd]           DATETIME        NULL,
    [ObowiazujeDo]           DATETIME SPARSE NULL,
    [IsValid]                BIT             DEFAULT ((1)) NULL,
    [ValidFrom]              DATETIME        DEFAULT (getdate()) NOT NULL,
    [ValidTo]                DATETIME SPARSE NULL,
    [IsDeleted]              BIT             DEFAULT ((0)) NOT NULL,
    [DeletedFrom]            DATETIME SPARSE NULL,
    [DeletedBy]              INT SPARSE      NULL,
    [CreatedOn]              DATETIME        DEFAULT (getdate()) NOT NULL,
    [CreatedBy]              INT             NULL,
    [LastModifiedOn]         DATETIME SPARSE NULL,
    [LastModifiedBy]         INT SPARSE      NULL,
    [TypId]                  INT             DEFAULT ((5)) NOT NULL,
    [RealCreatedOn]          DATETIME        DEFAULT (getdate()) NOT NULL,
    [RealLastModifiedOn]     DATETIME SPARSE NULL,
    [RealDeletedFrom]        DATETIME SPARSE NULL,
    [IsBlocked]              BIT             CONSTRAINT [DF_Slowniki_IsBlocked] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Slowniki] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [CHK_Slowniki_Nazwa] CHECK ([Nazwa]<>'' AND charindex('.',[Nazwa])=(0)),
    FOREIGN KEY ([TypId]) REFERENCES [dbo].[Cecha_Typy] ([Id]),
    CONSTRAINT [FK_Slowniki_IdArch] FOREIGN KEY ([IdArch]) REFERENCES [dbo].[Slowniki] ([Id]),
    CONSTRAINT [FK_Slowniki_IdArchLink] FOREIGN KEY ([IdArchLink]) REFERENCES [dbo].[Slowniki] ([Id])
);


GO
CREATE TRIGGER [dbo].[CreateTableForSlownik]
   ON  [dbo].[Slowniki]
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @NowaNazwa NVARCHAR(256)
	SELECT @NowaNazwa =(SELECT TOP 1 Nazwa FROM INSERTED)
	
	DECLARE @CzyHistoria BIT = (SELECT TOP 1 CzyPrzechowujeHistorie FROM INSERTED)
	DECLARE @IdArch INT = (SELECT TOP 1 IdArch FROM inserted)	
	
	IF (@IdArch IS NULL)
	BEGIN		
		
		DECLARE @str nvarchar(max)
		SET @str = 'IF OBJECT_ID (N''[_Slownik_' + @NowaNazwa + ']'', N''U'') IS NULL
			BEGIN
				CREATE TABLE [dbo].[_Slownik_' + @NowaNazwa + '](
					Id INT IDENTITY (1,1), -- PRIMARY KEY CLUSTERED,
					[IdArch] [int] NULL, -- FOREIGN KEY REFERENCES [_Slownik_' + @NowaNazwa + '](Id),
					[IdArchLink] [int] NULL, -- FOREIGN KEY REFERENCES [_Slownik_' + @NowaNazwa + '](Id),
					[Nazwa] nvarchar(200) NOT NULL,
					[NazwaSkrocona] nvarchar(50) NULL,
					[NazwaPelna] nvarchar(200) NULL,
					[Uwagi] nvarchar(MAX) NULL,
					[TypId] int NOT NULL,
					[IsAlternativeHistory] [bit] DEFAULT(0),
					[IsMainHistFlow] [bit] DEFAULT(1),
					[IsStatus] [bit] NOT NULL DEFAULT (0),
					[StatusS] [int] SPARSE NULL,
					[StatusSFrom] [datetime] SPARSE NULL,
					[StatusSTo] [datetime] SPARSE NULL,
					[StatusSFromBy] [int] SPARSE NULL,
					[StatusSToBy] [int] SPARSE NULL,
					[StatusW] [int] SPARSE NULL,
					[StatusWFrom] [datetime] SPARSE NULL,
					[StatusWTo] [datetime] SPARSE NULL,
					[StatusWFromBy] [int] SPARSE NULL,
					[StatusWToBy] [int] SPARSE NULL,
					[StatusP] [int] SPARSE NULL,
					[StatusPFrom] [datetime] SPARSE NULL,
					[StatusPTo] [datetime] SPARSE NULL,
					[StatusPFromBy] [int] SPARSE NULL,
					[StatusPToBy] [int] SPARSE NULL,
					[ObowiazujeOd] [datetime] NULL,
					[ObowiazujeDo] [datetime] SPARSE NULL,
					[IsValid] [bit] NOT NULL DEFAULT(1),
					[ValidFrom] [datetime] NOT NULL DEFAULT(GETDATE()),
					[ValidTo] [datetime] SPARSE NULL,
					[IsDeleted] [bit] NOT NULL DEFAULT (0),
					[DeletedFrom] [datetime] SPARSE NULL,
					[DeletedBy] [int] SPARSE NULL,
					[CreatedOn] [datetime] NOT NULL DEFAULT(GETDATE()),
					[CreatedBy] [int] NULL,
					[LastModifiedOn] [datetime] SPARSE NULL,
					[LastModifiedBy] [int] SPARSE NULL,
					[RealCreatedOn] datetime NOT NULL DEFAULT(GETDATE()),
					[RealLastModifiedOn] datetime SPARSE NULL,
					[RealDeletedFrom] datetime SPARSE NULL					
					);
				
				CREATE CLUSTERED INDEX [PK_Slownik_' + @NowaNazwa + '] ON [dbo].[_Slownik_' + @NowaNazwa + '] 
				(
					[Id] ASC
				)ON [PRIMARY];
				
				ALTER TABLE [_Slownik_' + @NowaNazwa + '] ADD CONSTRAINT [PK2_Slownik_' + @NowaNazwa + '] PRIMARY KEY NONCLUSTERED(Id);
				
				ALTER TABLE [dbo].[_Slownik_' + @NowaNazwa + ']
				ADD CONSTRAINT [FK_Slownik_' + @NowaNazwa + '_TypId] FOREIGN KEY (TypId) REFERENCES dbo.Cecha_Typy(Id);
				
				ALTER TABLE [dbo].[_Slownik_' + @NowaNazwa + ']
				ADD CONSTRAINT [FK_Slownik_' + @NowaNazwa + '_IdArch] FOREIGN KEY (IdArch) REFERENCES dbo.[_Slownik_' + @NowaNazwa + '](Id);
				
				ALTER TABLE [dbo].[_Slownik_' + @NowaNazwa + ']
				ADD CONSTRAINT [FK_Slownik_' + @NowaNazwa + '_IdArchLink] FOREIGN KEY (IdArchLink) REFERENCES dbo.[_Slownik_' + @NowaNazwa + '](Id);
			END';
			
		--PRINT @str;
		EXEC( @str)
				
		IF NOT EXISTS (SELECT name FROM sys.triggers WHERE name = 'WartoscZmiany_Slownik_' + @NowaNazwa + '_UPDATE')
		BEGIN
			
			SET @str = '
				CREATE TRIGGER [dbo].[WartoscZmiany_Slownik_' + @NowaNazwa + '_UPDATE]
				   ON [dbo].[_Slownik_' + @NowaNazwa + '] 
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
							
							INSERT INTO [dbo].[_Slownik_' + @NowaNazwa + ']
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

							UPDATE [dbo].[_Slownik_' + @NowaNazwa + ']
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
	END
		
					
	IF NOT EXISTS (SELECT name FROM sys.triggers WHERE name = 'WartoscZmiany_Slownik_' + @NowaNazwa + '_INSERT')
	BEGIN	
		SET @str = 'CREATE TRIGGER [dbo].[WartoscZmiany_Slownik_'+ @NowaNazwa +'_INSERT]
				   ON  [dbo].[_Slownik_' + @NowaNazwa + '] 
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
							  JOIN [dbo].[_Slownik_'+ @NowaNazwa +']  AS S2
								ON  S2.Nazwa = S1.Nazwa
								AND (COALESCE(S2.ObowiazujeDo,@maxDt) >= COALESCE(S1.ObowiazujeOd,@maxDt)
									 AND COALESCE(S2.ObowiazujeOd, @maxDt) <= COALESCE(S1.ObowiazujeDo,@maxDt))
							WHERE S1.Id = @id AND S1.ID <> S2.ID
						)	
						BEGIN						
						
							UPDATE [dbo].[_Slownik_'+ @NowaNazwa +'] SET 
							IsAlternativeHistory = 1
							, IsMainHistFlow = 0
							WHERE Id = @id
						
						END
					END
				END'
				
		--PRINT @str
		EXEC(@str)
		
		--wylaczenie trigera na insert
		SET @str = 'DISABLE TRIGGER [dbo].[WartoscZmiany_Slownik_' + @NowaNazwa + '_INSERT] ON  [dbo].[_Slownik_' + @NowaNazwa + '];' 
		EXEC(@str);
	END
	
	END
END



GO
CREATE TRIGGER [dbo].[RemoveTablesForSlownik]
   ON  [dbo].[Slowniki]
   AFTER DELETE
AS 
BEGIN
	SET NOCOUNT ON;
	
	--usuwanie tabel tymczasowych, jesli istnieja
	IF OBJECT_ID('tempdb..#UsunieteSlowniki') IS NOT NULL
		DROP TABLE #UsunieteSlowniki
		
	SELECT Nazwa
	INTO #UsunieteSlowniki
	FROM DELETED
	
	DECLARE @Nazwa nvarchar(256);
	DECLARE @query_drop_obiekt nvarchar(256)
	
	--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
	IF Cursor_Status('local','cur20') > 0 
	BEGIN
		 CLOSE cur20
		 DEALLOCATE cur20
	END

	DECLARE cur20 CURSOR LOCAL FOR 
		SELECT Nazwa FROM #UsunieteSlowniki
	OPEN cur20
	FETCH NEXT FROM cur20 INTO @Nazwa
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @query_drop_obiekt = N'DROP TABLE [dbo].[_Slownik_' + @Nazwa + ']'
	
		IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_Slownik_' + @Nazwa + ']') AND type in (N'U'))
			EXEC (@query_drop_obiekt)	
		
		FETCH NEXT FROM cur20 INTO @Nazwa
	END
	CLOSE cur20;
	DEALLOCATE cur20;
	
	IF OBJECT_ID('tempdb..#UsunieteSlowniki') IS NOT NULL
		DROP TABLE #UsunieteSlowniki

END


GO
-- DK
-- Last modified on: 2013-01-24
------------------------------------------------------
CREATE TRIGGER [dbo].[WartoscZmiany_Slowniki_UPDATE]
ON [dbo].[Slowniki] AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @ID int, @Struktura_ObiektID int, @Nazwa nvarchar(64), @WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int
	,@ZmianaOd datetime, @ZmianaDo datetime, @ObowiazujeOD datetime, @ObowiazujeDo datetime, @TypId int, @WaznyOdNEW datetime, @UtworzonyPrzezNEW int, @CzyWaznyNEW bit
	,@NazwaNEW nvarchar(64), @hist int, @DataModyfikacjiApp datetime, @RealCreatedOn datetime, @RealLastModifiedOn datetime, @IsStatus bit, @StatusS int, @StatusW int, 
	@StatusP int, @StatusSBy int, @StatusPBy int, @StatusWBy int, @StatusSFrom datetime, @StatusPFrom datetime, @StatusWFrom datetime, @IsBlocked bit			

	DECLARE cur_SlownikiTr_UPDATE CURSOR FOR
		SELECT Id, ValidFrom, CreatedBy, IdArchLink, ObowiazujeOd, ObowiazujeDo, Nazwa, TypId,
			IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom, IsBlocked
		FROM deleted
	OPEN cur_SlownikiTr_UPDATE 
	FETCH NEXT FROM cur_SlownikiTr_UPDATE INTO @ID, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo, @Nazwa, @TypId,
		@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, @IsBlocked
	WHILE @@fetch_status = 0
	BEGIN
	
		SELECT @WaznyodNEW = ValidFrom, @CzyWaznyNEW = IsValid, @UtworzonyPrzezNEW = LastModifiedBy, @NazwaNEW = Nazwa,
			@DataModyfikacjiApp = LastModifiedOn, @RealCreatedOn = RealCreatedOn, @RealLastModifiedOn = RealLastModifiedOn
		FROM inserted WHERE Id = @ID
	
		IF(@CzyWaznyNEW = 1)
		BEGIN	
		
			SET @ObowiazujeDo = NULL;					
			
			--DK--
			--przeniesione do Dictioanries_Save
			
			----zmiana nazwy tabeli
			--DECLARE @OldN nvarchar(64) = '_Slownik_' + @Nazwa
			--DECLARE @NewN nvarchar(64) = '_Slownik_' + @NazwaNEW
			
			--IF @OldN <> @NewN
			--	EXEC sp_rename @OldN, @NewN
				
			----TODO co ze zmiana trigerow w tabelach w ktorych zmieniano nazwe?
			--EXEC [THB].[UpdateTriggersForDictionary] @OldName = @OldN, @NewName = @NewN;				
			
			INSERT INTO [dbo].Slowniki
			   ([IdArch], IdArchLink, [IsValid], [ValidFrom], [ValidTo], [CreatedOn], [CreatedBy], [LastModifiedOn], [LastModifiedBy], ObowiazujeOD, ObowiazujeDo, 
			   Nazwa, TypId, RealCreatedOn, RealLastModifiedOn, IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, 
			   StatusWFrom, StatusSTo, StatusPTo, StatusWTo, StatusSToBy, StatusPToBy, StatusWToBy, IsBlocked)				    
			SELECT @ID,ISNULL(@IdArchLink,@ID), 0, @WaznyOd, @WaznyOdNEW, @WaznyOd, @UtworzonyPrzez, @DataModyfikacjiApp, @UtworzonyPrzezNEW, @ObowiazujeOd, @ObowiazujeDo, 
				@Nazwa, @TypId, @RealCreatedOn, @RealLastModifiedOn, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, 
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
				END,
				@IsBlocked 								

			SELECT @hist = @@IDENTITY

			UPDATE dbo.Slowniki
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
			WHERE Id = @ID

		END
	
		FETCH NEXT FROM cur_SlownikiTr_UPDATE INTO @ID, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOd, @ObowiazujeDo, @Nazwa, @TypId,
			@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, @IsBlocked
	END
	
	CLOSE cur_SlownikiTr_UPDATE
	DEALLOCATE cur_SlownikiTr_UPDATE	
	
END

