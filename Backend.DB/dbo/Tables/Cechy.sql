CREATE TABLE [dbo].[Cechy] (
    [TableID]                     INT             NULL,
    [Cecha_ID]                    INT             IDENTITY (1, 1) NOT NULL,
    [IdArch]                      INT             NULL,
    [IdArchLink]                  INT             NULL,
    [IsValid]                     BIT             CONSTRAINT [DF_CechyPodstawowe_IsValid] DEFAULT ((1)) NULL,
    [ValidFrom]                   DATETIME        CONSTRAINT [DF_CechyPodstawowe_ValidFrom] DEFAULT (getdate()) NOT NULL,
    [ValidTo]                     DATETIME SPARSE NULL,
    [Nazwa]                       NVARCHAR (50)   NOT NULL,
    [NazwaSkrocona]               NVARCHAR (50)   NULL,
    [Hint]                        NVARCHAR (200)  NULL,
    [Opis]                        NVARCHAR (500)  NULL,
    [WartoscSlownika]             NVARCHAR (50)   NULL,
    [TypID]                       INT             NOT NULL,
    [Format]                      VARCHAR (50)    NULL,
    [CzyWymagana]                 BIT             CONSTRAINT [DF_CechyPodstawowe_WartoscWymagana] DEFAULT ((1)) NOT NULL,
    [CzyPusta]                    BIT             CONSTRAINT [DF_CechyPodstawowe_CzyPusta] DEFAULT ((1)) NOT NULL,
    [CzyWyliczana]                BIT             CONSTRAINT [DF_CechyPodstawowe_CzyWyliczana] DEFAULT ((0)) NOT NULL,
    [CzyPrzetwarzana]             BIT             CONSTRAINT [DF_CechyPodstawowe_CzyPrzetwarzana] DEFAULT ((0)) NOT NULL,
    [CzyFiltrowana]               BIT             CONSTRAINT [DF_CechyPodstawowe_CzyFiltorwana] DEFAULT ((0)) NOT NULL,
    [CzyJestDanaOsobowa]          BIT             CONSTRAINT [DF_CechyPodstawowe_CzyJestDanaOsobowa] DEFAULT ((0)) NOT NULL,
    [WartoscDomyslna]             NVARCHAR (20)   NULL,
    [ListaWartosciDopuszczalnych] NVARCHAR (MAX)  NULL,
    [CzyCechaUzytkownika]         BIT             CONSTRAINT [DF_CechyPodstawowe_CzyCechaUzytkownika] DEFAULT ((0)) NULL,
    [StatusA]                     VARCHAR (3)     NULL,
    [StatusB]                     VARCHAR (3)     NULL,
    [StatusC]                     VARCHAR (3)     NULL,
    [Widocznosc]                  VARCHAR (2)     NULL,
    [IsDeleted]                   BIT             CONSTRAINT [DF_Cechy_IsDeleted] DEFAULT ((0)) NOT NULL,
    [DeletedFrom]                 DATETIME SPARSE NULL,
    [DeletedBy]                   INT SPARSE      NULL,
    [CreatedOn]                   DATETIME        CONSTRAINT [DF_Cechy_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]                   INT             NULL,
    [LastModifiedOn]              DATETIME SPARSE NULL,
    [LastModifiedBy]              INT SPARSE      NULL,
    [IsStatus]                    BIT             CONSTRAINT [DF_Cechy_IsStatus] DEFAULT ((0)) NOT NULL,
    [StatusS]                     INT SPARSE      NULL,
    [StatusSFrom]                 DATETIME SPARSE NULL,
    [StatusSTo]                   DATETIME SPARSE NULL,
    [StatusSFromBy]               INT SPARSE      NULL,
    [StatusSToBy]                 INT SPARSE      NULL,
    [StatusW]                     INT SPARSE      NULL,
    [StatusWFrom]                 DATETIME SPARSE NULL,
    [StatusWTo]                   DATETIME SPARSE NULL,
    [StatusWFromBy]               INT SPARSE      NULL,
    [StatusWToBy]                 INT SPARSE      NULL,
    [StatusP]                     INT SPARSE      NULL,
    [StatusPFrom]                 DATETIME SPARSE NULL,
    [StatusPTo]                   DATETIME SPARSE NULL,
    [StatusPFromBy]               INT SPARSE      NULL,
    [StatusPToBy]                 INT SPARSE      NULL,
    [ObowiazujeOd]                DATETIME        NULL,
    [ObowiazujeDo]                DATETIME SPARSE NULL,
    [IsAlternativeHistory]        BIT             DEFAULT ((0)) NULL,
    [IsMainHistFlow]              BIT             DEFAULT ((0)) NULL,
    [ControlSize]                 INT             CONSTRAINT [DF_Cechy_ControlSize] DEFAULT ((1)) NULL,
    [JednostkaMiary]              INT             NULL,
    [CzySlownik]                  BIT             DEFAULT ((0)) NOT NULL,
    [RealCreatedOn]               DATETIME        DEFAULT (getdate()) NOT NULL,
    [RealLastModifiedOn]          DATETIME SPARSE NULL,
    [RealDeletedFrom]             DATETIME SPARSE NULL,
    [PrzedzialCzasowyId]          INT             DEFAULT ((4)) NULL,
    [CharakterChwilowy]           BIT             DEFAULT ((0)) NOT NULL,
    [RelationTypeId]              INT             NULL,
    [UnitTypeId]                  INT             NULL,
    [IsBlocked]                   BIT             DEFAULT ((0)) NOT NULL,
    [Sledzona]                    BIT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Cechy] PRIMARY KEY CLUSTERED ([Cecha_ID] ASC) WITH (FILLFACTOR = 80),
    FOREIGN KEY ([PrzedzialCzasowyId]) REFERENCES [dbo].[Cecha_PrzedzialCzasowy] ([Id]),
    CONSTRAINT [FK_Cechy_Jednostka] FOREIGN KEY ([JednostkaMiary]) REFERENCES [dbo].[JednostkiMiary] ([Id]),
    CONSTRAINT [FK_Cechy_RelationTypeId] FOREIGN KEY ([RelationTypeId]) REFERENCES [dbo].[TypRelacji] ([TypRelacji_ID])
);


