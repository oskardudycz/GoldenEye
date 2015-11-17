CREATE TABLE [dbo].[TypObiektu] (
    [TableID]                INT             NULL,
    [TypObiekt_ID]           INT             IDENTITY (1, 1) NOT NULL,
    [IdArch]                 INT             NULL,
    [IdArchLink]             INT             NULL,
    [Nazwa]                  NVARCHAR (256)  NOT NULL,
    [CzyPrzechowujeHistorie] BIT             CONSTRAINT [DF__TypObiekt__CzyPr__7F60ED59] DEFAULT ((1)) NULL,
    [IsStatus]               BIT             CONSTRAINT [DF_TypObiektu_IsStatus] DEFAULT ((0)) NOT NULL,
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
    [IsValid]                BIT             CONSTRAINT [DF_TypObiektu_IsValid_1] DEFAULT ((1)) NULL,
    [ValidFrom]              DATETIME        CONSTRAINT [DF_TypObiektu_ValidFrom_1] DEFAULT (getdate()) NOT NULL,
    [ValidTo]                DATETIME SPARSE NULL,
    [IsDeleted]              BIT             CONSTRAINT [DF_TypObiektu_IsDeleted] DEFAULT ((0)) NOT NULL,
    [DeletedFrom]            DATETIME SPARSE NULL,
    [DeletedBy]              INT SPARSE      NULL,
    [CreatedOn]              DATETIME        CONSTRAINT [DF_TypObiektu_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]              INT             NULL,
    [LastModifiedOn]         DATETIME SPARSE NULL,
    [LastModifiedBy]         INT SPARSE      NULL,
    [RealCreatedOn]          DATETIME        DEFAULT (getdate()) NOT NULL,
    [RealLastModifiedOn]     DATETIME SPARSE NULL,
    [RealDeletedFrom]        DATETIME SPARSE NULL,
    [Tabela]                 BIT             DEFAULT ((0)) NOT NULL,
    [IsBlocked]              BIT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_TypObiektu] PRIMARY KEY CLUSTERED ([TypObiekt_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [CHK_TypObiektu_Nazwa] CHECK ([Nazwa]<>'' AND charindex('.',[Nazwa])=(0)),
    CONSTRAINT [FK_TypObiektu_IdArch] FOREIGN KEY ([IdArch]) REFERENCES [dbo].[TypObiektu] ([TypObiekt_ID]),
    CONSTRAINT [FK_TypObiektu_IdArchLink] FOREIGN KEY ([IdArchLink]) REFERENCES [dbo].[TypObiektu] ([TypObiekt_ID])
);


GO

CREATE TRIGGER [dbo].[RemoveTablesForTypObiektu]
   ON  [dbo].[TypObiektu]
   AFTER DELETE
AS 
BEGIN
	SET NOCOUNT ON;
	
	--usuwanie tabel tymczasowych, jesli istnieja
	IF OBJECT_ID('tempdb..#UsunieteTypyObiektow') IS NOT NULL
		DROP TABLE #UsunieteTypyObiektow
		
	SELECT Nazwa, CzyPrzechowujeHistorie
	INTO #UsunieteTypyObiektow
	FROM DELETED
	
	--DECLARE @IsValid bit = (SELECT IsValid FROM DELETED);
	DECLARE @CzyHistoria bit; -- = (SELECT TOP 1 CzyPrzechowujeHistorie FROM DELETED)
	DECLARE @Nazwa nvarchar(256); -- = (SELECT TOP 1 Nazwa FROM DELETED)
	DECLARE @NazwaCechy nvarchar(256)
	DECLARE @query_drop_obiekt nvarchar(256)
	DECLARE @query_drop_cechy nvarchar(256)
	DECLARE @query_drop_relacje nvarchar(256)
	
	--sprawdzenie czy kursor istnieje, jesli tak to go usuwa
	IF Cursor_Status('local','cur20') > 0 
	BEGIN
		 CLOSE cur20
		 DEALLOCATE cur20
	END

	DECLARE cur20 CURSOR LOCAL FOR 
		SELECT Nazwa, CzyPrzechowujeHistorie FROM #UsunieteTypyObiektow
	OPEN cur20
	FETCH NEXT FROM cur20 INTO @Nazwa, @CzyHistoria
	WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @query_drop_obiekt = N'DROP TABLE [dbo].[_' + @Nazwa + ']'	
		SET @query_drop_relacje = N'DROP TABLE [dbo].[_' + @Nazwa + '_Relacje_Hist]'
		 
		IF(@CzyHistoria > 0)
		BEGIN
			SET @NazwaCechy = '_' + @Nazwa + N'_Cechy_Hist]'
		END
			
		SET @query_drop_cechy = N'DROP TABLE [dbo].['+@NazwaCechy
		
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].['+@NazwaCechy) AND type in (N'U'))
			exec (@query_drop_cechy)
			
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_' + @Nazwa + '_Relacje_Hist]') AND type in (N'U'))
			exec (@query_drop_relacje)
		
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_' + @Nazwa + ']') AND type in (N'U'))
			exec (@query_drop_obiekt)	
			
		FETCH NEXT FROM cur20 INTO @Nazwa, @CzyHistoria
	END
	CLOSE cur20;
	DEALLOCATE cur20;
	
	IF OBJECT_ID('tempdb..#UsunieteTypyObiektow') IS NOT NULL
		DROP TABLE #UsunieteTypyObiektow
END


