CREATE TABLE [dbo].[JednostkiMiary_Przeliczniki] (
    [IdFrom]                 INT             NOT NULL,
    [IdTo]                   INT             NOT NULL,
    [Przelicznik]            FLOAT (53)      NOT NULL,
    [Id]                     INT             IDENTITY (1, 1) NOT NULL,
    [IdArch]                 INT             NULL,
    [IdArchLink]             INT             NULL,
    [CzyPrzechowujeHistorie] BIT             NULL,
    [IsStatus]               BIT             DEFAULT ((0)) NOT NULL,
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
    [IsValid]                BIT             DEFAULT ((1)) NOT NULL,
    [ValidFrom]              DATETIME        DEFAULT (getdate()) NOT NULL,
    [ValidTo]                DATETIME SPARSE NULL,
    [IsDeleted]              BIT             DEFAULT ((0)) NOT NULL,
    [DeletedFrom]            DATETIME SPARSE NULL,
    [DeletedBy]              INT SPARSE      NULL,
    [CreatedOn]              DATETIME        DEFAULT (getdate()) NOT NULL,
    [CreatedBy]              INT             NULL,
    [LastModifiedOn]         DATETIME SPARSE NULL,
    [LastModifiedBy]         INT SPARSE      NULL,
    [RealCreatedOn]          DATETIME        DEFAULT (getdate()) NOT NULL,
    [RealLastModifiedOn]     DATETIME SPARSE NULL,
    [RealDeletedFrom]        DATETIME SPARSE NULL,
    CONSTRAINT [PK_JednostkiMiary_Przeliczniki] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [chkToAndFrom] CHECK ([IdFrom]<>[IdTo]),
    CONSTRAINT [FK_JednostkiMiary_Przeliczniki_IdArch] FOREIGN KEY ([IdArch]) REFERENCES [dbo].[JednostkiMiary_Przeliczniki] ([Id]),
    CONSTRAINT [FK_JednostkiMiary_Przeliczniki_IdArchLink] FOREIGN KEY ([IdArchLink]) REFERENCES [dbo].[JednostkiMiary_Przeliczniki] ([Id]),
    CONSTRAINT [FK_JednostkiMiary_Przeliczniki_JednostkiMiary] FOREIGN KEY ([IdFrom]) REFERENCES [dbo].[JednostkiMiary] ([Id]),
    CONSTRAINT [FK_JednostkiMiary_Przeliczniki_JednostkiMiary1] FOREIGN KEY ([IdTo]) REFERENCES [dbo].[JednostkiMiary] ([Id])
);


GO
-- Author: DK
-- Last modified on: 2013-01-26
--
CREATE TRIGGER [dbo].[WartoscZmiany_JednostkiMiary_Przeliczniki_UPDATE]
   ON [dbo].[JednostkiMiary_Przeliczniki] AFTER UPDATE
	AS 
	BEGIN
		SET NOCOUNT ON;

		DECLARE @ID int, @ID_L int, @ID_P int, @Przelicznik float, @WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int
		,@ZmianaOd datetime, @ZmianaDo datetime, @ObowiazujeOD datetime, @ObowiazujeDo datetime,
		@WaznyOdNEW datetime, @UtworzonyPrzezNEW int, @CzyWaznyNEW bit, @PrzelicznikNew float,
		@DataModyfikacjiApp datetime, @RealCreatedOn datetime, @RealLastModifiedOn datetime, @hist int
		,@IsStatus bit, @StatusS int, @StatusW int, @StatusP int, @StatusSBy int, @StatusPBy int, @StatusWBy int, 
		@StatusSFrom datetime, @StatusPFrom datetime, @StatusWFrom datetime					

		IF Cursor_Status('local', 'curPrzelJedn') > 0 
		BEGIN
			 CLOSE curPrzelJedn
			 DEALLOCATE curPrzelJedn
		END	

		DECLARE curPrzelJedn CURSOR LOCAL FOR
			SELECT Id, IdFrom, IdTo, Przelicznik, ValidFrom, CreatedBy, IdArchLink, ObowiazujeOd, ObowiazujeDo,
				IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom
			FROM deleted
		OPEN curPrzelJedn 
		FETCH NEXT FROM curPrzelJedn INTO @Id, @ID_L, @ID_P, @Przelicznik, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOd, @ObowiazujeDo,
			@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
		WHILE @@fetch_status = 0
		BEGIN
			
			SELECT @WaznyodNEW = ValidFrom, @CzyWaznyNEW = IsValid, @UtworzonyPrzezNEW = LastModifiedBy, @PrzelicznikNew = Przelicznik,
				@DataModyfikacjiApp = LastModifiedOn, @RealCreatedOn = RealCreatedOn, @RealLastModifiedOn = RealLastModifiedOn
			FROM inserted WHERE Id = @Id;
		
			IF(@CzyWaznyNEW = 1) --AND NOT UPDATE(IsAlternativeHistory))
			BEGIN
				
				--wpisywanie NULL w pole obowiazujeDo
				SET @ObowiazujeDo = NULL;
				
				INSERT INTO [dbo].[JednostkiMiary_Przeliczniki]
				   ([IdArch], IdArchLink, IdFrom, IdTo, Przelicznik, [IsValid], [ValidFrom], [ValidTo], [CreatedOn], [CreatedBy], [LastModifiedOn], [LastModifiedBy], 
				   ObowiazujeOd, ObowiazujeDo, RealCreatedOn, RealLastModifiedOn,
				   IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, 
				   StatusWFrom, StatusSTo, StatusPTo, StatusWTo, StatusSToBy, StatusPToBy, StatusWToBy)
			
				SELECT @Id, ISNULL(@IdArchLink, @Id), @ID_L, @ID_P, @Przelicznik, 0, @WaznyOd, @WaznyOdNEW, @WaznyOd, @UtworzonyPrzez  
					,@DataModyfikacjiApp, @UtworzonyPrzezNEW, @ObowiazujeOd, @ObowiazujeDo,
					@RealCreatedOn, @RealLastModifiedOn, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, 
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

				UPDATE [dbo].[JednostkiMiary_Przeliczniki]
				SET ValidFrom = @WaznyOdNEW
				,[CreatedBy] = @UtworzonyPrzezNEW
				,LastModifiedOn = NULL
				,LastModifiedBy = NULL
				,CreatedOn = ISNULL(@DataModyfikacjiApp, GETDATE())
				,RealCreatedOn = ISNULL(@RealLastModifiedOn, GETDATE())
				,RealDeletedFrom = NULL
				,RealLastModifiedOn = NULL
				,IdArchLink = @hist
				,IdArch = NULL
				WHERE Id = @Id
			END
					
			FETCH NEXT FROM curPrzelJedn INTO @Id, @ID_L, @ID_P, @Przelicznik, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo,
				@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
		END
		
		CLOSE curPrzelJedn
		DEALLOCATE curPrzelJedn	
	END