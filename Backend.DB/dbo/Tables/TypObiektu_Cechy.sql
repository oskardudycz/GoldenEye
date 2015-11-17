CREATE TABLE [dbo].[TypObiektu_Cechy] (
    [ID]                     INT             IDENTITY (1, 1) NOT NULL,
    [IdArch]                 INT             NULL,
    [IdArchLink]             INT             NULL,
    [TypObiektu_ID]          INT             NOT NULL,
    [Cecha_ID]               INT             NOT NULL,
    [CzyPrzechowujeHistorie] BIT             CONSTRAINT [DF_TypObiektu_Cechy_CzyPrzechowujeHistorie] DEFAULT ((1)) NULL,
    [IsStatus]               BIT             CONSTRAINT [DF_TypObiektu_Cechy_IsStatus] DEFAULT ((0)) NOT NULL,
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
    [IsValid]                BIT             CONSTRAINT [DF_TypObiektu_Cechy_IsValid1] DEFAULT ((1)) NOT NULL,
    [ValidFrom]              DATETIME        CONSTRAINT [DF_TypObiektu_Cechy_ValidFrom] DEFAULT (getdate()) NOT NULL,
    [ValidTo]                DATETIME SPARSE NULL,
    [IsDeleted]              BIT             CONSTRAINT [DF_TypObiektu_Cechy_IsDeleted] DEFAULT ((0)) NOT NULL,
    [DeletedFrom]            DATETIME SPARSE NULL,
    [DeletedBy]              INT SPARSE      NULL,
    [CreatedOn]              DATETIME        NULL,
    [CreatedBy]              INT             NULL,
    [LastModifiedOn]         DATETIME SPARSE NULL,
    [LastModifiedBy]         INT SPARSE      NULL,
    [Priority]               SMALLINT        NOT NULL,
    [UIOrder]                SMALLINT        NOT NULL,
    [IsAlternativeHistory]   BIT             DEFAULT ((0)) NULL,
    [IsMainHistFlow]         BIT             DEFAULT ((0)) NULL,
    [Importance]             SMALLINT        NULL,
    [RealCreatedOn]          DATETIME        DEFAULT (getdate()) NOT NULL,
    [RealLastModifiedOn]     DATETIME SPARSE NULL,
    [RealDeletedFrom]        DATETIME SPARSE NULL,
    CONSTRAINT [PK_TypObiektu_Cechy] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_TypObiektu_Cechy_Cechy] FOREIGN KEY ([Cecha_ID]) REFERENCES [dbo].[Cechy] ([Cecha_ID]),
    CONSTRAINT [FK_TypObiektu_Cechy_IdArch] FOREIGN KEY ([IdArch]) REFERENCES [dbo].[TypObiektu_Cechy] ([ID]),
    CONSTRAINT [FK_TypObiektu_Cechy_IdArchLink] FOREIGN KEY ([IdArchLink]) REFERENCES [dbo].[TypObiektu_Cechy] ([ID]),
    CONSTRAINT [FK_TypObiektu_Cechy_TypObiektu] FOREIGN KEY ([TypObiektu_ID]) REFERENCES [dbo].[TypObiektu] ([TypObiekt_ID])
);


GO
-- =============================================
-- Author:		DW, DK
-- Create date: 2011-08-23
-- Last modified on: 2013-01-24
-- Description:	
-- =============================================
CREATE TRIGGER [dbo].[WartoscZmiany_TypObiektu_Cechy_UPDATE]
ON [dbo].[TypObiektu_Cechy] AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @ID int, @TypObiektu_ID int, @CechaID int, @CzyPrzechowujeHistorie bit, @Priority int, @UIOrder int, @WaznyOd datetime, @UtworzonyPrzez int, 
	@IdArchLink int, @ZmianaOd datetime, @ZmianaDo datetime, @ObowiazujeOD datetime, @ObowiazujeDo datetime, @Importance smallint, @WaznyOdNEW datetime, 
	@UtworzonyPrzezNEW int, @CzyWaznyNEW bit, @CreatedOn datetime, @DataModyfikacjiApp datetime, @RealCreatedOn datetime, @RealLastModifiedOn datetime, @hist int,
	@IsStatus bit, @StatusS int, @StatusW int, @StatusP int, @StatusSBy int, @StatusPBy int, @StatusWBy int, @StatusSFrom datetime, @StatusPFrom datetime, @StatusWFrom datetime						

	DECLARE cur_TypObiektuCechy_UPDATE CURSOR FOR
		SELECT ID, TypObiektu_ID, Cecha_ID, @CzyPrzechowujeHistorie, ValidFrom, CreatedBy, IdArchLink, ObowiazujeOD, ObowiazujeDo, UIOrder, [Priority], 
			Importance, CreatedOn, IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom
		FROM deleted
	OPEN cur_TypObiektuCechy_UPDATE 
	FETCH NEXT FROM cur_TypObiektuCechy_UPDATE INTO @ID, @TypObiektu_ID, @CechaID, @CzyPrzechowujeHistorie, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo, 
		@UIOrder, @Priority, @Importance, @CreatedOn, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
	WHILE @@fetch_status = 0
	BEGIN
	
		SELECT @WaznyodNEW = ValidFrom, @CzyWaznyNEW = IsValid, @UtworzonyPrzezNEW = LastModifiedBy,
			@DataModyfikacjiApp = LastModifiedOn, @RealCreatedOn = RealCreatedOn, @RealLastModifiedOn = RealLastModifiedOn
		FROM inserted WHERE ID = @ID
		
		IF(@CzyWaznyNEW = 1)
		BEGIN
			
			SET @ObowiazujeDo = NULL;						
			
			INSERT INTO dbo.TypObiektu_Cechy
			   ([IdArch],IdArchLink, [IsValid], [ValidFrom], [ValidTo], [CreatedOn], [CreatedBy], [LastModifiedOn],[LastModifiedBy], ObowiazujeOD, ObowiazujeDo
			   ,TypObiektu_ID, Cecha_ID, UIOrder, [Priority], Importance, RealCreatedOn, RealLastModifiedOn,
			   IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, 
				StatusWFrom, StatusSTo, StatusPTo, StatusWTo, StatusSToBy, StatusPToBy, StatusWToBy)
	    
			SELECT @ID,ISNULL(@IdArchLink, @ID), 0, @WaznyOd, @WaznyodNEW, @CreatedOn, @UtworzonyPrzez  
				,@DataModyfikacjiApp ,@UtworzonyPrzezNEW, @ObowiazujeOD, @ObowiazujeDo
				,@TypObiektu_ID, @CechaID, @UIOrder, @Priority, @Importance, @RealCreatedOn, @RealLastModifiedOn,
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

			UPDATE dbo.TypObiektu_Cechy
			SET ValidFrom = @WaznyodNEW
			,[CreatedBy] = @UtworzonyPrzezNEW
			,LastModifiedOn = NULL
			,LastModifiedBy = NULL
			,CreatedOn = @DataModyfikacjiApp
			,RealCreatedOn = @RealLastModifiedOn
			,RealLastModifiedOn = NULL
			,IdArchLink = @hist
			,IdArch = NULL
			WHERE Id = @ID

		END
		
			FETCH NEXT FROM cur_TypObiektuCechy_UPDATE INTO @ID, @TypObiektu_ID, @CechaID, @CzyPrzechowujeHistorie, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo, 
				@UIOrder, @Priority, @Importance, @CreatedOn, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom

	END
	
	CLOSE cur_TypObiektuCechy_UPDATE
	DEALLOCATE cur_TypObiektuCechy_UPDATE	

END