GO
-- =============================================
-- Author:		DW/DK
-- Create date: 2011-08-23
-- Last modified on: 2013-01-24
-- Description:	
-- =============================================
CREATE TRIGGER [dbo].[WartoscZmiany_TypObiektu_UPDATE]
ON [dbo].[TypObiektu] AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @ID int, @Struktura_ObiektID int, @Nazwa nvarchar(64)
	,@WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int, @hist int
	, @ObowiazujeOD datetime
	,@ObowiazujeDo datetime, @WaznyOdNEW datetime, @UtworzonyPrzezNEW int, @CzyWaznyNEW bit
	,@NazwaNEW nvarchar(64), @DataModyfikacjiApp datetime, @RealCreatedOn datetime, @RealLastModifiedOn datetime,
	@IsStatus bit, @StatusS int, @StatusW int, @StatusP int, @StatusSBy int, @StatusPBy int, @StatusWBy int, 
	@StatusSFrom datetime, @StatusPFrom datetime, @StatusWFrom datetime, @Tabela bit
	
	DECLARE cur_TypObiektu_UPDATE CURSOR FOR
		SELECT TypObiekt_ID, ValidFrom, CreatedBy, IdArchLink, ObowiazujeOD, ObowiazujeDo, Nazwa, Tabela,
			IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom 
		FROM deleted
	OPEN cur_TypObiektu_UPDATE 
	FETCH NEXT FROM cur_TypObiektu_UPDATE INTO @ID, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo, @Nazwa, @Tabela,
		@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
	WHILE @@fetch_status = 0
	BEGIN
	
		SELECT @WaznyodNEW = ValidFrom, @CzyWaznyNEW = IsValid, @UtworzonyPrzezNEW = LastModifiedBy, @NazwaNEW = Nazwa,
		@DataModyfikacjiApp = LastModifiedOn, @RealCreatedOn = RealCreatedOn, @RealLastModifiedOn = RealLastModifiedOn
		FROM inserted WHERE TypObiekt_ID = @ID
	
		IF(@CzyWaznyNEW = 1)
		BEGIN	
		
			SET @ObowiazujeDo = NULL;							
		/*	
			Przeniesione do UnitTypes_Save i UpdatesTriggersForUnitTypes
			
			DECLARE @OldN nvarchar(64) = '_'+@Nazwa
			DECLARE @NewN nvarchar(64) = '_'+@NazwaNEW
			
			IF @OldN <> @NewN
				EXEC sp_rename @OldN, @NewN
			
			SET @OldN = '_' + @Nazwa + '_Cechy_Hist'
			SET @NewN = '_' + @NazwaNEW + '_Cechy_Hist'
			
			IF @OldN <> @NewN
				EXEC sp_rename @OldN, @NewN

			SET @OldN = '_' + @Nazwa + '_Relacje_Hist'
			SET @NewN = '_' + @NazwaNEW + '_Relacje_Hist'
			
			IF @OldN <> @NewN
				EXEC sp_rename @OldN, @NewN
				
			--zmiana nazwy triggerow
			SET @OldN = 'WartoscZmiany_' + @Nazwa + '_INSERT';
			SET @NewN = 'WartoscZmiany_' + @NazwaNEW + '_INSERT';
			
			IF @OldN <> @NewN
				EXEC sp_rename @OldN, @NewN
				
			SET @OldN = 'WartoscZmiany_' + @Nazwa + '_UPDATE';
			SET @NewN = 'WartoscZmiany_' + @NazwaNEW + '_UPDATE';
			
			IF @OldN <> @NewN
				EXEC sp_rename @OldN, @NewN
				
			-- cechy
			SET @OldN = 'WartoscZmiany_' + @Nazwa + '_Cechy_Hist_INSERT';
			SET @NewN = 'WartoscZmiany_' + @NazwaNEW + '_Cechy_Hist_INSERT';
			
			IF @OldN <> @NewN
				EXEC sp_rename @OldN, @NewN
				
			SET @OldN = 'WartoscZmiany_' + @Nazwa + '_Cechy_Hist_UPDATE';
			SET @NewN = 'WartoscZmiany_' + @NazwaNEW + '_Cechy_Hist_UPDATE';
			
			IF @OldN <> @NewN
				EXEC sp_rename @OldN, @NewN
				
			--relacje
			SET @OldN = 'WartoscZmiany_' + @Nazwa + '_Relacje_Hist_INSERT';
			SET @NewN = 'WartoscZmiany_' + @NazwaNEW + '_Relacje_Hist_INSERT';
			
			IF @OldN <> @NewN
				EXEC sp_rename @OldN, @NewN
				
			SET @OldN = 'WartoscZmiany_' + @Nazwa + '_Relacje_Hist_UPDATE';
			SET @NewN = 'WartoscZmiany_' + @NazwaNEW + '_Relacje_Hist_UPDATE';
			
			IF @OldN <> @NewN
				EXEC sp_rename @OldN, @NewN
				*/
			
			INSERT INTO [dbo].TypObiektu
			   ([IdArch], IdArchLink, [IsValid], [ValidFrom], [ValidTo], [CreatedOn], [CreatedBy], [LastModifiedOn], [LastModifiedBy], ObowiazujeOd, 
			   ObowiazujeDo, Nazwa, Tabela, RealCreatedOn, RealLastModifiedOn, IsStatus, StatusS, StatusP, StatusW, 
			   StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom, StatusSTo, StatusPTo, StatusWTo, StatusSToBy, StatusPToBy, StatusWToBy)
	    
			SELECT @ID, ISNULL(@IdArchLink,@ID), 0, @WaznyOd, @WaznyodNEW, @WaznyOd, @UtworzonyPrzez, @DataModyfikacjiApp, @UtworzonyPrzezNEW, @ObowiazujeOd, 
				@ObowiazujeDo, @Nazwa, @Tabela, @RealCreatedOn, @RealLastModifiedOn, @IsStatus, @StatusS, @StatusP, 
				@StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, 
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

			SELECT @hist = @@IDENTITY;

			UPDATE dbo.TypObiektu
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
			WHERE TypObiekt_ID = @ID

		END
	
		FETCH NEXT FROM cur_TypObiektu_UPDATE INTO @ID, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo, @Nazwa, @Tabela,
			@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
	END
	
	CLOSE cur_TypObiektu_UPDATE
	DEALLOCATE cur_TypObiektu_UPDATE	
		
END

GO

CREATE TRIGGER [dbo].[CreateTableForTypObiektu]
   ON  [dbo].[TypObiektu]
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @NowaNazwa NVARCHAR(256)
	SELECT @NowaNazwa =(SELECT Nazwa FROM INSERTED)
	
	DECLARE  @CzyHistoria bit,
			@CzyTabela bit,
			@IdArch int,
			@str nvarchar(max)
	
	--pobranie danych wstawionego typu obiektu
	SELECT @CzyHistoria = CzyPrzechowujeHistorie, @IdArch = IdArch, @CzyTabela = Tabela
	FROM inserted
	
	IF (@IdArch IS NULL)
	BEGIN
		
		IF OBJECT_ID (N'[_' + @NowaNazwa + ']', N'U') IS NULL
		BEGIN
			SET @str = '
			CREATE TABLE [dbo].[_' + @NowaNazwa + '](
					[Id] [int] IDENTITY(1,1) NOT NULL,
					[IdArch] [int] NULL,
					[IdArchLink] [int] NULL,
					--[Wersja] [int] NOT NULL DEFAULT(0),
					[Nazwa] nvarchar(256) not null,
					[IsAlternativeHistory] [bit] DEFAULT(0),
					[IsMainHistFlow] [bit] DEFAULT(1),
					[IsStatus] [bit] NOT NULL DEFAULT (0),
					[StatusS] [int] SPARSE NULL,
					[StatusSFrom] [datetime] SPARSE NULL,
					[StatusSTo] [datetime] SPARSE NULL,
					[StatusSFromBy] [int] SPARSE NULL,
					[StatusSToBy] [int] SPARSE NULL,
					[StatusW] [int] SPARSE NULL,
					[StatusWFrom] [datetime] SPARSE NULL,
					[StatusWTo] [datetime] SPARSE NULL,
					[StatusWFromBy] [int] SPARSE NULL,
					[StatusWToBy] [int] SPARSE NULL,
					[StatusP] [int] SPARSE NULL,
					[StatusPFrom] [datetime] SPARSE NULL,
					[StatusPTo] [datetime] SPARSE NULL,
					[StatusPFromBy] [int] SPARSE NULL,
					[StatusPToBy] [int] SPARSE NULL,
					[ObowiazujeOd] [datetime] NULL,
					[ObowiazujeDo] [datetime] SPARSE NULL,
					[IsValid] [bit] NOT NULL DEFAULT(1),
					[ValidFrom] [datetime] NOT NULL DEFAULT(GETDATE()),
					[ValidTo] [datetime] SPARSE NULL,
					[IsDeleted] [bit] NOT NULL DEFAULT (0),
					[DeletedFrom] [datetime] SPARSE NULL,
					[DeletedBy] [int] SPARSE NULL,
					[CreatedOn] [datetime] NOT NULL DEFAULT(GETDATE()),
					[CreatedBy] [int] NULL,
					[LastModifiedOn] [datetime] SPARSE NULL,
					[LastModifiedBy] [int] SPARSE NULL,
					[RealCreatedOn] datetime NOT NULL DEFAULT(GETDATE()),
					[RealLastModifiedOn] datetime SPARSE NULL,
					[RealDeletedFrom] datetime SPARSE NULL			
					)					
				'
		EXEC( @str)		
			
		SET @str='
			CREATE CLUSTERED INDEX [PK_' + @NowaNazwa + '] ON [dbo].[_' + @NowaNazwa + '] 
			(
				[Id] ASC
			)ON [PRIMARY]
		'
		
				--,[Wersja] ASC
		EXEC(@str)
		
		--index i klucz glowny
		SET @str = '
		ALTER TABLE [_' + @NowaNazwa + '] ADD CONSTRAINT [PK2_' + @NowaNazwa + ']
		PRIMARY KEY NONCLUSTERED(Id);
		'
		EXEC(@str)
		
		-- klucze obce na IdArch i IdArchLink
		SET @str = '
		ALTER TABLE [_' + @NowaNazwa + ']
		ADD CONSTRAINT [FK_' + @NowaNazwa + '_IdArch] FOREIGN KEY (IdArch) REFERENCES [_' + @NowaNazwa + '](Id);

		ALTER TABLE [_' + @NowaNazwa + ']
		ADD CONSTRAINT [FK_' + @NowaNazwa + '_IdArchLink] FOREIGN KEY (IdArchLink) REFERENCES [_' + @NowaNazwa + '](Id);
		'
		EXEC(@str)
	END
	
		IF NOT EXISTS (SELECT name FROM sys.triggers WHERE name = 'WartoscZmiany_' + @NowaNazwa + '_UPDATE')
		BEGIN		
		
			SET @str = '
