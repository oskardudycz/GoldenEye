CREATE TABLE [dbo].[TypStruktury] (
    [TypStruktury_Obiekt_Id] INT             NOT NULL,
    [TypObiektuId_L]         INT             NOT NULL,
    [TypObiektuId_R]         INT             NOT NULL,
    [TypRelacjiId]           INT             NOT NULL,
    [TypStruktury_Klasa_Id]  INT             NOT NULL,
    [WartoscRelacji]         INT             NULL,
    [IsStructure]            BIT             NOT NULL,
    [Id]                     INT             IDENTITY (1, 1) NOT NULL,
    [IdArch]                 INT             NULL,
    [IdArchLink]             INT             NULL,
    [IsStatus]               BIT             CONSTRAINT [DF_TypStruktury_IsStatus] DEFAULT ((0)) NOT NULL,
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
    [IsValid]                BIT             CONSTRAINT [DF_TypStruktury_IsValid] DEFAULT ((1)) NULL,
    [ValidFrom]              DATETIME        CONSTRAINT [DF_TypStruktury_ValidFrom] DEFAULT (getdate()) NOT NULL,
    [ValidTo]                DATETIME SPARSE NULL,
    [IsDeleted]              BIT             CONSTRAINT [DF_TypStruktury_IsDeleted] DEFAULT ((0)) NOT NULL,
    [DeletedFrom]            DATETIME SPARSE NULL,
    [DeletedBy]              INT SPARSE      NULL,
    [CreatedOn]              DATETIME        CONSTRAINT [DF_TypStruktury_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]              INT             NULL,
    [LastModifiedOn]         DATETIME SPARSE NULL,
    [LastModifiedBy]         INT SPARSE      NULL,
    [IsAlternativeHistory]   BIT             DEFAULT ((0)) NULL,
    [IsMainHistFlow]         BIT             DEFAULT ((0)) NULL,
    [RealCreatedOn]          DATETIME        DEFAULT (getdate()) NOT NULL,
    [RealLastModifiedOn]     DATETIME SPARSE NULL,
    [RealDeletedFrom]        DATETIME SPARSE NULL,
    CONSTRAINT [PK_TypStruktury] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80),
    FOREIGN KEY ([TypObiektuId_L]) REFERENCES [dbo].[TypObiektu] ([TypObiekt_ID]),
    FOREIGN KEY ([TypObiektuId_R]) REFERENCES [dbo].[TypObiektu] ([TypObiekt_ID]),
    FOREIGN KEY ([TypRelacjiId]) REFERENCES [dbo].[TypRelacji] ([TypRelacji_ID]),
    CONSTRAINT [FK_TypStruktury] FOREIGN KEY ([TypRelacjiId]) REFERENCES [dbo].[TypRelacji] ([TypRelacji_ID]),
    CONSTRAINT [FK_TypStruktury_IdArch] FOREIGN KEY ([IdArch]) REFERENCES [dbo].[TypStruktury] ([Id]),
    CONSTRAINT [FK_TypStruktury_IdArchLink] FOREIGN KEY ([IdArchLink]) REFERENCES [dbo].[TypStruktury] ([Id]),
    CONSTRAINT [FK_TypStruktury_TypObiektuL] FOREIGN KEY ([TypObiektuId_L]) REFERENCES [dbo].[TypObiektu] ([TypObiekt_ID]),
    CONSTRAINT [FK_TypStruktury_TypObiektuR] FOREIGN KEY ([TypObiektuId_R]) REFERENCES [dbo].[TypObiektu] ([TypObiekt_ID]),
    CONSTRAINT [FK_TypStruktury_TypStruktury_Obiekt] FOREIGN KEY ([TypStruktury_Obiekt_Id]) REFERENCES [dbo].[TypStruktury_Obiekt] ([Id])
);


