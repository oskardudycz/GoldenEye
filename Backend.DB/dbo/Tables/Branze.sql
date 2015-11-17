CREATE TABLE [dbo].[Branze] (
    [TableID]              INT             NULL,
    [Id]                   INT             IDENTITY (1, 1) NOT NULL,
    [IdArch]               INT             NULL,
    [IdArchLink]           INT             NULL,
    [Nazwa]                NVARCHAR (50)   NOT NULL,
    [IsValid]              BIT             CONSTRAINT [DF__Branze__IsValid__0BC6C43E] DEFAULT ((1)) NULL,
    [ValidFrom]            DATETIME        CONSTRAINT [DF__Branze__ValidFro__0CBAE877] DEFAULT (getdate()) NOT NULL,
    [ValidTo]              DATETIME SPARSE NULL,
    [IsStatus]             BIT             CONSTRAINT [DF_Branze_IsStatus] DEFAULT ((0)) NOT NULL,
    [StatusS]              INT SPARSE      NULL,
    [StatusSFrom]          DATETIME SPARSE NULL,
    [StatusSTo]            DATETIME SPARSE NULL,
    [StatusSFromBy]        INT SPARSE      NULL,
    [StatusSToBy]          INT SPARSE      NULL,
    [StatusW]              INT SPARSE      NULL,
    [StatusWFrom]          DATETIME SPARSE NULL,
    [StatusWTo]            DATETIME SPARSE NULL,
    [StatusWFromBy]        INT SPARSE      NULL,
    [StatusWToBy]          INT SPARSE      NULL,
    [StatusP]              INT SPARSE      NULL,
    [StatusPFrom]          DATETIME SPARSE NULL,
    [StatusPTo]            DATETIME SPARSE NULL,
    [StatusPFromBy]        INT SPARSE      NULL,
    [StatusPToBy]          INT SPARSE      NULL,
    [ObowiazujeOd]         DATETIME        NULL,
    [ObowiazujeDo]         DATETIME SPARSE NULL,
    [IsDeleted]            BIT             CONSTRAINT [DF_Branze_IsDeleted] DEFAULT ((0)) NOT NULL,
    [DeletedFrom]          DATETIME SPARSE NULL,
    [DeletedBy]            INT SPARSE      NULL,
    [CreatedOn]            DATETIME        CONSTRAINT [DF_Branze_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]            INT             NULL,
    [LastModifiedOn]       DATETIME SPARSE NULL,
    [LastModifiedBy]       INT SPARSE      NULL,
    [IsAlternativeHistory] BIT             DEFAULT ((0)) NULL,
    [IsMainHistFlow]       BIT             DEFAULT ((0)) NULL,
    [RealCreatedOn]        DATETIME        DEFAULT (getdate()) NOT NULL,
    [RealLastModifiedOn]   DATETIME SPARSE NULL,
    [RealDeletedFrom]      DATETIME SPARSE NULL,
    CONSTRAINT [PK_Branze] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Branze_IdArch] FOREIGN KEY ([IdArch]) REFERENCES [dbo].[Branze] ([Id]),
    CONSTRAINT [FK_Branze_IdArchLink] FOREIGN KEY ([IdArchLink]) REFERENCES [dbo].[Branze] ([Id])
);


GO
-- =============================================
-- Author:		DW
-- Create date: 2011-08-23
-- Last modified on: 2013-01-24
-- Description:	
-- =============================================
CREATE TRIGGER [dbo].[WartoscZmiany_Branze_UPDATE]
ON [dbo].[Branze] AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @ID int, @Struktura_ObiektID int,@Nazwa nvarchar(64)
	,@WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int, @ZmianaOd datetime, @ZmianaDo datetime, @ObowiazujeOD datetime
	,@ObowiazujeDo datetime, @hist int, @WaznyOdNEW datetime, @UtworzonyPrzezNEW int, @CzyWaznyNEW bit, @NazwaNEW nvarchar(64), @DataModyfikacjiApp datetime, 
	@RealCreatedOn datetime, @RealLastModifiedOn datetime, @IsStatus bit, @StatusS int, @StatusW int, @StatusP int, @StatusSBy int, @StatusPBy int, @StatusWBy int, 
	@StatusSFrom datetime, @StatusPFrom datetime, @StatusWFrom datetime		

	DECLARE cur_Branze_UPDATE CURSOR FOR
		SELECT ID, ValidFrom, CreatedBy, IdArchLink, ObowiazujeOD, ObowiazujeDo, Nazwa,
			IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom 
		FROM deleted
	OPEN cur_Branze_UPDATE 
	FETCH NEXT FROM cur_Branze_UPDATE INTO @ID, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo, @Nazwa,
		@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
	WHILE @@fetch_status = 0
	BEGIN
	
		SELECT @WaznyodNEW = ValidFrom, @CzyWaznyNEW = IsValid, @UtworzonyPrzezNEW = LastModifiedBy, @NazwaNEW = Nazwa, 
			@DataModyfikacjiApp = LastModifiedOn, @RealCreatedOn = RealCreatedOn, @RealLastModifiedOn = RealLastModifiedOn
		FROM inserted WHERE ID = @ID
	
		IF(@CzyWaznyNEW = 1)
		BEGIN
			--wpisywanie NULL w pole obowiazujeDo
			SET @ObowiazujeDo = NULL;
					
			INSERT INTO [dbo].Branze
			   ([IdArch], IdArchLink, [IsValid], [ValidFrom], [ValidTo], [CreatedOn], [CreatedBy], [LastModifiedOn],[LastModifiedBy], ObowiazujeOd, ObowiazujeDo
			   , Nazwa, RealCreatedOn, RealLastModifiedOn, IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, 
			   StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom, StatusSTo, StatusPTo, StatusWTo, StatusSToBy, StatusPToBy, StatusWToBy)
	    
			SELECT @ID, ISNULL(@IdArchLink, @ID), 0, @WaznyOd, @DataModyfikacjiApp, @WaznyOd, @UtworzonyPrzez, @DataModyfikacjiApp, @UtworzonyPrzezNEW,
				@ObowiazujeOD, @ObowiazujeDo, @Nazwa, @RealCreatedOn, @RealLastModifiedOn,
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

			UPDATE dbo.Branze
			SET ValidFrom = @DataModyfikacjiApp
			,[CreatedBy] = @UtworzonyPrzezNEW
			,LastModifiedOn = NULL
			,LastModifiedBy = NULL
			,CreatedOn = @DataModyfikacjiApp
			,RealCreatedOn = @RealLastModifiedOn
			,RealDeletedFrom = NULL
			,RealLastModifiedOn = NULL
			,IdArchLink = @hist
			,IdArch = NULL
			WHERE ID = @ID

		END
	
		FETCH NEXT FROM cur_Branze_UPDATE INTO @ID, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo, @Nazwa,
			@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
	END
	
	CLOSE cur_Branze_UPDATE
	DEALLOCATE cur_Branze_UPDATE	

END