CREATE TRIGGER [dbo].[WartoscZmiany_' + @NowaNazwa + '_UPDATE]
   ON  [dbo].[_' + @NowaNazwa + '] 
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
			
			INSERT INTO [dbo].[_' + @NowaNazwa + ']
			   ([IdArch], IdArchLink, Nazwa, [IsValid], [ValidFrom], [ValidTo], [CreatedOn], [CreatedBy], [LastModifiedOn], [LastModifiedBy], 
			   ObowiazujeOD, ObowiazujeDo, RealCreatedOn, RealLastModifiedOn,
			   IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, 
			   StatusWFrom, StatusSTo, StatusPTo, StatusWTo, StatusSToBy, StatusPToBy, StatusWToBy)
	   '
	   
	   SET @str += ' 
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

			UPDATE [dbo].[_' + @NowaNazwa + ']
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
END	'
				
			--PRINT @str
			EXEC(@str)
		END
		
		IF NOT EXISTS (SELECT name FROM sys.triggers WHERE name = 'WartoscZmiany_' + @NowaNazwa + '_INSERT')
		BEGIN
			SET @str='			
CREATE TRIGGER [dbo].[WartoscZmiany_' + @NowaNazwa + '_INSERT]
   ON  [dbo].[_' + @NowaNazwa + '] 
   AFTER INSERT
AS 
BEGIN
	DECLARE @ID int, @Nazwa nvarchar(64)
	,@WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int, @Wersja int
	,@ObowiazujeOD datetime, @ObowiazujeDo datetime

	DECLARE @maxDt date = ''9999-12-31''
	
	select @ID = ID, @IdArchLink = IdArchLink
	FROM inserted

	IF (@IdArchLink IS NULL)
	BEGIN
		IF EXISTS(
			SELECT S1.Nazwa,
			  S1.ID AS key1, S1.ObowiazujeOd AS start1, S1.ObowiazujeDo AS end1,
			  S2.ID AS key2, S2.ObowiazujeOd AS start2, S2.ObowiazujeDo AS end2
			FROM inserted AS S1
			  JOIN [dbo].[_' + @NowaNazwa + '] AS S2
				ON  S2.Nazwa = S1.Nazwa
				AND (COALESCE(S2.ObowiazujeDo, @maxDt) >= COALESCE(S1.ObowiazujeOd, @maxDt)
					 AND COALESCE(S2.ObowiazujeOd, @maxDt) <= COALESCE(S1.ObowiazujeDo, @maxDt))
			WHERE S1.Id = @id AND S1.ID <> S2.ID
		)	
		BEGIN						
		
			UPDATE [dbo].[_' + @NowaNazwa + '] 
			SET IsAlternativeHistory=1
			, IsMainHistFlow=0
			WHERE Id = @id						
		END
	END