GO
-- DK
-- Last modified on: 2013-01-26
------------------------------------------------------
CREATE TRIGGER [dbo].[WartoscZmiany_TypStruktura_UPDATE]
   ON [dbo].[TypStruktury]
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @ID int, @TypStruktury_Obiekt_Id int, @TypObiektuId_L int, @TypObiektuId_R int, @TypRelacjiId int, @TypStruktury_Klasa_ID int
	,@WartoscRelacji int, @IsStructure bit, @WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int, @ZmianaOd datetime, @ZmianaDo datetime, @ObowiazujeOD datetime
	,@ObowiazujeDo datetime, @WaznyOdNEW datetime, @UtworzonyPrzezNEW int, @CzyWaznyNEW bit, @NazwaNEW nvarchar(64), @DataModyfikacjiApp datetime, @RealCreatedOn datetime, 
	@RealLastModifiedOn datetime, @hist int, @IsStatus bit, @StatusS int, @StatusW int, @StatusP int, @StatusSBy int, @StatusPBy int, @StatusWBy int, @StatusSFrom datetime, 
	@StatusPFrom datetime, @StatusWFrom datetime			

	DECLARE cur_TypStruktura_UPDATE CURSOR FOR
		SELECT ID, ValidFrom, CreatedBy, IdArchLink, ObowiazujeOD, ObowiazujeDo, TypStruktury_Obiekt_Id, TypObiektuId_L, TypObiektuId_R, TypRelacjiId,
			WartoscRelacji, IsStructure, TypStruktury_Klasa_ID, IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom
		FROM deleted
	OPEN cur_TypStruktura_UPDATE 
	FETCH NEXT FROM cur_TypStruktura_UPDATE INTO @ID, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo, @TypStruktury_Obiekt_Id,
		@TypObiektuId_L, @TypObiektuId_R, @TypRelacjiId, @WartoscRelacji, @IsStructure, @TypStruktury_Klasa_ID, 
		@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
	WHILE @@fetch_status = 0
	BEGIN
	
		SELECT @WaznyodNEW = ValidFrom, @CzyWaznyNEW = IsValid, @UtworzonyPrzezNEW = LastModifiedBy,
		@DataModyfikacjiApp = LastModifiedOn, @RealCreatedOn = RealCreatedOn, @RealLastModifiedOn = RealLastModifiedOn
		FROM inserted WHERE ID = @ID
	
		IF(@CzyWaznyNEW = 1)
		BEGIN
		
			--ustawiena daty do na null, narazie nie uzywane
			SET @ObowiazujeDo = NULL;
			
			INSERT INTO dbo.TypStruktury
			   ([IdArch],IdArchLink, [IsValid], [ValidFrom], [ValidTo], [CreatedOn], [CreatedBy], [TypStruktury_Klasa_ID]
			   ,[LastModifiedOn], [LastModifiedBy], ObowiazujeOD, ObowiazujeDo, TypStruktury_Obiekt_Id, TypObiektuId_L, TypObiektuId_R
				,TypRelacjiId, WartoscRelacji, IsStructure, RealCreatedOn, RealLastModifiedOn,
				IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom, StatusSTo, StatusPTo, StatusWTo, 
			   StatusSToBy, StatusPToBy, StatusWToBy )				    
			SELECT @ID,ISNULL(@IdArchLink,@ID), 0, @WaznyOd, @WaznyodNEW, @WaznyOd, @UtworzonyPrzez, @TypStruktury_Klasa_ID  
				,@DataModyfikacjiApp, @UtworzonyPrzezNEW, @ObowiazujeOD, @ObowiazujeDo
				,@TypStruktury_Obiekt_Id, @TypObiektuId_L, @TypObiektuId_R, @TypRelacjiId, @WartoscRelacji, @IsStructure,				@RealCreatedOn, @RealLastModifiedOn, @IsStatus, @StatusS, @StatusP, @StatusW, 
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
			SELECT @hist = @@IDENTITY

			UPDATE dbo.TypStruktury
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
			WHERE ID = @ID

		END
	
		FETCH NEXT FROM cur_TypStruktura_UPDATE INTO @ID, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo, @TypStruktury_Obiekt_Id,
			@TypObiektuId_L, @TypObiektuId_R, @TypRelacjiId, @WartoscRelacji, @IsStructure, @TypStruktury_Klasa_ID, 
			@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
	END
	
	CLOSE cur_TypStruktura_UPDATE
	DEALLOCATE cur_TypStruktura_UPDATE	
END

