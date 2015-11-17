CREATE TABLE [dbo].[Branze_Cechy] (
    [TableID]              INT             NULL,
    [BranzaId]             INT             NOT NULL,
    [CechaId]              INT             NOT NULL,
    [IsValid]              BIT             CONSTRAINT [DF_Branze_CechyPodstawowe_IsValid] DEFAULT ((1)) NULL,
    [ValidFrom]            DATETIME        CONSTRAINT [DF_Branze_CechyPodstawowe_ValidFrom] DEFAULT (getdate()) NOT NULL,
    [ValidTo]              DATETIME SPARSE NULL,
    [Id]                   INT             IDENTITY (1, 1) NOT NULL,
    [IdArch]               INT             NULL,
    [IdArchLink]           INT             NULL,
    [IsStatus]             BIT             CONSTRAINT [DF_Branze_Cechy_IsStatus] DEFAULT ((0)) NOT NULL,
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
    [IsDeleted]            BIT             CONSTRAINT [DF_Branze_Cechy_IsDeleted] DEFAULT ((0)) NOT NULL,
    [DeletedFrom]          DATETIME SPARSE NULL,
    [DeletedBy]            INT SPARSE      NULL,
    [CreatedOn]            DATETIME        CONSTRAINT [DF_Branze_Cechy_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]            INT             NULL,
    [LastModifiedOn]       DATETIME SPARSE NULL,
    [LastModifiedBy]       INT SPARSE      NULL,
    [IsAlternativeHistory] BIT             DEFAULT ((0)) NULL,
    [IsMainHistFlow]       BIT             DEFAULT ((0)) NULL,
    [RealCreatedOn]        DATETIME        DEFAULT (getdate()) NOT NULL,
    [RealLastModifiedOn]   DATETIME SPARSE NULL,
    [RealDeletedFrom]      DATETIME SPARSE NULL,
    CONSTRAINT [PK_Branze_Cechy] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Branza] FOREIGN KEY ([BranzaId]) REFERENCES [dbo].[Branze] ([Id]),
    CONSTRAINT [FK_Branze_Cechy_IdArch] FOREIGN KEY ([IdArch]) REFERENCES [dbo].[Branze_Cechy] ([Id]),
    CONSTRAINT [FK_Branze_Cechy_IdArchLink] FOREIGN KEY ([IdArchLink]) REFERENCES [dbo].[Branze_Cechy] ([Id]),
    CONSTRAINT [FK_Cecha] FOREIGN KEY ([CechaId]) REFERENCES [dbo].[Cechy] ([Cecha_ID])
);


GO
-- =============================================
-- Author:		DW
-- Create date: 2011-08-23
-- Last modified on: 2013-01-24
-- Description:	
-- =============================================
CREATE TRIGGER [dbo].[WartoscZmiany_Branze_Cechy_UPDATE]
ON [dbo].[Branze_Cechy] AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @ID int, @BranzaId int, @CechaId int, @WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int
	,@ZmianaOd datetime, @ZmianaDo datetime, @ObowiazujeOD datetime, @ObowiazujeDo datetime,
	@WaznyOdNEW datetime, @UtworzonyPrzezNEW int, @CzyWaznyNEW bit, @NazwaNEW nvarchar(64),
	@DataModyfikacjiApp datetime, @RealCreatedOn datetime, @RealLastModifiedOn datetime, @hist int,
	@IsStatus bit, @StatusS int, @StatusW int, @StatusP int, @StatusSBy int, @StatusPBy int, @StatusWBy int, 
	@StatusSFrom datetime, @StatusPFrom datetime, @StatusWFrom datetime			

	DECLARE cur_BranzeCechy_UPDATE CURSOR FOR
		SELECT ID, ValidFrom, CreatedBy, IdArchLink, ObowiazujeOd, ObowiazujeDo, BranzaID, CechaID,
			IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom
		FROM deleted
	OPEN cur_BranzeCechy_UPDATE 
	FETCH NEXT FROM cur_BranzeCechy_UPDATE INTO @ID, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo
		,@BranzaID, @CechaID, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
	
	WHILE @@fetch_status = 0
	BEGIN
	
		SELECT @WaznyodNEW = ValidFrom, @CzyWaznyNEW = IsValid, @UtworzonyPrzezNEW = LastModifiedBy,
		@DataModyfikacjiApp = LastModifiedOn, @RealCreatedOn = RealCreatedOn, @RealLastModifiedOn = RealLastModifiedOn
		FROM inserted WHERE ID = @ID
	
		IF(@CzyWaznyNEW = 1)
		BEGIN
		
			--wpisywanie NULL w pole obowiazujeDo
			SET @ObowiazujeDo = NULL;					
		
			INSERT INTO [dbo].Branze_Cechy
			   ([IdArch], IdArchLink, [IsValid], [ValidFrom], [ValidTo], [CreatedOn], [CreatedBy], [LastModifiedOn], [LastModifiedBy]
			   ,ObowiazujeOD, ObowiazujeDo, BranzaId, CechaId, RealCreatedOn, RealLastModifiedOn,
			   IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, 
				   StatusWFrom, StatusSTo, StatusPTo, StatusWTo, StatusSToBy, StatusPToBy, StatusWToBy)
	    
			SELECT @ID, ISNULL(@IdArchLink,@ID), 0, @WaznyOd, @DataModyfikacjiApp, @WaznyOd, @UtworzonyPrzez,  
				@DataModyfikacjiApp, @UtworzonyPrzezNEW, @ObowiazujeOD, @ObowiazujeDo, @BranzaId, @CechaId, 
				@RealCreatedOn, @RealLastModifiedOn, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, 
				@StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, 
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

			UPDATE dbo.Branze_Cechy
			SET ValidFrom = ISNULL(@DataModyfikacjiApp, GETDATE())
			,[CreatedBy] = @UtworzonyPrzezNEW
			,LastModifiedOn = NULL
			,LastModifiedBy = NULL
			,CreatedOn = ISNULL(@DataModyfikacjiApp, GETDATE())
			,RealCreatedOn = ISNULL(@RealLastModifiedOn, GETDATE())
			,RealLastModifiedOn = NULL
			,IdArchLink = @hist
			,IdArch = NULL
			WHERE ID = @ID

		END
				
			FETCH NEXT FROM cur_BranzeCechy_UPDATE INTO @ID, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo
				,@BranzaID, @CechaID, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
		END
		
		CLOSE cur_BranzeCechy_UPDATE
		DEALLOCATE cur_BranzeCechy_UPDATE	
		
	END