END	'
				
			--PRINT @str
			EXEC(@str)
		END
		
		--wylaczenie poki co takiego triggera
		SET @str = 'DISABLE TRIGGER [dbo].[WartoscZmiany_' + @NowaNazwa + '_INSERT] ON  [dbo].[_' + @NowaNazwa + ']; '
		EXEC(@str);

		IF (@CzyHistoria > 0 AND @CzyTabela = 0)
		BEGIN
		
			SET @str = 'IF OBJECT_ID (N''[_' + @NowaNazwa + '_Cechy_Hist]'', N''U'') IS NULL
			BEGIN
				CREATE TABLE [dbo].[_' + @NowaNazwa + '_Cechy_Hist](
						[Id] [int] IDENTITY(1,1) NOT NULL,
						[IdArch] [int] NULL,
						[IdArchLink] [int] NULL,
						[ObiektId] [int] NOT NULL, -- FOREIGN KEY REFERENCES [dbo].[_' + @NowaNazwa + '](Id),
						[CechaId] [int] NOT NULL, -- FOREIGN KEY REFERENCES [dbo].[Cechy](Cecha_ID),
						CalculatedByAlgorithm smallint SPARSE NULL, -- FOREIGN KEY REFERENCES Algorytmy(Id),						
						VirtualTypeId smallint SPARSE NULL, -- NOT NULL DEFAULT(0),
						IsValidForAlgorithm bit SPARSE NULL, --NOT NULL DEFAULT(1),
						AlgorithmRun int SPARSE NULL,						
						[ColumnsSet] [xml] COLUMN_SET FOR ALL_SPARSE_COLUMNS  NULL,
						[ValInt] [int] SPARSE  NULL,
						[ValString] [nvarchar](max) NULL,
						[ValFloat] [float] SPARSE  NULL,
						[ValBit] [bit] SPARSE  NULL,
						[ValDecimal] [decimal](12, 5) SPARSE  NULL,
						[ValDatetime] [datetime] SPARSE  NULL,
						[ValDictionary] [int] SPARSE NULL,
						[ValDate] [date] SPARSE  NULL,
						[ValTime] [time](7) SPARSE  NULL,
						[ValXml] xml(Schema_CompositeArithmeticOperationColumn) SPARSE NULL,
						[ValRef] xml(Schema_ValRef) SPARSE NULL,
						[IsAlternativeHistory] [bit] DEFAULT(0),
						[IsMainHistFlow] [bit] DEFAULT(1),
						[IsStatus] [bit] NOT NULL DEFAULT (0),
						[StatusS] [int] SPARSE NULL,
						[StatusSFrom] [datetime] SPARSE NULL,
						[StatusSTo] [datetime] SPARSE NULL,
						[StatusSFromBy] [int] SPARSE NULL,
						[StatusSToBy] [int] SPARSE NULL,
						[StatusW] [int] SPARSE NULL,
						[StatusWFrom] [datetime] SPARSE NULL,
						[StatusWTo] [datetime] SPARSE NULL,
						[StatusWFromBy] [int] SPARSE NULL,
						[StatusWToBy] [int] SPARSE NULL,
						[StatusP] [int] SPARSE NULL,
						[StatusPFrom] [datetime] SPARSE NULL,
						[StatusPTo] [datetime] SPARSE NULL,
						[StatusPFromBy] [int] SPARSE NULL,
						[StatusPToBy] [int] SPARSE NULL,
						[ObowiazujeOd] [datetime] NULL,
						[ObowiazujeDo] [datetime] SPARSE NULL,
						[IsValid] [bit] NOT NULL DEFAULT(1),
						[ValidFrom] [datetime] NOT NULL DEFAULT(GETDATE()),
						[ValidTo] [datetime] SPARSE NULL,
						[IsDeleted] [bit] NOT NULL DEFAULT (0),
						[DeletedFrom] [datetime] SPARSE NULL,
						[DeletedBy] [int] SPARSE NULL,
						[CreatedOn] [datetime] NOT NULL DEFAULT(GETDATE()),
						[CreatedBy] [int] NULL,
						[LastModifiedOn] [datetime] SPARSE NULL,
						[LastModifiedBy] [int] SPARSE NULL,
						[Priority] [smallint] NOT NULL,
						[UIOrder] [smallint] NULL,
						[RealCreatedOn] datetime NOT NULL DEFAULT(GETDATE()),
						[RealLastModifiedOn] datetime SPARSE NULL,
						[RealDeletedFrom] datetime SPARSE NULL
						);
				END
					'
				--PRINT @str;
				EXEC(@str)
				
				SET @str='
				CREATE CLUSTERED INDEX [PK_' + @NowaNazwa + '_Cechy_Hist] ON [dbo].[_' + @NowaNazwa + '_Cechy_Hist]
				(
					[ObiektID] ASC,
					[CechaID] ASC
				)ON [PRIMARY]
				'
				EXEC(@str)
				
				--index i klucz glowny
				SET @str = '
				ALTER TABLE [_' + @NowaNazwa + '_Cechy_Hist] ADD CONSTRAINT [PK2_' + @NowaNazwa + '_Cechy_Hist]
				PRIMARY KEY NONCLUSTERED(Id);
				'
				EXEC(@str)
				
				-- klucze obce na IdArch i IdArchLink
				SET @str = '
				ALTER TABLE [_' + @NowaNazwa + '_Cechy_Hist]
				ADD CONSTRAINT [FK_' + @NowaNazwa + '_Cechy_Hist_IdArch] FOREIGN KEY (IdArch) REFERENCES [_' + @NowaNazwa + '_Cechy_Hist](Id);

				ALTER TABLE [_' + @NowaNazwa + '_Cechy_Hist]
				ADD CONSTRAINT [FK_' + @NowaNazwa + '_Cechy_Hist_IdArchLink] FOREIGN KEY (IdArchLink) REFERENCES [_' + @NowaNazwa + '_Cechy_Hist](Id);
				
				ALTER TABLE [_' + @NowaNazwa + '_Cechy_Hist]
				ADD CONSTRAINT [FK_' + @NowaNazwa + '_Cechy_Hist_ObiektId] FOREIGN KEY (ObiektId) REFERENCES [_' + @NowaNazwa + '](Id);
				
				ALTER TABLE [_' + @NowaNazwa + '_Cechy_Hist]
				ADD CONSTRAINT [FK_' + @NowaNazwa + '_Cechy_Hist_CechaId] FOREIGN KEY (CechaId) REFERENCES [dbo].[Cechy](Cecha_ID);

				ALTER TABLE [_' + @NowaNazwa + '_Cechy_Hist]
				ADD CONSTRAINT [FK_' + @NowaNazwa + '_Cechy_Hist_CalculatedByAlgorithm] FOREIGN KEY (CalculatedByAlgorithm) REFERENCES [dbo].Algorytmy(Id);

				'
				EXEC(@str)
				
			IF NOT EXISTS (SELECT name FROM sys.triggers WHERE name = 'WartoscZmiany_' + @NowaNazwa + '_Cechy_Hist_UPDATE')
			BEGIN
				SET @str = '			
