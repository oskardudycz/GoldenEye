CREATE TABLE [dbo].[JednostkiMiary] (
    [Id]                     INT             IDENTITY (1, 1) NOT NULL,
    [NazwaSkrocona]          NVARCHAR (10)   NOT NULL,
    [Nazwa]                  NVARCHAR (200)  NULL,
    [Uwagi]                  NVARCHAR (MAX)  NULL,
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
    [IsBlocked]              BIT             CONSTRAINT [DF_JednostkiMiary_IsBlocked] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_JednostkiMiary] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_JednostkiMiary_IdArch] FOREIGN KEY ([IdArch]) REFERENCES [dbo].[JednostkiMiary] ([Id]),
    CONSTRAINT [FK_JednostkiMiary_IdArchLink] FOREIGN KEY ([IdArchLink]) REFERENCES [dbo].[JednostkiMiary] ([Id])
);


GO
-- Author: DK
-- Last modified on: 2013-03-19
--
CREATE TRIGGER [dbo].[WartoscZmiany_JednostkiMiary_UPDATE]
   ON [dbo].[JednostkiMiary] AFTER UPDATE
	AS 
	BEGIN
		SET NOCOUNT ON;

		declare @ID int, @Nazwa nvarchar(MAX), @NazwaSkrocona nvarchar(10), @Uwagi nvarchar(MAX), @WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int
		,@ZmianaOd datetime, @ZmianaDo datetime, @ObowiazujeOD datetime, @hist int
		,@ObowiazujeDo datetime, @WaznyOdNEW datetime, @UtworzonyPrzezNEW int, @CzyWaznyNEW bit
		,@NazwaNEW nvarchar(64), @DataModyfikacjiApp datetime, @RealCreatedOn datetime, @RealLastModifiedOn datetime
		,@IsStatus bit, @StatusS int, @StatusW int, @StatusP int, @StatusSBy int, @StatusPBy int, @StatusWBy int, 
		@StatusSFrom datetime, @StatusPFrom datetime, @StatusWFrom datetime, @IsBlocked bit				

		IF Cursor_Status('local','curJedn') > 0 
		BEGIN
			 CLOSE curJedn
			 DEALLOCATE curJedn
		END	

		DECLARE curJedn CURSOR FOR
			SELECT ID , Nazwa, NazwaSkrocona, Uwagi, ValidFrom , CreatedBy, IdArchLink, ObowiazujeOd, ObowiazujeDo,
				IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom, IsBlocked
			FROM deleted
		OPEN curJedn 
		FETCH NEXT FROM curJedn INTO @ID, @Nazwa, @NazwaSkrocona, @Uwagi, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOd, @ObowiazujeDo,
			@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, @IsBlocked
		WHILE @@fetch_status = 0
		BEGIN
					
			SELECT @WaznyOdNEW = ValidFrom, @CzyWaznyNEW = IsValid, @UtworzonyPrzezNEW = LastModifiedBy, @NazwaNEW = Nazwa,
				@DataModyfikacjiApp = LastModifiedOn, @RealCreatedOn = RealCreatedOn, @RealLastModifiedOn = RealLastModifiedOn
			FROM inserted WHERE ID = @ID
		
			IF(@CzyWaznyNEW = 1) --AND NOT UPDATE(IsAlternativeHistory))
			BEGIN
				
				--wpisywanie NULL w pole obowiazujeDo
				SET @ObowiazujeDo = NULL;
				
				INSERT INTO [dbo].[JednostkiMiary]
				   ([IdArch], IdArchLink, Nazwa, NazwaSkrocona, Uwagi, [IsValid], [ValidFrom], [ValidTo], [CreatedOn], [CreatedBy], [LastModifiedOn], [LastModifiedBy], 
				   ObowiazujeOd, ObowiazujeDo, RealCreatedOn, RealLastModifiedOn, IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, 
				   StatusWFrom, StatusSTo, StatusPTo, StatusWTo, StatusSToBy, StatusPToBy, StatusWToBy, IsBlocked)			
				SELECT @ID, ISNULL(@IdArchLink,@ID), @Nazwa, @NazwaSkrocona, @Uwagi, 0, @WaznyOd, @WaznyOdNEW, @WaznyOd, @UtworzonyPrzez, @WaznyOdNEW, @UtworzonyPrzezNEW, 
					@ObowiazujeOd, @ObowiazujeDo, @RealCreatedOn, @RealLastModifiedOn,
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
					END,
					@IsBlocked

				SELECT @hist = @@IDENTITY

				UPDATE [dbo].[JednostkiMiary]
				SET ValidFrom = ISNULL(@DataModyfikacjiApp, GETDATE())
				,[CreatedBy] = @UtworzonyPrzezNEW
				,LastModifiedOn = NULL
				,LastModifiedBy = NULL
				,CreatedOn = ISNULL(@DataModyfikacjiApp, GETDATE())
				,RealCreatedOn = ISNULL(@RealLastModifiedOn, GETDATE())
				,RealDeletedFrom = NULL
				,RealLastModifiedOn = NULL
				,IdArchLink = @hist
				,IdArch = NULL
				WHERE ID = @ID
			END
					
			FETCH NEXT FROM curJedn INTO @ID, @Nazwa, @NazwaSkrocona, @Uwagi, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOd, @ObowiazujeDo,
				@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, @IsBlocked
		END
		
		CLOSE curJedn
		DEALLOCATE curJedn	
	END