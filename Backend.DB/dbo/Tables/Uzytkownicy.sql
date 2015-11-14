CREATE TABLE [dbo].[Uzytkownicy] (
    [Id]                 INT             IDENTITY (1, 1) NOT NULL,
    [Login]              NVARCHAR (32)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Imie]               NVARCHAR (32)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Nazwisko]           NVARCHAR (64)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Email]              NVARCHAR (64)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Haslo]              NVARCHAR (300)  NOT NULL,
    [Aktywny]            BIT             NOT NULL,
    [Domenowy]           BIT             NOT NULL,
    [Nazwa]              NVARCHAR (256)  NULL,
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
    [IsStatus]           BIT             DEFAULT ((0)) NOT NULL,
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
    CONSTRAINT [PK_Uzytkownicy] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Uzytkownicy_IdArch] FOREIGN KEY ([IdArch]) REFERENCES [dbo].[Uzytkownicy] ([Id]),
    CONSTRAINT [FK_Uzytkownicy_IdArchLink] FOREIGN KEY ([IdArchLink]) REFERENCES [dbo].[Uzytkownicy] ([Id])
);


GO
-- Last modified on: 2013-01-24
----------------------------
CREATE TRIGGER [dbo].[WartoscZmiany_Uzytkownicy_UPDATE]
   ON [dbo].[Uzytkownicy] AFTER UPDATE
	AS 
	BEGIN
		SET NOCOUNT ON;

		declare @Id int, @Login nvarchar(32), @Imie nvarchar(32), @Nazwisko nvarchar(64), @Email nvarchar(64), @Haslo nvarchar(300), @Domenowy bit, @Aktywny bit,
		@WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int, @ZmianaOd datetime, @ZmianaDo datetime, @ObowiazujeOD datetime, @ObowiazujeDo datetime,
		@WaznyOdNEW datetime, @UtworzonyPrzezNEW int, @CzyWaznyNEW bit, @PrzelicznikNew float, @DataModyfikacjiApp datetime, @hist int,
		@RealCreatedOn datetime, @RealLastModifiedOn datetime, @IsStatus bit, @StatusS int, @StatusW int, @StatusP int, @StatusSBy int, @StatusPBy int, @StatusWBy int, 
		@StatusSFrom datetime, @StatusPFrom datetime, @StatusWFrom datetime					

		IF Cursor_Status('local','cur') > 0 
		BEGIN
			 CLOSE cur
			 DEALLOCATE cur
		END	

		DECLARE cur CURSOR LOCAL FOR
			SELECT Id, [Login], Imie, Nazwisko, Email, Haslo, Aktywny, Domenowy, ValidFrom, CreatedBy, IdArchLink, ObowiazujeOD, ObowiazujeDo,
				IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom
			FROM deleted
		OPEN cur 
		FETCH NEXT FROM cur INTO @Id, @Login, @Imie, @Nazwisko, @Email, @Haslo, @Aktywny, @Domenowy, @WaznyOd, @UtworzonyPrzez, @IdArchLink,
			@ObowiazujeOd, @ObowiazujeDo, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
		WHILE @@fetch_status = 0
		BEGIN
					
			SELECT @WaznyodNEW = ValidFrom, @CzyWaznyNEW = IsValid, @UtworzonyPrzezNEW = LastModifiedBy,
				@DataModyfikacjiApp = LastModifiedOn, @RealCreatedOn = RealCreatedOn, @RealLastModifiedOn = RealLastModifiedOn
			FROM inserted WHERE Id = @Id
			
			IF(@CzyWaznyNEW = 1)
			BEGIN
			
				--ustawiena daty do na null, narazie nie uzywane
				SET @ObowiazujeDo = NULL;
				
				INSERT INTO [dbo].[Uzytkownicy]
				   ([IdArch], IdArchLink, [Login], Imie, Nazwisko, Email, Haslo, Aktywny, Domenowy, [IsValid], [ValidFrom], [ValidTo], [CreatedOn], [CreatedBy]
				   , [LastModifiedOn], [LastModifiedBy], ObowiazujeOd, ObowiazujeDo, RealCreatedOn, 
				   RealLastModifiedOn, IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, 
				   StatusWFrom, StatusSTo, StatusPTo, StatusWTo, StatusSToBy, StatusPToBy, StatusWToBy)
			
				SELECT @ID, ISNULL(@IdArchLink, @ID), @Login, @Imie, @Nazwisko, @Email, @Haslo, @Aktywny, @Domenowy, 0, @WaznyOd, @WaznyodNEW, @WaznyOd, @UtworzonyPrzez  
					,@DataModyfikacjiApp, @UtworzonyPrzezNEW, @ObowiazujeOd, @ObowiazujeDo, @RealCreatedOn, 
					@RealLastModifiedOn, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, 
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

				UPDATE [dbo].[Uzytkownicy]
				SET ValidFrom = @WaznyodNEW
				,[CreatedBy] = @UtworzonyPrzezNEW
				,LastModifiedOn = NULL
				,LastModifiedBy = NULL
				,CreatedOn = ISNULL(@DataModyfikacjiApp, GETDATE())
				,RealCreatedOn = @RealLastModifiedOn
				,RealDeletedFrom = NULL
				,RealLastModifiedOn = NULL
				,IdArchLink = @hist
				,IdArch = NULL
				WHERE Id = @Id
			END
					
			FETCH NEXT FROM cur INTO @Id, @Login, @Imie, @Nazwisko, @Email, @Haslo, @Aktywny, @Domenowy, @WaznyOd, @UtworzonyPrzez, @IdArchLink,
				@ObowiazujeOd, @ObowiazujeDo, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
		END
		
		CLOSE cur
		DEALLOCATE cur	
	END