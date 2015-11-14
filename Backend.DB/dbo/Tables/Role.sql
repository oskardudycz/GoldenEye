CREATE TABLE [dbo].[Role] (
    [Id]                   INT             IDENTITY (1, 1) NOT NULL,
    [Nazwa]                NVARCHAR (64)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Opis]                 NVARCHAR (MAX)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [IsAlternativeHistory] BIT             DEFAULT ((0)) NULL,
    [IsMainHistFlow]       BIT             DEFAULT ((0)) NULL,
    [ObowiazujeOd]         DATETIME        NULL,
    [ObowiazujeDo]         DATETIME SPARSE NULL,
    [Rank]                 SMALLINT        NOT NULL,
    [IdArch]               INT             NULL,
    [IdArchLink]           INT             NULL,
    [IsValid]              BIT             DEFAULT ((1)) NOT NULL,
    [ValidFrom]            DATETIME        DEFAULT (getdate()) NOT NULL,
    [ValidTo]              DATETIME SPARSE NULL,
    [IsDeleted]            BIT             DEFAULT ((0)) NOT NULL,
    [DeletedFrom]          DATETIME SPARSE NULL,
    [DeletedBy]            INT SPARSE      NULL,
    [CreatedOn]            DATETIME        DEFAULT (getdate()) NOT NULL,
    [CreatedBy]            INT             NULL,
    [LastModifiedOn]       DATETIME SPARSE NULL,
    [LastModifiedBy]       INT SPARSE      NULL,
    [RealCreatedOn]        DATETIME        DEFAULT (getdate()) NOT NULL,
    [RealLastModifiedOn]   DATETIME SPARSE NULL,
    [RealDeletedFrom]      DATETIME SPARSE NULL,
    [IsStatus]             BIT             DEFAULT ((0)) NOT NULL,
    [StatusS]              INT             DEFAULT ((0)) NOT NULL,
    [StatusSFrom]          DATETIME SPARSE NULL,
    [StatusSTo]            DATETIME SPARSE NULL,
    [StatusSFromBy]        INT SPARSE      NULL,
    [StatusSToBy]          INT SPARSE      NULL,
    [StatusW]              INT             DEFAULT ((0)) NOT NULL,
    [StatusWFrom]          DATETIME SPARSE NULL,
    [StatusWTo]            DATETIME SPARSE NULL,
    [StatusWFromBy]        INT SPARSE      NULL,
    [StatusWToBy]          INT SPARSE      NULL,
    [StatusP]              INT             DEFAULT ((0)) NOT NULL,
    [StatusPFrom]          DATETIME SPARSE NULL,
    [StatusPTo]            DATETIME SPARSE NULL,
    [StatusPFromBy]        INT SPARSE      NULL,
    [StatusPToBy]          INT SPARSE      NULL,
    CONSTRAINT [PK_Role] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Role_IdArch] FOREIGN KEY ([IdArch]) REFERENCES [dbo].[Role] ([Id]),
    CONSTRAINT [FK_Role_IdArchLink] FOREIGN KEY ([IdArchLink]) REFERENCES [dbo].[Role] ([Id])
);


GO
-- Last modified on: 2012-11-23
--------------------------------
CREATE TRIGGER [dbo].[WartoscZmiany_Role_UPDATE]
   ON [dbo].[Role] AFTER UPDATE
	AS 
	BEGIN
		SET NOCOUNT ON;

		declare @ID int, @Nazwa nvarchar(64), @Opis nvarchar(MAX), @WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int
		,@ZmianaOd datetime, @ZmianaDo datetime, @ObowiazujeOD datetime, @ObowiazujeDo datetime, @WaznyOdNEW datetime, @UtworzonyPrzezNEW int, @CzyWaznyNEW bit, @Rank smallint,
		@DataModyfikacjiApp datetime, @RealCreatedOn datetime, @RealLastModifiedOn datetime, @IsStatus bit, @StatusS int, @StatusW int, @StatusP int, @StatusSBy int, @StatusPBy int, 
		@StatusWBy int, @StatusSFrom datetime, @StatusPFrom datetime, @StatusWFrom datetime					

		IF Cursor_Status('local','cur') > 0 
		BEGIN
			 CLOSE cur
			 DEALLOCATE cur
		END	

		DECLARE cur CURSOR LOCAL FOR
			SELECT Id, Nazwa, Opis, [Rank], ValidFrom, CreatedBy, IdArchLink, ObowiazujeOd, ObowiazujeDo,
				IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom
			FROM deleted
		OPEN cur 
		FETCH NEXT FROM cur INTO @Id, @Nazwa, @Opis, @Rank, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOd, @ObowiazujeDo,
			@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
		while @@fetch_status = 0
		BEGIN
			
			SELECT @WaznyodNEW = ValidFrom, @CzyWaznyNEW = IsValid, @UtworzonyPrzezNEW = LastModifiedBy,
			@DataModyfikacjiApp = LastModifiedOn, @RealCreatedOn = RealCreatedOn, @RealLastModifiedOn = RealLastModifiedOn
			FROM inserted WHERE Id = @Id;
			
			declare @hist int;
		
			IF(@CzyWaznyNEW = 1) --AND NOT UPDATE(IsAlternativeHistory))
			BEGIN
			
				SET @ObowiazujeDo = NULL;
				
				INSERT INTO [dbo].[Role]
				   ([IdArch], IdArchLink, Nazwa, Opis, [Rank], [IsValid], [ValidFrom], [ValidTo], [CreatedOn], [CreatedBy]
				   , [LastModifiedOn], [LastModifiedBy], ObowiazujeOd, ObowiazujeDo, 
				   RealCreatedOn, RealLastModifiedOn, IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, 
				   StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom, StatusSTo, StatusPTo, StatusWTo, StatusSToBy, StatusPToBy, StatusWToBy)
			
				SELECT @Id, ISNULL(@IdArchLink, @Id), @Nazwa, @Opis, @Rank, 0, @WaznyOd, @WaznyodNEW, @WaznyOd, @UtworzonyPrzez  
					,@DataModyfikacjiApp, @UtworzonyPrzezNEW, @ObowiazujeOd, @ObowiazujeDo,
					@RealCreatedOn, @RealLastModifiedOn, @IsStatus, @StatusS, @StatusP, @StatusW, 
					@StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, 
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

				UPDATE [dbo].[Role]
				SET ValidFrom = @WaznyodNEW
				,[CreatedBy] = @UtworzonyPrzezNEW
				,LastModifiedOn = NULL
				,LastModifiedBy = NULL
				,CreatedOn = @DataModyfikacjiApp
				,RealCreatedOn = @RealLastModifiedOn
				,RealDeletedFrom = NULL
				,RealLastModifiedOn = NULL
				,IdArchLink = @hist
				,IdArch = NULL
				WHERE Id = @Id
			END
					
			FETCH NEXT FROM cur INTO @Id, @Nazwa, @Opis, @Rank, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOd, @ObowiazujeDo,
				@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
		END
		
		close cur
		deallocate cur	
	END