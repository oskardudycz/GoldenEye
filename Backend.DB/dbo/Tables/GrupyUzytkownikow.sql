CREATE TABLE [dbo].[GrupyUzytkownikow] (
    [Id]                 INT             IDENTITY (1, 1) NOT NULL,
    [Nazwa]              NVARCHAR (64)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Opis]               NVARCHAR (MAX)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [IdArch]             INT             NULL,
    [IdArchLink]         INT             NULL,
    [ObowiazujeOd]       DATETIME        NULL,
    [ObowiazujeDo]       DATETIME SPARSE NULL,
    [IsValid]            BIT             DEFAULT ((1)) NOT NULL,
    [ValidFrom]          DATETIME        DEFAULT (getdate()) NOT NULL,
    [ValidTo]            DATETIME SPARSE NULL,
    [IsDeleted]          BIT             DEFAULT ((0)) NOT NULL,
    [DeletedFrom]        DATETIME SPARSE NULL,
    [DeletedBy]          INT SPARSE      NULL,
    [CreatedOn]          DATETIME        DEFAULT (getdate()) NOT NULL,
    [CreatedBy]          INT             NULL,
    [LastModifiedOn]     DATETIME SPARSE NULL,
    [LastModifiedBy]     INT SPARSE      NULL,
    [RealCreatedOn]      DATETIME        DEFAULT (getdate()) NOT NULL,
    [RealLastModifiedOn] DATETIME SPARSE NULL,
    [RealDeletedFrom]    DATETIME SPARSE NULL,
    [IsStatus]           BIT             DEFAULT ((1)) NOT NULL,
    [StatusS]            INT             DEFAULT ((0)) NOT NULL,
    [StatusSFrom]        DATETIME SPARSE NULL,
    [StatusSTo]          DATETIME SPARSE NULL,
    [StatusSFromBy]      INT SPARSE      NULL,
    [StatusSToBy]        INT SPARSE      NULL,
    [StatusW]            INT             DEFAULT ((0)) NOT NULL,
    [StatusWFrom]        DATETIME SPARSE NULL,
    [StatusWTo]          DATETIME SPARSE NULL,
    [StatusWFromBy]      INT SPARSE      NULL,
    [StatusWToBy]        INT SPARSE      NULL,
    [StatusP]            INT             DEFAULT ((0)) NOT NULL,
    [StatusPFrom]        DATETIME SPARSE NULL,
    [StatusPTo]          DATETIME SPARSE NULL,
    [StatusPFromBy]      INT SPARSE      NULL,
    [StatusPToBy]        INT SPARSE      NULL,
    CONSTRAINT [PK_GrupyUzytkownikow] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_GrupyUzytkownikow_IdArch] FOREIGN KEY ([IdArch]) REFERENCES [dbo].[GrupyUzytkownikow] ([Id]),
    CONSTRAINT [FK_GrupyUzytkownikow_IdArchLink] FOREIGN KEY ([IdArchLink]) REFERENCES [dbo].[GrupyUzytkownikow] ([Id])
);


GO
-- Last modified on: 2013-01-26
CREATE TRIGGER [dbo].[WartoscZmiany_GrupyUzytkownikow_UPDATE]
   ON [dbo].[GrupyUzytkownikow] AFTER UPDATE
	AS 
	BEGIN
		SET NOCOUNT ON;

		declare @ID int, @Nazwa nvarchar(64), @Opis nvarchar(MAX), @WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int
		,@ZmianaOd datetime, @ZmianaDo datetime, @ObowiazujeOD datetime, @ObowiazujeDo datetime
		,@WaznyOdNEW datetime, @UtworzonyPrzezNEW int, @CzyWaznyNEW bit, @PrzelicznikNew float, @DataModyfikacjiApp datetime
		,@RealCreatedOn datetime, @RealLastModifiedOn datetime, @hist int
		,@IsStatus bit, @StatusS int, @StatusW int, @StatusP int, @StatusSBy int, @StatusPBy int, @StatusWBy int, 
		@StatusSFrom datetime, @StatusPFrom datetime, @StatusWFrom datetime			

		IF Cursor_Status('local','cur') > 0 
		BEGIN
			 CLOSE cur
			 DEALLOCATE cur
		END	

		DECLARE cur CURSOR LOCAL FOR
			SELECT Id, Nazwa, Opis, ValidFrom, CreatedBy, IdArchLink, ObowiazujeOd, ObowiazujeDo, IsStatus, StatusS, StatusP, StatusW, 
				StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom
			FROM deleted
		OPEN cur 
		FETCH NEXT FROM cur INTO @Id, @Nazwa, @Opis, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOd, @ObowiazujeDo, @IsStatus, @StatusS,
			@StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
		WHILE @@fetch_status = 0
		BEGIN
			
			SELECT @WaznyodNEW = ValidFrom, @CzyWaznyNEW = IsValid, @UtworzonyPrzezNEW = LastModifiedBy,
			@DataModyfikacjiApp = LastModifiedOn, @RealCreatedOn = RealCreatedOn, @RealLastModifiedOn = RealLastModifiedOn
			FROM inserted WHERE Id = @Id; 
		
			IF(@CzyWaznyNEW = 1)
			BEGIN
			
				--wpisywanie NULL w pole obowiazujeDo
				SET @ObowiazujeDo = NULL;
				
				INSERT INTO [dbo].[GrupyUzytkownikow]
				   ([IdArch], IdArchLink, Nazwa, Opis, [IsValid], [ValidFrom], [ValidTo], [CreatedOn], [CreatedBy]
				   , [LastModifiedOn], [LastModifiedBy], ObowiazujeOd, ObowiazujeDo,
				   RealCreatedOn, RealLastModifiedOn, IsStatus, StatusS, StatusP, StatusW, 
					StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom, StatusSTo, StatusPTo, StatusWTo,
					StatusSToBy, StatusPToBy, StatusWToBy)
			
				SELECT @Id, ISNULL(@IdArchLink, @Id), @Nazwa, @Opis, 0, @WaznyOd, @WaznyodNEW, @WaznyOd, @UtworzonyPrzez  
					,@DataModyfikacjiApp, @UtworzonyPrzezNEW, @ObowiazujeOd, @ObowiazujeDo, 
					@RealCreatedOn, @RealLastModifiedOn, @IsStatus, @StatusS,
					@StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, 
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

				SET @hist = @@IDENTITY;

				UPDATE [dbo].[GrupyUzytkownikow] SET
				 ValidFrom = @DataModyfikacjiApp
				,[CreatedBy] = @UtworzonyPrzezNEW
				,LastModifiedOn = NULL
				,LastModifiedBy = NULL
				,CreatedOn = @DataModyfikacjiApp
				,RealCreatedOn = ISNULL(@RealLastModifiedOn, GETDATE())
				,RealDeletedFrom = NULL
				,RealLastModifiedOn = NULL
				,IdArchLink = @hist
				,IdArch = NULL
				WHERE Id = @Id
			END
					
			FETCH NEXT FROM cur INTO @Id, @Nazwa, @Opis, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOd, @ObowiazujeDo, @IsStatus, @StatusS,
				@StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
		END
		
		CLOSE cur
		DEALLOCATE cur	
	END