CREATE TRIGGER [dbo].[WartoscZmiany_' + @NowaNazwa + '_Cechy_Hist_UPDATE]
   ON  [dbo].[_' + @NowaNazwa + '_Cechy_Hist] 
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	IF(UPDATE(IsDeleted)) RETURN;

	DECLARE @ID int, @ObiektID int, @CechaID int, @ValInt int, @ValString nvarchar(max), @ValFloat float, @ValBit bit, @ValDecimal decimal(12,5)
	,@ValDatetime datetime, @ValDate date, @ValTime time, @WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int
	,@ObowiazujeOd datetime, @ObowiazujeDo datetime, @UIOrder smallint, @Priority smallint
	,@VirtualTypeId smallint, @IsValidForAlgorithm bit, @CalculatedByAlgorithm smallint, @AlgorithmRun int
	,@WaznyOdNEW datetime, @UtworzonyPrzezNEW int, @CzyWaznyNEW bit, @ValIntNEW int, @ValStringNEW nvarchar(max), @ValFloatNEW float
	,@ValBitNEW bit, @ValDecimalNEW decimal(12,5), @ValDatetimeNEW datetime, @ValDateNEW date, @ValTimeNEW time
	,@DataModyfikacjiApp datetime, @RealCreatedOn datetime, @RealLastModifiedOn datetime, @hist int
	,@PrzedzialCzasowyId int, @Sledzona bit, @MinDate datetime, @MaxDate datetime, @OldLastModifiedOn datetime 
	,@IsStatus bit, @StatusS int, @StatusW int, @StatusP int, @StatusSBy int, @StatusPBy int, @StatusWBy int 
	,@StatusSFrom datetime, @StatusPFrom datetime, @StatusWFrom datetime, @StatusPCechy int, @NewObowiazujeDo datetime, @MinDateObowiazuje datetime, @MaxDateObowiazuje datetime
	,@IsAlternativeHistory bit, @IsMainHistFlow bit, @NewObowiazujeOd datetime, @NewIsMainHistFlow bit, @ValDictionary int, @ValXml xml, @ValRef xml,
	@CreatedOn datetime, @LastModifiedOn datetime, @ZmienionyPrzez int
	
	DECLARE cur_ObiektInst_Cechy_UPDATE CURSOR FOR
		SELECT ID, ObiektID, CechaID, ValInt, ValString, ValFloat, ValBit ,ValDecimal, ValDatetime, ValDate, ValTime, ValDictionary, ValXml, ValRef,
			ValidFrom, CreatedBy, IdArchLink, ObowiazujeOd, ObowiazujeDo, UIOrder, [Priority], VirtualTypeId, IsValidForAlgorithm,
			CalculatedByAlgorithm, AlgorithmRun, ISNULL(LastModifiedOn, CreatedOn), IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, 
			StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom, IsAlternativeHistory, IsMainHistFlow, CreatedOn, LastModifiedOn, LastModifiedBy
		FROM deleted
	OPEN cur_ObiektInst_Cechy_UPDATE	
	FETCH NEXT FROM cur_ObiektInst_Cechy_UPDATE INTO @ID, @ObiektID, @CechaID, @ValInt, @ValString, @ValFloat, @ValBit, @ValDecimal, @ValDatetime, @ValDate, @ValTime, 
		@ValDictionary, @ValXml, @ValRef, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo, @UIOrder, @Priority, @VirtualTypeId, @IsValidForAlgorithm, 
		@CalculatedByAlgorithm, @AlgorithmRun, @OldLastModifiedOn, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, 
		@StatusWFrom, @IsAlternativeHistory, @IsMainHistFlow, @CreatedOn, @LastModifiedOn, @ZmienionyPrzez
	WHILE @@fetch_status = 0
	BEGIN
	
		SELECT @WaznyodNEW = ValidFrom, @CzyWaznyNEW = IsValid, @UtworzonyPrzezNEW = LastModifiedBy, @NewObowiazujeOd = ObowiazujeOd, @NewIsMainHistFlow = IsMainHistFlow,
			@DataModyfikacjiApp = LastModifiedOn, @RealCreatedOn = RealCreatedOn, @RealLastModifiedOn = RealLastModifiedOn, @NewObowiazujeDo = ObowiazujeDo
		FROM inserted WHERE ID = @ID
		
		--pobranie przedzialu czasowego z danych cechy oraz jej charakteru chwilowego
		SELECT @PrzedzialCzasowyId = PrzedzialCzasowyId, @Sledzona = Sledzona, @StatusPCechy = StatusP
		FROM Cechy
		WHERE Cecha_ID = @CechaID;
	
		IF @CzyWaznyNEW = 1 
		BEGIN'
	
		SET @str += '						
			--okreslamy granice przedzialu tylko jesli ustawiono typ przedzialu dla cechy
			IF @PrzedzialCzasowyId IS NOT NULL
			BEGIN
				--pobranie przedzialu czasowego dla przedzialu czasowego modyfikowanego typu cechy i daty aplikacji
				EXEC [THB].[PrepareTimePeriods]
					@AppDate = @DataModyfikacjiApp,
					@TimeIntervalId = @PrzedzialCzasowyId,
					@MinDate = @MinDate OUTPUT,
					@MaxDate = @MaxDate OUTPUT
			END
			ELSE
			BEGIN
				--brak jednostki czasu wiec zapisujemy kazda zmiane
				SET @Sledzona = 1;
			END
			
			--jesli ma byc zapisywana kazda zmiana wartosci cechy (charakter chwilowy) lub wartosc nie miesci sie w podanym przedziale czasowym
			IF @NewIsMainHistFlow <> @IsMainHistFlow OR @ObowiazujeOd <> @NewObowiazujeOd OR @Sledzona = 1 OR @StatusPCechy >= 5 
				OR @OldLastModifiedOn < @MinDate OR @OldLastModifiedOn > @MaxDate
			BEGIN
			
				--EXEC [THB].[PrepareTimeForPrevPeriod]
				--	@AppDate = @DataModyfikacjiApp,
				--	@TimeIntervalId = @PrzedzialCzasowyId,
				--	@MinDate = @MinDateObowiazuje OUTPUT,
				--	@MaxDate = @MaxDateObowiazuje OUTPUT
					
				--kolumna narazie nie uzywana	
				SET @MaxDateObowiazuje = NULL
				
				--podmiana wartosci daty ostatniej modyfikacji i osoby modyfikujacej
				IF @Sledzona = 1
				BEGIN
					SET @LastModifiedOn = @DataModyfikacjiApp;
					SET @ZmienionyPrzez = @UtworzonyPrzezNEW;
				END							
			
				INSERT INTO [dbo].[_' + @NowaNazwa + '_Cechy_Hist]
				   ([IdArch], IdArchLink, [ObiektId], [CechaID], [ValInt], [ValString], [ValFloat], [ValBit], [ValDecimal], [ValDatetime], [ValDate], [ValTime], [ValDictionary], [ValXml], [ValRef]
				   ,[IsValid], [ValidFrom], [ValidTo], [CreatedOn], [CreatedBy], [LastModifiedOn], [LastModifiedBy], ObowiazujeOd, ObowiazujeDo, 
				   UIOrder, [Priority], VirtualTypeId, IsValidForAlgorithm, CalculatedByAlgorithm, AlgorithmRun,
				   RealCreatedOn, RealLastModifiedOn, IsAlternativeHistory, IsMainHistFlow, IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, 
				   StatusWFrom, StatusSTo, StatusPTo, StatusWTo, StatusSToBy, StatusPToBy, StatusWToBy)';
		    
		SET @str += '
				SELECT @Id, ISNULL(@IdArchLink, @ID), @ObiektID, @CechaID, @ValInt, @ValString, @ValFloat, @ValBit, @ValDecimal, @ValDatetime, @ValDate, @ValTime, @ValDictionary, @ValXml, @ValRef 
					, 0, @WaznyOd, @WaznyodNEW, @CreatedOn, @UtworzonyPrzez, @LastModifiedOn, @ZmienionyPrzez, @ObowiazujeOd, @MaxDateObowiazuje, --@ObowiazujeOd, @ObowiazujeDo, 
					@UIOrder, @Priority, @VirtualTypeId, @IsValidForAlgorithm, @CalculatedByAlgorithm, @AlgorithmRun,
					@RealCreatedOn, @RealLastModifiedOn, @IsAlternativeHistory, @IsMainHistFlow, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom,
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
	
				UPDATE [dbo].[_' + @NowaNazwa + '_Cechy_Hist]
				SET ValidFrom = @WaznyodNEW
				,[CreatedBy] = @UtworzonyPrzezNEW
				--,[ObowiazujeOd] = @MinDate
				--,[ObowiazujeDo] = @NewObowiazujeDo
				,LastModifiedOn = NULL
				,LastModifiedBy = NULL
				,CreatedOn = ISNULL(@DataModyfikacjiApp, @WaznyodNEW)
				,RealCreatedOn = ISNULL(@RealLastModifiedOn, @RealCreatedOn)
				,RealDeletedFrom = NULL
				,RealLastModifiedOn = NULL
				,IdArchLink = @hist
				,IdArch = NULL
				WHERE ID = @ID'
				
		SET @str += '
			END
			ELSE IF (@ObowiazujeOd = @NewObowiazujeOd AND @OldLastModifiedOn >= @MinDate AND @OldLastModifiedOn <= @MaxDate) --zapis cech na podstawie przedzialow czasowych
			BEGIN
									
				--sprawdzenie czy data ostatniej modyfikacji miesci sie w przedziale czasowym wg nowej daty modyfikacji, jesli tak to tylko update rekordu
				--bez tworzenia wpisow historycznych
				UPDATE [dbo].[_' + @NowaNazwa + '_Cechy_Hist]
				SET ValidFrom = @DataModyfikacjiApp
				,[CreatedBy] = @UtworzonyPrzezNEW
				WHERE ID = @ID
			
			END
		END
	
		FETCH NEXT FROM cur_ObiektInst_Cechy_UPDATE INTO @ID, @ObiektID, @CechaID, @ValInt, @ValString, @ValFloat, @ValBit, @ValDecimal, @ValDatetime, @ValDate, @ValTime, 
			@ValDictionary, @ValXml, @ValRef, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo, @UIOrder, @Priority, @VirtualTypeId, @IsValidForAlgorithm, 
			@CalculatedByAlgorithm, @AlgorithmRun, @OldLastModifiedOn, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, 
			@StatusWFrom, @IsAlternativeHistory, @IsMainHistFlow, @CreatedOn, @LastModifiedOn, @ZmienionyPrzez
	END
	
	CLOSE cur_ObiektInst_Cechy_UPDATE
	DEALLOCATE cur_ObiektInst_Cechy_UPDATE	
