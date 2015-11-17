CREATE TABLE [dbo].[_Czynność nietabelaryczna] (
    [Id]                   INT             IDENTITY (1, 1) NOT NULL,
    [IdArch]               INT             NULL,
    [IdArchLink]           INT             NULL,
    [Nazwa]                NVARCHAR (256)  NOT NULL,
    [IsAlternativeHistory] BIT             DEFAULT ((0)) NULL,
    [IsMainHistFlow]       BIT             DEFAULT ((1)) NULL,
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
    [ObowiazujeOd]         DATETIME        NULL,
    [ObowiazujeDo]         DATETIME SPARSE NULL,
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
    CONSTRAINT [PK2_Czynność nietabelaryczna] PRIMARY KEY NONCLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Czynność nietabelaryczna_IdArch] FOREIGN KEY ([IdArch]) REFERENCES [dbo].[_Czynność nietabelaryczna] ([Id]),
    CONSTRAINT [FK_Czynność nietabelaryczna_IdArchLink] FOREIGN KEY ([IdArchLink]) REFERENCES [dbo].[_Czynność nietabelaryczna] ([Id])
);


GO
CREATE CLUSTERED INDEX [PK_Czynność nietabelaryczna]
    ON [dbo].[_Czynność nietabelaryczna]([Id] ASC);


GO

CREATE TRIGGER [dbo].[WartoscZmiany_Czynność nietabelaryczna_UPDATE]
   ON  [dbo].[_Czynność nietabelaryczna] 
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	--IF(UPDATE(IsDeleted)) RETURN;

	DECLARE @ID int, @Nazwa nvarchar(64), @WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int, @Wersja int
	,@ObowiazujeOd datetime, @ObowiazujeDo datetime, @WaznyOdNEW datetime, @UtworzonyPrzezNEW int, @CzyWaznyNEW bit
	,@NazwaNEW nvarchar(64), @DataModyfikacjiApp datetime, @RealCreatedOn datetime, @RealLastModifiedOn datetime, @hist int
	,@IsStatus bit, @StatusS int, @StatusW int, @StatusP int, @StatusSBy int, @StatusPBy int, @StatusWBy int 
	,@StatusSFrom datetime, @StatusPFrom datetime, @StatusWFrom datetime				

	DECLARE cur_TypObiektuInst_UPDATE CURSOR FOR
		SELECT Id, Nazwa, ValidFrom, CreatedBy, IdArchLink, ObowiazujeOd, ObowiazujeDo,
			IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom
		FROM deleted
	OPEN cur_TypObiektuInst_UPDATE 
	FETCH NEXT FROM cur_TypObiektuInst_UPDATE INTO @ID, @Nazwa, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo,
		@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
	WHILE @@fetch_status = 0
	BEGIN
	
		SELECT @WaznyodNEW = ValidFrom, @CzyWaznyNEW = IsValid, @UtworzonyPrzezNEW = LastModifiedBy, @NazwaNEW = Nazwa,
			@DataModyfikacjiApp = LastModifiedOn, @RealCreatedOn = RealCreatedOn, @RealLastModifiedOn = RealLastModifiedOn
		FROM inserted WHERE ID = @ID
	
		IF @CzyWaznyNEW = 1
		BEGIN
			
			INSERT INTO [dbo].[_Czynność nietabelaryczna]
			   ([IdArch], IdArchLink, Nazwa, [IsValid], [ValidFrom], [ValidTo], [CreatedOn], [CreatedBy], [LastModifiedOn], [LastModifiedBy], 
			   ObowiazujeOD, ObowiazujeDo, RealCreatedOn, RealLastModifiedOn,
			   IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, 
			   StatusWFrom, StatusSTo, StatusPTo, StatusWTo, StatusSToBy, StatusPToBy, StatusWToBy)
	    
			SELECT @ID,ISNULL(@IdArchLink,@ID), @Nazwa, 0, @WaznyOd, @DataModyfikacjiApp, @WaznyOd, @UtworzonyPrzez, @DataModyfikacjiApp, @UtworzonyPrzezNEW, 
				@ObowiazujeOD, @ObowiazujeDo, @RealCreatedOn, @RealLastModifiedOn,
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

			UPDATE [dbo].[_Czynność nietabelaryczna]
			SET ValidFrom = @DataModyfikacjiApp
			,[CreatedBy] = @UtworzonyPrzezNEW
			,LastModifiedOn = NULL
			,LastModifiedBy = NULL
			,CreatedOn = ISNULL(@DataModyfikacjiApp, @WaznyodNEW)
			,RealCreatedOn = ISNULL(@RealLastModifiedOn, @RealCreatedOn)
			,RealDeletedFrom = NULL
			,RealLastModifiedOn = NULL
			,IdArchLink = @hist
			,IdArch = NULL
			WHERE ID = @ID
		END
	
			FETCH NEXT FROM cur_TypObiektuInst_UPDATE INTO @ID, @Nazwa, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo,
				@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
	END
	
	CLOSE cur_TypObiektuInst_UPDATE
	DEALLOCATE cur_TypObiektuInst_UPDATE	
END	
GO
			
CREATE TRIGGER [dbo].[WartoscZmiany_Czynność nietabelaryczna_INSERT]
   ON  [dbo].[_Czynność nietabelaryczna] 
   AFTER INSERT
AS 
BEGIN
	DECLARE @ID int, @Nazwa nvarchar(64)
	,@WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int, @Wersja int
	,@ObowiazujeOD datetime, @ObowiazujeDo datetime

	DECLARE @maxDt date = '9999-12-31'
	
	select @ID = ID, @IdArchLink = IdArchLink
	FROM inserted

	IF (@IdArchLink IS NULL)
	BEGIN
		IF EXISTS(
			SELECT S1.Nazwa,
			  S1.ID AS key1, S1.ObowiazujeOd AS start1, S1.ObowiazujeDo AS end1,
			  S2.ID AS key2, S2.ObowiazujeOd AS start2, S2.ObowiazujeDo AS end2
			FROM inserted AS S1
			  JOIN [dbo].[_Czynność nietabelaryczna] AS S2
				ON  S2.Nazwa = S1.Nazwa
				AND (COALESCE(S2.ObowiazujeDo, @maxDt) >= COALESCE(S1.ObowiazujeOd, @maxDt)
					 AND COALESCE(S2.ObowiazujeOd, @maxDt) <= COALESCE(S1.ObowiazujeDo, @maxDt))
			WHERE S1.Id = @id AND S1.ID <> S2.ID
		)	
		BEGIN						
		
			UPDATE [dbo].[_Czynność nietabelaryczna] 
			SET IsAlternativeHistory=1
			, IsMainHistFlow=0
			WHERE Id = @id						
		END
	END
END	
GO
DISABLE TRIGGER [dbo].[WartoscZmiany_Czynność nietabelaryczna_INSERT]
    ON [dbo].[_Czynność nietabelaryczna];

