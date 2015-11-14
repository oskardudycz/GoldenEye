CREATE TABLE [dbo].[TypRelacji_Cechy] (
    [ID]                   INT             IDENTITY (1, 1) NOT NULL,
    [TypRelacji_ID]        INT             NOT NULL,
    [Cecha_ID]             INT             NOT NULL,
    [IsValid]              BIT             CONSTRAINT [DF_TypRelacji_Cechy_IsValid] DEFAULT ((1)) NULL,
    [CreatedOn]            DATETIME        CONSTRAINT [DF_TypRelacji_Cechy_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]            INT             NULL,
    [LastModifiedOn]       DATETIME SPARSE NULL,
    [LastModifiedBy]       INT SPARSE      NULL,
    [Priority]             SMALLINT        NOT NULL,
    [UIOrder]              SMALLINT        NOT NULL,
    [IsAlternativeHistory] BIT             DEFAULT ((0)) NULL,
    [IsMainHistFlow]       BIT             DEFAULT ((0)) NULL,
    [ObowiazujeOd]         DATETIME        NULL,
    [ObowiazujeDo]         DATETIME SPARSE NULL,
    [IsDeleted]            BIT             DEFAULT ((0)) NOT NULL,
    [DeletedBy]            INT             NULL,
    [DeletedFrom]          DATETIME        NULL,
    [IdArch]               INT             NULL,
    [IdArchLink]           INT             NULL,
    [IsStatus]             BIT             DEFAULT ((0)) NOT NULL,
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
    [ValidFrom]            DATETIME        DEFAULT (getdate()) NOT NULL,
    [ValidTo]              DATETIME SPARSE NULL,
    [RealCreatedOn]        DATETIME        DEFAULT (getdate()) NOT NULL,
    [RealLastModifiedOn]   DATETIME SPARSE NULL,
    [RealDeletedFrom]      DATETIME        NULL,
    [Importance]           SMALLINT        NULL,
    CONSTRAINT [PK_TypRelacji_Cechy] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_TypRelacji_Cechy_Cechy] FOREIGN KEY ([Cecha_ID]) REFERENCES [dbo].[Cechy] ([Cecha_ID]),
    CONSTRAINT [FK_TypRelacji_Cechy_IdArch] FOREIGN KEY ([IdArch]) REFERENCES [dbo].[TypRelacji_Cechy] ([ID]),
    CONSTRAINT [FK_TypRelacji_Cechy_IdArchLink] FOREIGN KEY ([IdArchLink]) REFERENCES [dbo].[TypRelacji_Cechy] ([ID]),
    CONSTRAINT [FK_TypRelacji_Cechy_TypRelacji] FOREIGN KEY ([TypRelacji_ID]) REFERENCES [dbo].[TypRelacji] ([TypRelacji_ID])
);


GO
-- Last modified on: 2013-01-26
---------------------	
CREATE TRIGGER [dbo].[WartoscZmiany_TypRelacji_Cechy_UPDATE]
   ON [dbo].[TypRelacji_Cechy]
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @ID int, @TypRelacjiId int, @CechaId int, @Priority int, @UIOrder int
	,@WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int, @Importance smallint
	,@ZmianaOd datetime, @ZmianaDo datetime, @ObowiazujeOD datetime
	,@ObowiazujeDo datetime, @WaznyOdNEW datetime, @UtworzonyPrzezNEW int, @CzyWaznyNEW bit
	,@NazwaNEW nvarchar(64), @CzyPrzechowujeHistorieNEW bit, @IsALternativeHistory bit, @IsMainHistFlow bit
	,@DataModyfikacjiApp datetime, @RealCreatedOn datetime, @RealLastModifiedOn datetime, @hist int, @IsStatus bit, @StatusS int, @StatusW int
	,@StatusP int, @StatusSBy int, @StatusPBy int, @StatusWBy int, @StatusSFrom datetime, @StatusPFrom datetime, @StatusWFrom datetime		

	DECLARE cur CURSOR FOR
		SELECT ID, TypRelacji_ID, Cecha_ID, ValidFrom, CreatedBy, IdArchLink, ObowiazujeOd, ObowiazujeDo, [Priority], UIOrder, Importance, IsAlternativeHistory, IsMainHistFlow,
			IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom
		FROM deleted
	OPEN cur 
	FETCH NEXT FROM cur INTO @ID, @TypRelacjiId, @CechaId, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOd, @ObowiazujeDo, @Priority, @UIOrder, @Importance,
		@IsAlternativeHistory, @IsMainHistFlow, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom 
	WHILE @@fetch_status = 0
	BEGIN
	
		SELECT @WaznyOdNEW = ValidFrom, @CzyWaznyNEW = IsValid, @UtworzonyPrzezNEW = LastModifiedBy,
			@DataModyfikacjiApp = LastModifiedOn, @RealCreatedOn = RealCreatedOn, @RealLastModifiedOn = RealLastModifiedOn
		FROM inserted WHERE Id = @ID

		IF(@CzyWaznyNEW = 1)
		BEGIN	
		
			--ustawiena daty do na null, narazie nie uzywane
			SET @ObowiazujeDo = NULL;					
			
			INSERT INTO dbo.[TypRelacji_Cechy]
			   ([IdArch], IdArchLink, [IsValid], [ValidFrom], [ValidTo], [CreatedOn], [CreatedBy], [LastModifiedOn], [LastModifiedBy],
			   ObowiazujeOD, ObowiazujeDo, TypRelacji_ID, Cecha_ID, [Priority], UIOrder, Importance, IsAlternativeHistory, IsMainHistFlow,
			   RealCreatedOn, RealLastModifiedOn, IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, 
				   StatusWFrom, StatusSTo, StatusPTo, StatusWTo, StatusSToBy, StatusPToBy, StatusWToBy)		    
			SELECT @ID, ISNULL(@IdArchLink, @ID), 0, @WaznyOd, @WaznyodNEW, @WaznyOd, @UtworzonyPrzez  
				, @DataModyfikacjiApp, @UtworzonyPrzezNEW, @ObowiazujeOD, @ObowiazujeDo, @TypRelacjiID, @CechaID, @Priority, @UIOrder, @Importance
				, @IsAlternativeHistory, @IsMainHistFlow, @RealCreatedOn, @RealLastModifiedOn
				, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, 
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

			UPDATE dbo.[TypRelacji_Cechy]
			SET ValidFrom = @WaznyodNEW
			,[CreatedBy] = @UtworzonyPrzezNEW
			,LastModifiedOn = NULL
			,LastModifiedBy = NULL
			,CreatedOn = ISNULL(@DataModyfikacjiApp, GETDATE())
			,RealCreatedOn = ISNULL(@RealLastModifiedOn, GETDATE())
			,RealDeletedFrom = NULL
			,RealLastModifiedOn = NULL
			,IdArchLink = @hist
			,IdArch = NULL
			WHERE Id = @ID
		END
	
		FETCH NEXT FROM cur INTO @ID, @TypRelacjiId, @CechaId, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo, @Priority, @UIOrder, @Importance,
			@IsAlternativeHistory, @IsMainHistFlow, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
	END
	
	CLOSE cur
	DEALLOCATE cur	
END