END	'
				
				--PRINT @str
				EXEC(@str)
			END
			
			IF NOT EXISTS (SELECT name FROM sys.triggers WHERE name = 'WartoscZmiany_' + @NowaNazwa + '_Cechy_Hist_INSERT')
			BEGIN
				SET @str='			
				
CREATE TRIGGER [dbo].[WartoscZmiany_'+ @NowaNazwa +'_Cechy_Hist_INSERT]
   ON  [dbo].[_'+ @NowaNazwa +'_Cechy_Hist] 
   AFTER INSERT
AS 
BEGIN
	DECLARE @ID int, @Nazwa nvarchar(64)
	,@WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int,@Wersja int
	,@ObowiazujeOD datetime, @ObowiazujeDo datetime

	DECLARE @maxDt date = ''9999-12-31''
	
	select @ID = ID, @IdArchLink = IdArchLink
	FROM inserted

	IF (@IdArchLink IS NULL)
	BEGIN
		IF EXISTS(
			SELECT S1.CechaID, S1.ObiektID,
			  S1.ID AS key1, S1.ObowiazujeOd AS start1, S1.ObowiazujeDo AS end1,
			  S2.ID AS key2, S2.ObowiazujeOd AS start2, S2.ObowiazujeDo AS end2
			FROM inserted AS S1
			  JOIN [dbo].[_' + @NowaNazwa + '_Cechy_Hist] AS S2
				ON  S2.CechaID = S1.CechaID
				AND S2.ObiektID = S1.ObiektID
				AND S2.VirtualTypeId = S1.VirtualTypeId
				AND (COALESCE(S2.ObowiazujeDo,@maxDt) >= COALESCE(S1.ObowiazujeOd,@maxDt)
					 AND COALESCE(S2.ObowiazujeOd, @maxDt) <= COALESCE(S1.ObowiazujeDo,@maxDt))
			WHERE S1.Id = @id AND S1.ID <> S2.ID AND S1.VirtualTypeId = S2.VirtualTypeId
		)	
		BEGIN
							
			UPDATE [dbo].[_' + @NowaNazwa + '_Cechy_Hist] 
			SET IsAlternativeHistory = 1
			, IsMainHistFlow = 0
			WHERE Id = @id
		
		END
	END
END	'
				
				--PRINT @str
				EXEC(@str)
			END
			
		--wylaczenie poki co takiego triggera
		SET @str = 'DISABLE TRIGGER [dbo].[WartoscZmiany_' + @NowaNazwa + '_Cechy_Hist_INSERT] ON  [dbo].[_' + @NowaNazwa + '_Cechy_Hist]; '
		EXEC(@str);
						
				
			SET @str = 'IF OBJECT_ID (N''[_' + @NowaNazwa + '_Relacje_Hist]'', N''U'') IS NULL
				BEGIN
					CREATE TABLE [dbo].[_' + @NowaNazwa + '_Relacje_Hist](
						[Id] [int] IDENTITY(1,1) NOT NULL,
						[IdArch] [int] NULL,
						[IdArchLink] [int] NULL,
						[ObiektId] [int] NOT NULL FOREIGN KEY REFERENCES [dbo].[_' + @NowaNazwa + '](Id),
						[CechaId] [int] NOT NULL FOREIGN KEY REFERENCES [dbo].[Cechy](Cecha_ID),
						[RelacjaId] [int] NOT NULL,
						CalculatedByAlgorithm smallint NULL FOREIGN KEY REFERENCES Algorytmy(Id),
						VirtualTypeId smallint NOT NULL DEFAULT(0),
						IsValidForAlgorithm bit NOT NULL DEFAULT(1),
						AlgorithmRun int NULL,
						[ColumnsSet] [xml] COLUMN_SET FOR ALL_SPARSE_COLUMNS  NULL,
						[ValInt] [int] SPARSE  NULL,
						[ValString] [nvarchar](max) NULL,
						[ValFloat] [float] SPARSE  NULL,
						[ValBit] [bit] SPARSE  NULL,
						[ValDecimal] [decimal](12, 5) SPARSE  NULL,
						[ValDatetime] [datetime] SPARSE  NULL,
						[ValDictionary] [int] SPARSE NULL,
						[ValDate] [date] SPARSE  NULL,
						[ValTime] [time](7) SPARSE  NULL,
						[IsAlternativeHistory] [bit] DEFAULT(0),
						[IsMainHistFlow] [bit] DEFAULT(1),
						[IsStatus] [bit] NOT NULL DEFAULT (1),
						[StatusS] [int] NULL,
						[StatusSFrom] [datetime] NULL,
						[StatusSTo] [datetime] NULL,
						[StatusSFromBy] [int] NULL,
						[StatusSToBy] [int] NULL,
						[StatusW] [int] NULL,
						[StatusWFrom] [datetime] NULL,
						[StatusWTo] [datetime] NULL,
						[StatusWFromBy] [int] NULL,
						[StatusWToBy] [int] NULL,
						[StatusP] [int] NULL,
						[StatusPFrom] [datetime] NULL,
						[StatusPTo] [datetime] NULL,
						[StatusPFromBy] [int] NULL,
						[StatusPToBy] [int] NULL,
						[ObowiazujeOd] [datetime] NULL,
						[ObowiazujeDo] [datetime] NULL,
						[IsValid] [bit] NOT NULL DEFAULT (1),
						[ValidFrom] [datetime] NOT NULL default (getdate()),
						[ValidTo] [datetime] NULL,
						[IsDeleted] [bit] NOT NULL DEFAULT (0),
						[DeletedFrom] [datetime] NULL,
						[DeletedBy] [int] NULL,
						[CreatedOn] [datetime] NOT NULL default (getdate()),
						[CreatedBy] [int] NULL,
						[LastModifiedOn] [datetime] NULL,
						[LastModifiedBy] [int] NULL,
						[Priority] [smallint] NULL,
						[UIOrder] [smallint] NULL,
						[RealCreatedOn] datetime NOT NULL DEFAULT(GETDATE()),
						[RealLastModifiedOn] datetime NULL,
						[RealDeletedFrom] datetime NULL
						)
			
				END
					'	
			--	EXEC(@str)	
				
				SET @str = '
				CREATE CLUSTERED INDEX [PK_' + @NowaNazwa + '_Relacje_Hist] ON [dbo].[_' + @NowaNazwa + '_Relacje_Hist]
				(
					[ObiektID] ASC,
					[RelacjaID] ASC,
					[CechaID] ASC
				)ON [PRIMARY]
				'
			--	EXEC(@str)
				
				--index i klucz glowny
				SET @str = '
				ALTER TABLE [_' + @NowaNazwa + '_Relacje_Hist] ADD CONSTRAINT [PK2_' + @NowaNazwa + '_Relacje_Hist]
				PRIMARY KEY NONCLUSTERED(Id);
				'
			--	EXEC(@str)
				
				-- klucze obce na IdArch i IdArchLink
				SET @str = '
				ALTER TABLE [_' + @NowaNazwa + '_Relacje_Hist]
				ADD CONSTRAINT [FK_' + @NowaNazwa + '_Relacje_Hist_IdArch] FOREIGN KEY (IdArch) REFERENCES [_' + @NowaNazwa + '_Relacje_Hist](Id);

				ALTER TABLE [_' + @NowaNazwa + '_Relacje_Hist]
				ADD CONSTRAINT [FK_' + @NowaNazwa + '_Relacje_Hist_IdArchLink] FOREIGN KEY (IdArchLink) REFERENCES [_' + @NowaNazwa + '_Relacje_Hist](Id);
				'
			--	EXEC(@str)

				
			IF NOT EXISTS (SELECT name FROM sys.triggers WHERE name = 'WartoscZmiany_' + @NowaNazwa + '_Relacje_Hist_UPDATE')
			BEGIN
				SET @str = '			