GO
-- =============================================
-- Author:		DK
-- Create date: 2012-06-13
-- Last modified on: 2013-01-25
-- Description:	
-- =============================================
CREATE TRIGGER [dbo].[WartoscZmiany_Cechy_UPDATE]
ON [dbo].[Cechy] AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @ID int, @Nazwa nvarchar(50)
	,@NazwaSkrocona nvarchar(50),@Opis nvarchar(500),@Hint nvarchar(200)
	,@WartoscSlownika nvarchar(50), @TypID int, @Format varchar(50),@CzyWymagana bit
	,@CzyPusta bit, @CzyWyliczana bit, @CzyPrzetwarzana bit, @CzyFiltrowana bit,@CzyJestDanaOsobowa bit
	,@WartoscDomyslna nvarchar(20),@ListaWartosciDopuszczalnych nvarchar(max)
	,@CzyCechaUzytkownika bit,@StatusA varchar(3),@StatusB varchar(3),@StatusC varchar(3)
	,@Widocznosc varchar(2), @WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int
	,@ZmianaOd datetime, @ZmianaDo datetime, @ObowiazujeOD datetime
	,@ObowiazujeDo datetime, @WaznyOdNEW datetime, @UtworzonyPrzezNEW int, @CzyWaznyNEW bit
	,@NazwaNEW nvarchar(64), @DataModyfikacjiApp datetime, @RealCreatedOn datetime
	,@RealLastModifiedOn datetime, @hist int, @CharakterChwilowy bit, @PrzedzialCzasowyId int, 
	@IsStatus bit, @StatusS int, @StatusW int, @StatusP int, @StatusSBy int, @StatusPBy int, @StatusWBy int, 
	@StatusSFrom datetime, @StatusPFrom datetime, @StatusWFrom datetime, @UnitTypeId int, @RelationTypeId int, @Sledzona bit

	DECLARE cur_Cechy_UPDATE CURSOR FOR
		SELECT Cecha_ID, ValidFrom , CreatedBy, IdArchLink, ObowiazujeOd, ObowiazujeDo, Nazwa, NazwaSkrocona, Hint, Opis, WartoscSlownika, TypID, 
		Format, CzyWymagana, CzyPusta, CzyWyliczana, CzyPrzetwarzana, CzyFiltrowana, CzyJestDanaOsobowa, WartoscDomyslna, ListaWartosciDopuszczalnych, CzyCechaUzytkownika, StatusA
		,StatusB, StatusC, Widocznosc, CharakterChwilowy, PrzedzialCzasowyId, IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, 
		StatusPFrom, StatusWFrom, UnitTypeId, RelationTypeId, Sledzona
		FROM deleted
	OPEN cur_Cechy_UPDATE 
	FETCH NEXT FROM cur_Cechy_UPDATE INTO @ID, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOd, @ObowiazujeDo, @Nazwa, @NazwaSkrocona, @Hint, @Opis, 
		@WartoscSlownika, @TypID, @Format, @CzyWymagana, @CzyPusta, @CzyWyliczana, @CzyPrzetwarzana, @CzyFiltrowana, @CzyJestDanaOsobowa, @WartoscDomyslna, @ListaWartosciDopuszczalnych, 
		@CzyCechaUzytkownika, @StatusA, @StatusB, @StatusC, @Widocznosc, @CharakterChwilowy, @PrzedzialCzasowyId, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, 
		@StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, @UnitTypeId, @RelationTypeId, @Sledzona
	WHILE @@fetch_status = 0
	BEGIN
				
		SELECT @WaznyodNEW = ValidFrom, @CzyWaznyNEW = IsValid, @UtworzonyPrzezNEW = LastModifiedBy, @NazwaNEW = Nazwa, 
		@DataModyfikacjiApp = LastModifiedOn, @RealCreatedOn = RealCreatedOn, @RealLastModifiedOn = RealLastModifiedOn
		FROM inserted WHERE Cecha_ID = @ID
	
		IF(@CzyWaznyNEW = 1)
		BEGIN
		
			--wpisywanie NULL w pole obowiazujeDo
			SET @ObowiazujeDo = NULL;
		
			INSERT INTO [dbo].Cechy
			   ([IdArch], IdArchLink, [IsValid], [ValidFrom], [ValidTo], [CreatedOn], [CreatedBy], [LastModifiedOn], [LastModifiedBy], ObowiazujeOd, ObowiazujeDo
			   ,Nazwa, NazwaSkrocona, Hint, Opis, WartoscSlownika, TypID, Format, CzyWymagana, CzyPusta, CzyWyliczana, CzyPrzetwarzana, CzyFiltrowana, CzyJestDanaOsobowa, WartoscDomyslna
				,ListaWartosciDopuszczalnych, CzyCechaUzytkownika, UnitTypeId, RelationTypeId, StatusA, StatusB, StatusC, Widocznosc, RealCreatedOn, RealLastModifiedOn, 
				CharakterChwilowy, PrzedzialCzasowyId, Sledzona, IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, 
				StatusWFrom, StatusSTo, StatusPTo, StatusWTo, StatusSToBy, StatusPToBy, StatusWToBy)
	    
			SELECT @ID,ISNULL(@IdArchLink,@ID), 0, @WaznyOd, @DataModyfikacjiApp, @WaznyOd, @UtworzonyPrzez,@DataModyfikacjiApp, @UtworzonyPrzezNEW,
				@ObowiazujeOD, @ObowiazujeDo, @Nazwa, @NazwaSkrocona, @Hint, @Opis, @WartoscSlownika, @TypID, @Format, @CzyWymagana, @CzyPusta, @CzyWyliczana, @CzyPrzetwarzana
				,@CzyFiltrowana, @CzyJestDanaOsobowa, @WartoscDomyslna, @ListaWartosciDopuszczalnych, @CzyCechaUzytkownika, @UnitTypeId, @RelationTypeId,
				@StatusA, @StatusB, @StatusC, @Widocznosc, @RealCreatedOn, 
				@RealLastModifiedOn, @CharakterChwilowy, @PrzedzialCzasowyId, @Sledzona, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, 
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

			UPDATE dbo.Cechy
			SET ValidFrom = ISNULL(@DataModyfikacjiApp, GETDATE())
			,[CreatedBy] = @UtworzonyPrzezNEW
			,LastModifiedOn = NULL
			,LastModifiedBy = NULL
			,CreatedOn = ISNULL(@DataModyfikacjiApp, @WaznyodNEW)
			,RealCreatedOn = ISNULL(@RealLastModifiedOn, @RealCreatedOn)
			,RealLastModifiedOn = NULL
			,IdArchLink = @hist
			,IdArch = NULL
			WHERE Cecha_ID = @ID

		END
				
	FETCH NEXT FROM cur_Cechy_UPDATE INTO @ID, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo, @Nazwa, @NazwaSkrocona, @Hint, @Opis, 
		@WartoscSlownika, @TypID, @Format, @CzyWymagana, @CzyPusta, @CzyWyliczana, @CzyPrzetwarzana, @CzyFiltrowana, @CzyJestDanaOsobowa, @WartoscDomyslna, @ListaWartosciDopuszczalnych, 
		@CzyCechaUzytkownika, @StatusA, @StatusB, @StatusC, @Widocznosc, @CharakterChwilowy, @PrzedzialCzasowyId, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, 
		@StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, @UnitTypeId, @RelationTypeId, @Sledzona
	END
	
	CLOSE cur_Cechy_UPDATE
	DEALLOCATE cur_Cechy_UPDATE	
	
END
