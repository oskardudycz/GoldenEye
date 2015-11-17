CREATE TABLE [dbo].[Relacje] (
    [Id]                     INT             IDENTITY (1, 1) NOT NULL,
    [IdArch]                 INT             NULL,
    [IdArchLink]             INT             NULL,
    [TypStruktury_Obiekt_Id] INT             NULL,
    [TypObiektuID_L]         INT             NOT NULL,
    [TypObiektuID_R]         INT             NOT NULL,
    [ObiektID_L]             INT             NOT NULL,
    [ObiektID_R]             INT             NOT NULL,
    [TypRelacji_ID]          INT             NOT NULL,
    [SourceId]               INT             NULL,
    [IsStatus]               BIT             CONSTRAINT [DF_Struktura_IsStatus] DEFAULT ((0)) NOT NULL,
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
    [IsValid]                BIT             CONSTRAINT [DF_Struktura_IsValid] DEFAULT ((1)) NULL,
    [ValidFrom]              DATETIME        CONSTRAINT [DF_Struktura_ValidFrom] DEFAULT (getdate()) NOT NULL,
    [ValidTo]                DATETIME SPARSE NULL,
    [IsDeleted]              BIT             CONSTRAINT [DF_Struktura_IsDeleted] DEFAULT ((0)) NOT NULL,
    [DeletedFrom]            DATETIME SPARSE NULL,
    [DeletedBy]              INT SPARSE      NULL,
    [CreatedOn]              DATETIME        CONSTRAINT [DF_Struktura_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]              INT             NULL,
    [LastModifiedOn]         DATETIME SPARSE NULL,
    [LastModifiedBy]         INT SPARSE      NULL,
    [IsOuter]                BIT             CONSTRAINT [DF_Relacje_IsOuter] DEFAULT ((0)) NOT NULL,
    [IsAlternativeHistory]   BIT             DEFAULT ((0)) NULL,
    [IsMainHistFlow]         BIT             DEFAULT ((0)) NULL,
    [RealCreatedOn]          DATETIME        DEFAULT (getdate()) NOT NULL,
    [RealLastModifiedOn]     DATETIME SPARSE NULL,
    [RealDeletedFrom]        DATETIME SPARSE NULL,
    CONSTRAINT [PK_Relacje] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [CHK_Relacje_ObiektID_L] CHECK ([ObiektID_L]>(0)),
    CONSTRAINT [CHK_Relacje_ObiektID_R] CHECK ([ObiektID_R]>(0)),
    CONSTRAINT [FK_Relacje_IdArch] FOREIGN KEY ([IdArch]) REFERENCES [dbo].[Relacje] ([Id]),
    CONSTRAINT [FK_Relacje_IdArchLink] FOREIGN KEY ([IdArchLink]) REFERENCES [dbo].[Relacje] ([Id]),
    CONSTRAINT [FK_Relacje_TypObiektuL] FOREIGN KEY ([TypObiektuID_L]) REFERENCES [dbo].[TypObiektu] ([TypObiekt_ID]),
    CONSTRAINT [FK_Relacje_TypObiektuR] FOREIGN KEY ([TypObiektuID_R]) REFERENCES [dbo].[TypObiektu] ([TypObiekt_ID]),
    CONSTRAINT [FK_Relacje_TypRelacji] FOREIGN KEY ([TypRelacji_ID]) REFERENCES [dbo].[TypRelacji] ([TypRelacji_ID]),
    CONSTRAINT [FK_Relacje_TypStruktury_Obiekt1] FOREIGN KEY ([TypStruktury_Obiekt_Id]) REFERENCES [dbo].[TypStruktury_Obiekt] ([Id])
);