CREATE TRIGGER [dbo].[WartoscZmiany_' + @NowaNazwa + '_Relacje_Hist_UPDATE]
   ON  [dbo].[_' + @NowaNazwa + '_Relacje_Hist] 
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @ID int, @ObiektID int, @CechaID int, @ValInt int, @ValString nvarchar(max), @ValFloat float, @ValBit bit, @ValDecimal decimal(12,5)
	,@ValDatetime datetime, @ValDate date, @ValTime time, @WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int, @ZmianaOd datetime, @ZmianaDo datetime, @ObowiazujeOd datetime
	,@ObowiazujeDo datetime, @RelacjaId int, @VirtualTypeId smallint, @IsValidForAlgorithm bit, @CalculatedByAlgorithm smallint, @AlgorithmRun int, @WaznyOdNEW datetime, 
	@UtworzonyPrzezNEW int, @CzyWaznyNEW bit, @ValIntNEW int, @ValStringNEW nvarchar(max), @ValFloatNEW float, @ValBitNEW bit, @ValDecimalNEW decimal(12,5)
	,@ValDatetimeNEW datetime, @ValDateNEW date, @ValTimeNEW time, @DataModyfikacjiApp datetime, @hist int, @RealCreatedOn datetime, @RealLastModifiedOn datetime, @IsStatus bit, 
	@StatusS int, @StatusW int, @StatusP int, @StatusSBy int, @StatusPBy int, @StatusWBy int, @StatusSFrom datetime, @StatusPFrom datetime, @StatusWFrom datetime					

	DECLARE cur_ObInst_Relacje_UPDATE CURSOR FOR
		SELECT Id, ObiektID, CechaID, ValInt, ValString, ValFloat, ValBit, ValDecimal, ValDatetime, ValDate, ValTime, ValidFrom, CreatedBy, IdArchLink
			,ObowiazujeOd, ObowiazujeDo, RelacjaId, VirtualTypeId, IsValidForAlgorithm, CalculatedByAlgorithm, AlgorithmRun,
			IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom
		FROM deleted
	OPEN cur_ObInst_Relacje_UPDATE 
	FETCH NEXT FROM cur_ObInst_Relacje_UPDATE INTO @ID, @ObiektID, @CechaID, @ValInt, @ValString, @ValFloat, @ValBit, @ValDecimal, @ValDatetime, @ValDate, @ValTime, @WaznyOd, 
		@UtworzonyPrzez, @IdArchLink, @ObowiazujeOd, @ObowiazujeDo, @RelacjaId, @VirtualTypeId, @IsValidForAlgorithm, @CalculatedByAlgorithm, @AlgorithmRun,
		@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
	WHILE @@fetch_status = 0
	BEGIN
	
		SELECT @WaznyodNEW = ValidFrom, @CzyWaznyNEW = IsValid, @UtworzonyPrzezNEW = LastModifiedBy,
			@DataModyfikacjiApp = LastModifiedOn, @RealCreatedOn = RealCreatedOn, @RealLastModifiedOn = RealLastModifiedOn
		FROM inserted WHERE ID = @ID
	
		IF(@CzyWaznyNEW = 1 AND NOT UPDATE(IsAlternativeHistory))
		BEGIN
			
			INSERT INTO [dbo].[_' + @NowaNazwa + '_Relacje_Hist]
			   ([IdArch], IdArchLink,[ObiektId],[CechaID], [ValInt], [ValString], [ValFloat], [ValBit], [ValDecimal],[ValDatetime], [ValDate], [ValTime]
			   ,[IsValid], [ValidFrom],[ValidTo],[CreatedOn], [CreatedBy], [LastModifiedOn], [LastModifiedBy], ObowiazujeOD, ObowiazujeDo, RelacjaId, [IsArchive], 
			   [ArchivedFrom], [ArchivedBy], VirtualTypeId, IsValidForAlgorithm, CalculatedByAlgorithm, AlgorithmRun, RealCreatedOn, 
				   RealLastModifiedOn, IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, 
				   StatusWFrom, StatusSTo, StatusPTo, StatusWTo, StatusSToBy, StatusPToBy, StatusWToBy)
		'
		
		SET @str += '	    
			SELECT @ID, ISNULL(@IdArchLink, @ID), @ObiektID, @CechaID, @ValInt, @ValString, @ValFloat, @ValBit, @ValDecimal, @ValDatetime, @ValDate, @ValTime, 0, @WaznyOd, 
			@DataModyfikacjiApp, @WaznyOd, @UtworzonyPrzez, @DataModyfikacjiApp, @UtworzonyPrzezNEW, @ObowiazujeOD, @ObowiazujeDo, @RelacjaId, 1, @DataModyfikacjiApp, 
			@UtworzonyPrzezNEW, @VirtualTypeId, @IsValidForAlgorithm, @CalculatedByAlgorithm, @AlgorithmRun, @RealCreatedOn, 
			@RealLastModifiedOn, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, 
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

			UPDATE [dbo].[_' + @NowaNazwa + '_Relacje_Hist]
			SET ValidFrom = @WaznyodNEW
			,[CreatedBy] = @UtworzonyPrzezNEW
			,LastModifiedOn = NULL
			,LastModifiedBy = NULL
			,CreatedOn = ISNULL(@DataModyfikacjiApp, GETDATE())
			,RealCreatedOn = @RealLastModifiedOn
			,RealDeletedFrom = NULL
			,RealLastModifiedOn = NULL
			,IdArchLink = @hist
			,IdArch = NULL			
			WHERE ID = @ID

		END
	
		FETCH NEXT FROM cur_ObInst_Relacje_UPDATE INTO @ID, @ObiektID, @CechaID, @ValInt, @ValString, @ValFloat, @ValBit, @ValDecimal, @ValDatetime, @ValDate, @ValTime, @WaznyOd, 
			@UtworzonyPrzez, @IdArchLink, @ObowiazujeOd, @ObowiazujeDo, @RelacjaId, @VirtualTypeId, @IsValidForAlgorithm, @CalculatedByAlgorithm, @AlgorithmRun,
			@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom
	END
	
	CLOSE cur_ObInst_Relacje_UPDATE
	DEALLOCATE cur_ObInst_Relacje_UPDATE	
