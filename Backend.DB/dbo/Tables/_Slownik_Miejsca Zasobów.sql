CREATE TABLE [dbo].[_Slownik_Miejsca Zasobów] (
    [Id]                   INT             IDENTITY (1, 1) NOT NULL,
    [IdArch]               INT             NULL,
    [IdArchLink]           INT             NULL,
    [Nazwa]                NVARCHAR (200)  NOT NULL,
    [NazwaSkrocona]        NVARCHAR (50)   NULL,
    [NazwaPelna]           NVARCHAR (200)  NULL,
    [Uwagi]                NVARCHAR (MAX)  NULL,
    [TypId]                INT             NOT NULL,
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
    CONSTRAINT [PK2_Slownik_Miejsca Zasobów] PRIMARY KEY NONCLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Slownik_Miejsca Zasobów_IdArch] FOREIGN KEY ([IdArch]) REFERENCES [dbo].[_Slownik_Miejsca Zasobów] ([Id]),
    CONSTRAINT [FK_Slownik_Miejsca Zasobów_IdArchLink] FOREIGN KEY ([IdArchLink]) REFERENCES [dbo].[_Slownik_Miejsca Zasobów] ([Id]),
    CONSTRAINT [FK_Slownik_Miejsca Zasobów_TypId] FOREIGN KEY ([TypId]) REFERENCES [dbo].[Cecha_Typy] ([Id])
);


GO
CREATE CLUSTERED INDEX [PK_Slownik_Miejsca Zasobów]
    ON [dbo].[_Slownik_Miejsca Zasobów]([Id] ASC);


GO

				CREATE TRIGGER [dbo].[WartoscZmiany_Slownik_Miejsca Zasobów_UPDATE]
				   ON [dbo].[_Slownik_Miejsca Zasobów] 
				   AFTER UPDATE
				AS 
				BEGIN
					SET NOCOUNT ON;
					
					--IF(UPDATE(IsDeleted)) RETURN;

					DECLARE @ID int, @Nazwa nvarchar(200), @NazwaSkrocona nvarchar(50), @NazwaPelna nvarchar(200), @Uwagi nvarchar(MAX), @WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int
						,@ZmianaOd datetime, @ZmianaDo datetime, @ObowiazujeOD datetime, @ObowiazujeDo datetime, @TypId int, @WaznyOdNEW datetime, @UtworzonyPrzezNEW int, @CzyWaznyNEW bit
						,@hist int, @NazwaNEW nvarchar(64), @DataModyfikacjiApp datetime, @RealCreatedOn datetime, @RealLastModifiedOn datetime, @IsStatus bit, @StatusS int, @StatusW int 
						,@StatusP int, @StatusSBy int, @StatusPBy int, @StatusWBy int, @StatusSFrom datetime, @StatusPFrom datetime, @StatusWFrom datetime				

					DECLARE curSl_UPDATE CURSOR FOR
						SELECT ID, Nazwa, NazwaSkrocona, NazwaPelna, Uwagi, ValidFrom, CreatedBy, IdArchLink, ObowiazujeOd, ObowiazujeDo, TypId,
							IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom 
						FROM deleted
					OPEN curSl_UPDATE 
					FETCH NEXT FROM curSl_UPDATE INTO @ID, @Nazwa, @NazwaSkrocona, @NazwaPelna, @Uwagi, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOd, @ObowiazujeDo, @TypId,
						@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
					WHILE @@fetch_status = 0
					BEGIN
					
						SELECT @WaznyodNEW = ValidFrom, @CzyWaznyNEW = IsValid, @UtworzonyPrzezNEW = LastModifiedBy, @NazwaNEW = Nazwa,
						@DataModyfikacjiApp = LastModifiedOn, @RealCreatedOn = RealCreatedOn, @RealLastModifiedOn = RealLastModifiedOn
						FROM inserted WHERE ID = @ID
					
						IF(@CzyWaznyNEW = 1 AND NOT UPDATE(IsAlternativeHistory))
						BEGIN
							
							INSERT INTO [dbo].[_Slownik_Miejsca Zasobów]
							   ([IdArch],IdArchLink, Nazwa, NazwaSkrocona, NazwaPelna, Uwagi, [IsValid], [ValidFrom], [ValidTo], [CreatedOn], [CreatedBy], [LastModifiedOn], 
							   [LastModifiedBy], ObowiazujeOd, ObowiazujeDo, TypId, RealCreatedOn, RealLastModifiedOn,
							   IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom, StatusSTo, StatusPTo, StatusWTo, StatusSToBy, StatusPToBy, StatusWToBy)					    
							SELECT @ID,ISNULL(@IdArchLink,@ID), @Nazwa, @NazwaSkrocona, @NazwaPelna, @Uwagi, 0, @WaznyOd, @DataModyfikacjiApp, @WaznyOd, @UtworzonyPrzez  
								,@DataModyfikacjiApp, @UtworzonyPrzezNEW, @ObowiazujeOd, @ObowiazujeDo, @TypId, @RealCreatedOn, @RealLastModifiedOn,
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

							UPDATE [dbo].[_Slownik_Miejsca Zasobów]
							SET ValidFrom = @WaznyOdNEW
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
					
						FETCH NEXT FROM curSl_UPDATE into @ID, @Nazwa, @NazwaSkrocona, @NazwaPelna, @Uwagi, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOd, @ObowiazujeDo, @TypId,
							@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
					END
					
					CLOSE curSl_UPDATE
					DEALLOCATE curSl_UPDATE	
				END
GO
CREATE TRIGGER [dbo].[WartoscZmiany_Slownik_Miejsca Zasobów_INSERT]
				   ON  [dbo].[_Slownik_Miejsca Zasobów] 
				   AFTER INSERT
				AS 
				BEGIN
					declare @ID int, @Nazwa nvarchar(64)
					,@WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int
					,@ObowiazujeOD datetime, @ObowiazujeDo datetime

					Declare @maxDt date = '9999-12-31'
					
					select @ID = ID , @IdArchLink = IdArchLink
					FROM inserted

					IF (@IdArchLink IS NULL)
					BEGIN
						IF EXISTS(
							SELECT S1.Nazwa,
							  S1.ID AS key1, S1.ObowiazujeOd AS start1, S1.ObowiazujeDo AS end1,
							  S2.ID AS key2, S2.ObowiazujeOd AS start2, S2.ObowiazujeDo AS end2
							FROM inserted AS S1
							  JOIN [dbo].[_Slownik_Miejsca Zasobów]  AS S2
								ON  S2.Nazwa = S1.Nazwa
								AND (COALESCE(S2.ObowiazujeDo,@maxDt) >= COALESCE(S1.ObowiazujeOd,@maxDt)
									 AND COALESCE(S2.ObowiazujeOd, @maxDt) <= COALESCE(S1.ObowiazujeDo,@maxDt))
							WHERE S1.Id = @id AND S1.ID <> S2.ID
						)	
						BEGIN						
						
							UPDATE [dbo].[_Slownik_Miejsca Zasobów] SET 
							IsAlternativeHistory = 1
							, IsMainHistFlow = 0
							WHERE Id = @id
						
						END
					END
				END
GO
DISABLE TRIGGER [dbo].[WartoscZmiany_Slownik_Miejsca Zasobów_INSERT]
    ON [dbo].[_Slownik_Miejsca Zasobów];