GO
-- DK
-- Last modofied on: 2013-01-28
---------------------------------------
CREATE TRIGGER [dbo].[WartoscZmiany_Relacje_UPDATE]
   ON  [dbo].[Relacje] 
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	IF(UPDATE(IsDeleted)) RETURN;

	DECLARE @ID int, @TypStruktury_ID int, @TypObiektuID_L int, @TypObiektuID_R int, @ObiektID_L int
	,@ObiektID_R int, @TypRelacji_ID int, @WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int
	,@ZmianaOd datetime, @ZmianaDo datetime, @ObowiazujeOd datetime, @ObowiazujeDo datetime, @IsOuter bit, @SourceId int,
	@WaznyOdNEW datetime, @UtworzonyPrzezNEW int, @CzyWaznyNEW bit, @NazwaNEW nvarchar(64), @DataModyfikacjiApp datetime,
	@RealCreatedOn datetime, @RealLastModifiedOn datetime, @hist int, @IsStatus bit, @StatusS int, @StatusW int, 
	@StatusP int, @StatusSBy int, @StatusPBy int, @StatusWBy int, @StatusSFrom datetime, @StatusPFrom datetime, @StatusWFrom datetime			

	DECLARE cur_WZRelacje_UPDATE CURSOR FOR
		SELECT ID, ValidFrom, CreatedBy, IdArchLink, ObowiazujeOD, ObowiazujeDo, TypStruktury_Obiekt_ID 
		,TypObiektuID_L, TypObiektuID_R, ObiektID_L, ObiektID_R, TypRelacji_ID, IsOuter, SourceId,
		IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom  
		FROM deleted
	OPEN cur_WZRelacje_UPDATE 
	FETCH NEXT FROM cur_WZRelacje_UPDATE INTO @ID, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo, @TypStruktury_ID, 
		@TypObiektuID_L, @TypObiektuID_R, @ObiektID_L, @ObiektID_R, @TypRelacji_ID, @IsOuter, @SourceId,
		@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom 
	WHILE @@fetch_status = 0
	BEGIN
				
		SELECT @WaznyodNEW = ValidFrom, @CzyWaznyNEW = IsValid, @UtworzonyPrzezNEW = LastModifiedBy,
		@DataModyfikacjiApp = LastModifiedOn, @RealCreatedOn = RealCreatedOn, @RealLastModifiedOn = RealLastModifiedOn
		FROM inserted WHERE ID = @ID
	
		IF(@CzyWaznyNEW = 1)
		BEGIN
		
			SET @ObowiazujeDo = NULL;
			
			INSERT INTO [dbo].[Relacje]
			   ([IdArch], IdArchLink, [IsValid], [ValidFrom], [ValidTo], [CreatedOn], [CreatedBy], [LastModifiedOn], [LastModifiedBy]
			   ,ObowiazujeOD, ObowiazujeDo, TypStruktury_Obiekt_ID, TypObiektuID_L, TypObiektuID_R, ObiektID_L 
				,ObiektID_R, TypRelacji_ID, IsOuter, SourceId, RealCreatedOn, RealLastModifiedOn,
				IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, 
				StatusWFrom, StatusSTo, StatusPTo, StatusWTo, StatusSToBy, StatusPToBy, StatusWToBy)
	    
			SELECT @ID,ISNULL(@IdArchLink,@ID), 0, @WaznyOd, @DataModyfikacjiApp, @WaznyOd, @UtworzonyPrzez, @DataModyfikacjiApp, @UtworzonyPrzezNEW
				,@ObowiazujeOD, @ObowiazujeDo, @TypStruktury_ID, @TypObiektuID_L, @TypObiektuID_R, @ObiektID_L, @ObiektID_R, 
				@TypRelacji_ID, @IsOuter, @SourceId, @RealCreatedOn, @RealLastModifiedOn,
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

			UPDATE [dbo].[Relacje]
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
	
		FETCH NEXT FROM cur_WZRelacje_UPDATE INTO @ID, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo, @TypStruktury_ID, 
			@TypObiektuID_L, @TypObiektuID_R, @ObiektID_L, @ObiektID_R, @TypRelacji_ID, @IsOuter, @SourceId,
			@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom 
	END
	
	CLOSE cur_WZRelacje_UPDATE
	DEALLOCATE cur_WZRelacje_UPDATE	
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Values description: 0 or null : object was created in this structure; 1 : object points on object created in this structure; 2 : object points on object created outside of this structure', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Relacje', @level2type = N'COLUMN', @level2name = N'Id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Relacja nie została stworzona na podstawie żadnej struktury.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Relacje', @level2type = N'COLUMN', @level2name = N'IsOuter';