END	'
				
				--EXEC(@str)
			END
			
			IF NOT EXISTS (SELECT name FROM sys.triggers WHERE name = 'WartoscZmiany_' + @NowaNazwa + '_Relacje_Hist_INSERT')
			BEGIN	
				SET @str='	
CREATE TRIGGER [dbo].[WartoscZmiany_'+ @NowaNazwa +'_Relacje_Hist_INSERT]
   ON  [dbo].[_'+ @NowaNazwa +'_Relacje_Hist] 
   AFTER INSERT
AS 
BEGIN
	declare @ID int, @Nazwa nvarchar(64)
	,@WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int,@Wersja int
	,@ZmianaOd datetime, @ZmianaDo datetime, @ObowiazujeOD datetime
	,@ObowiazujeDo datetime

	Declare @maxDt date = ''9999-12-31''
	
	select @ID = ID , @IdArchLink = IdArchLink
	FROM inserted

	IF (@IdArchLink IS NULL)
	BEGIN
		IF EXISTS(
			SELECT S1.ObiektID,S1.CechaID,
			  S1.ID AS key1, S1.ObowiazujeOd AS start1, S1.ObowiazujeDo AS end1,
			  S2.ID AS key2, S2.ObowiazujeOd AS start2, S2.ObowiazujeDo AS end2
			FROM inserted AS S1
			  JOIN [dbo].[_'+ @NowaNazwa +'_Relacje_Hist]   AS S2
				ON  S1.ObiektID = S2.ObiektID
				AND S1.CechaID = S2.CechaID
				AND (COALESCE(S2.ObowiazujeDo,@maxDt) >= COALESCE(S1.ObowiazujeOd,@maxDt)
					 AND COALESCE(S2.ObowiazujeOd, @maxDt) <= COALESCE(S1.ObowiazujeDo,@maxDt))
			WHERE S1.Id = @id AND S1.ID <> S2.ID AND S1.VirtualTypeId = S2.VirtualTypeId
		)	
		BEGIN						
		
			UPDATE [dbo].[_'+ @NowaNazwa +'_Relacje_Hist] 
			SET IsAlternativeHistory = 1
			, IsMainHistFlow = 0
			WHERE Id = @id
		
		END
	END
END	'
				
				--PRINT @str
			--	EXEC(@str)
			END
			
			--wylaczenie poki co takiego triggera
			SET @str = 'DISABLE TRIGGER [dbo].[WartoscZmiany_' + @NowaNazwa + '_Relacje_Hist_INSERT] ON  [dbo].[_' + @NowaNazwa + '_Relacje_Hist]; '
			--EXEC(@str);
					
		END
		ELSE
		BEGIN
			SET @str = 'IF OBJECT_ID (N''[_' + @NowaNazwa + '_Cechy]'', N''U'') IS NULL
				BEGIN
					CREATE TABLE [dbo].[_' + @NowaNazwa + '_Cechy](
						[Id] [int] IDENTITY(1,1) NOT NULL,
						[ObiektId] [int] NOT NULL,
						[ColumnsSet] [xml] column_set FOR ALL_SPARSE_COLUMNS,
						[CechaID] int not null,
						[StatusID] int not null,
						[ValInt] [int] SPARSE null,
						[ValString] nvarchar(max) null,
						[ValFloat] [float]  SPARSE NULL,
						[ValBit] [bit]  SPARSE NULL,
						[ValDecimal] decimal(12,5) SPARSE null ,
						[ValDatetime] datetime SPARSE NULL,
						[ValDate] date SPARSE NULL,
						[ValTime] time SPARSE null,					
						[IsValid] [bit] NOT NULL DEFAULT(1),
						[ValidFrom] [datetime] NOT NULL DEfAult(GETDATE()),
						[ValidTo] [datetime] NULL ,
						[CreatedOn] [datetime] NOT NULL DEfAult(GETDATE()),
						[CreatedBy] [int] null,
						[LastModifiedOn] [datetime] NULL,
						[LastModifiedBy] [int] null,
						[Priority] [smallint] null,
						[UIOrder][smallint] null
						)
				END
					'	
			--	EXEC(@str)	
				
				--SET @str='
				--CREATE CLUSTERED INDEX [PK_'+@NowaNazwa+ '_Cechy] ON [dbo].[_'+@NowaNazwa+ '_Cechy]
				--(
				--	[ObiektID] ASC,
				--	[CechaID] ASC
				--)ON [PRIMARY]
				--'
				--EXEC(@str)
				
				
					SET @str = 'IF OBJECT_ID (N''[_' + @NowaNazwa + '_Relacje]'', N''U'') IS NULL
				BEGIN
					CREATE TABLE [dbo].[_' + @NowaNazwa + '_Relacje](
						[Id] [int] IDENTITY(1,1) NOT NULL,
						[ObiektId] [int] NOT NULL,
						[RelacjaID] [int] NOT NULL,
						[ColumnsSet] [xml] column_set FOR ALL_SPARSE_COLUMNS,
						[CechaID] int not null,
						[StatusID] int not null,
						[ValInt] [int] SPARSE null,
						[ValString] nvarchar(max) null,
						[ValFloat] [float]  SPARSE NULL,
						[ValBit] [bit]  SPARSE NULL,
						[ValDecimal] decimal(12,5) SPARSE null ,
						[ValDatetime] datetime SPARSE NULL,
						[ValDate] date SPARSE NULL,
						[ValTime] time SPARSE null,					
						[IsValid] [bit] NOT NULL DEFAULT(1),
						[ValidFrom] [datetime] NOT NULL DEfAult(GETDATE()),
						[ValidTo] [datetime] NULL ,
						[CreatedOn] [datetime] NOT NULL DEfAult(GETDATE()),
						[CreatedBy] [int] null,
						[LastModifiedOn] [datetime] NULL,
						[LastModifiedBy] [int] null
						);
				END			
					'	
			--	EXEC(@str)	
				
				SET @str='IF OBJECT_ID (N''[_' + @NowaNazwa + '_Relacje]'', N''U'') IS NOT NULL
				BEGIN
					CREATE CLUSTERED INDEX [PK_' + @NowaNazwa+ '_Relacje] ON [dbo].[_' + @NowaNazwa + '_Relacje]
					(
						[ObiektID] ASC,
						[RelacjaID] ASC,
						[CechaID] ASC
					)ON [PRIMARY]
				END
				'
		--		EXEC(@str)

			END
	END
END


