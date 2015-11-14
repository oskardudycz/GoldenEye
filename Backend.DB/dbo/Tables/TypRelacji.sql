CREATE TABLE [dbo].[TypRelacji] (
    [TableID]                INT             NULL,
    [TypRelacji_ID]          INT             IDENTITY (1, 1) NOT NULL,
    [IdArch]                 INT             NULL,
    [IdArchLink]             INT             NULL,
    [Nazwa]                  NVARCHAR (64)   NOT NULL,
    [CzyPrzechowujeHistorie] BIT             CONSTRAINT [DF_TypRelacji_CzyPrzechowujeHistorie] DEFAULT ((1)) NULL,
    [IsValid]                BIT             CONSTRAINT [DF_TypRelacji_IsValid] DEFAULT ((1)) NULL,
    [ValidFrom]              DATETIME        CONSTRAINT [DF_TypRelacji_ValidFrom] DEFAULT (getdate()) NOT NULL,
    [ValidTo]                DATETIME SPARSE NULL,
    [IsStatus]               BIT             CONSTRAINT [DF_TypRelacji_IsStatus] DEFAULT ((0)) NOT NULL,
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
    [StatusA]                VARCHAR (3)     NULL,
    [StatusB]                VARCHAR (3)     NULL,
    [StatusC]                VARCHAR (3)     NULL,
    [IsDeleted]              BIT             CONSTRAINT [DF_TypRelacji_IsDeleted] DEFAULT ((0)) NOT NULL,
    [DeletedFrom]            DATETIME SPARSE NULL,
    [DeletedBy]              INT SPARSE      NULL,
    [CreatedOn]              DATETIME        CONSTRAINT [DF_TypRelacji_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]              INT             NULL,
    [LastModifiedOn]         DATETIME SPARSE NULL,
    [LastModifiedBy]         INT SPARSE      NULL,
    [IsAlternativeHistory]   BIT             DEFAULT ((0)) NULL,
    [IsMainHistFlow]         BIT             DEFAULT ((0)) NULL,
    [BazowyTypRelacji_ID]    INT             NOT NULL,
    [RealCreatedOn]          DATETIME        DEFAULT (getdate()) NOT NULL,
    [RealLastModifiedOn]     DATETIME SPARSE NULL,
    [RealDeletedFrom]        DATETIME SPARSE NULL,
    [IsBlocked]              BIT             CONSTRAINT [DF_TypRelacji_IsBlocked] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_TypRelacji] PRIMARY KEY CLUSTERED ([TypRelacji_ID] ASC) WITH (FILLFACTOR = 80),
    FOREIGN KEY ([BazowyTypRelacji_ID]) REFERENCES [dbo].[Relacja_Typ] ([Id]),
    CONSTRAINT [FK_TypRelacji_IdArch] FOREIGN KEY ([IdArch]) REFERENCES [dbo].[TypRelacji] ([TypRelacji_ID]),
    CONSTRAINT [FK_TypRelacji_IdArchLink] FOREIGN KEY ([IdArchLink]) REFERENCES [dbo].[TypRelacji] ([TypRelacji_ID])
);


GO
CREATE TRIGGER [dbo].[CreateTableForTypRelacji]
   ON  [dbo].[TypRelacji]
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @NowaNazwa VARCHAR(32)
	SELECT @NowaNazwa =(SELECT Nazwa FROM INSERTED)
	
	DECLARE @CzyHistoria BIT=(SELECT CzyPrzechowujeHistorie FROM INSERTED)
	DECLARE @IdArch INT = (SELECT IdArch FROM inserted)
	
	
	IF (@IdArch IS NULL)
	BEGIN
	
	
	DECLARE @str nvarchar(max)
	SET @str = 'CREATE TABLE [dbo].[_R_' + @NowaNazwa + '](
					[Id] [int] IDENTITY(1,1) NOT NULL,
					[IdArch] [int] NULL,
					[IdArchLink] [int] NULL,
					[Wersja] [int] NOT NULL DEFAULT(0),
					[Nazwa] nvarchar(256) not null,
					--[StatusID] [int] NULL,
					--[RzeczywistaDataZmiany] datetime null,
					--[ZmianaOd] datetime null,
					--[ZmianaDo] datetime null,
					--[IsValid] [bit] NOT NULL DEFAULT(1),
					--[ValidFrom] [datetime] NOT NULL DEfAult(GETDATE()),
					--[ValidTo] [datetime] NULL ,
					--[CreatedOn] [datetime] NOT NULL DEfAult(GETDATE()),
					--[CreatedBy] [int] null,
					--[LastModifiedOn] [datetime] NULL,
					--[LastModifiedBy] [int] null
					[IsStatus] [bit] NOT NULL DEFAULT (0),
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
					[ZmianaOd] [datetime] NULL,
					[ZmianaDo] [datetime] NULL,
					[ObowiazujeOd] [datetime] NULL,
					[ObowiazujeDo] [datetime] NULL,
					[IsValid] [bit] NOT NULL DEFAULT(1),
					[ValidFrom] [datetime] NOT NULL DEFAULT(GETDATE()),
					[ValidTo] [datetime] NULL,
					[IsArchive] [bit] NOT NULL DEFAULT (0) ,
					[ArchivedFrom] [datetime] NULL,
					[ArchivedBy] [int] NULL,
					[IsDeleted] [bit] NOT NULL DEFAULT (0),
					[DeletedFrom] [datetime] NULL,
					[DeletedBy] [int] NULL,
					[CreatedOn] [datetime] NOT NULL DEFAULT(GETDATE()),
					[CreatedBy] [int] NULL,
					[LastModifiedOn] [datetime] NULL,
					[LastModifiedBy] [int] NULL
					
						)
			
					'	
				EXEC(@str)	


				SET @str='
				CREATE UNIQUE CLUSTERED INDEX [PK_R_'+@NowaNazwa+'] ON [dbo].[_R_'+@NowaNazwa+'] 
				(
					[Id] ASC,
					[Wersja] ASC
				)ON [PRIMARY]
				'
				EXEC(@str)
				
			SET @str='			
				
				CREATE TRIGGER [dbo].[WartoscZmiany_R_'+ @NowaNazwa +'_UPDATE]
				   ON  [dbo].[_R_'+ @NowaNazwa +'] 
				   AFTER UPDATE
				AS 
				BEGIN
					SET NOCOUNT ON;

					declare @ID int, @Nazwa nvarchar(64)
					,@WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int,@Wersja int
					,@ZmianaOd datetime, @ZmianaDo datetime, @ObowiazujeOD datetime
					,@ObowiazujeDo datetime

					declare @WaznyOdNEW datetime, @UtworzonyPrzezNEW int, @CzyWaznyNEW bit
					,@NazwaNEW nvarchar(64)
				

					declare cur cursor for
						select ID , Nazwa, ValidFrom , CreatedBy, IdArchLink,Wersja
						,ZmianaOd, ZmianaDo, ObowiazujeOD,ObowiazujeDo
						FROM deleted
					open cur 
					fetch next from cur into @ID , @Nazwa,@WaznyOd , @UtworzonyPrzez 
					,@IdArchLink,@Wersja,@ZmianaOd, @ZmianaDo, @ObowiazujeOD,@ObowiazujeDo
					while @@fetch_status=0
					begin
					
						SELECT @WaznyodNEW =ValidFrom, @CzyWaznyNEW = IsValid,@UtworzonyPrzezNEW = LastModifiedBy
						,@NazwaNEW = Nazwa
						FROM inserted WHERE ID=@ID
						
						declare @hist int
					
						IF(@CzyWaznyNEW=1)
							BEGIN
							
							INSERT INTO [dbo].[_R_'+@NowaNazwa+']
							   ([IdArch],IdArchLink,Nazwa,Wersja
							   ,[IsValid],[ValidFrom],[ValidTo],[CreatedOn],[CreatedBy]
							   ,[LastModifiedOn],[LastModifiedBy]
							   ,ZmianaOd, ZmianaDo, ObowiazujeOD,ObowiazujeDo)
					    
							SELECT @ID,ISNULL(@IdArchLink,@ID) , @Nazwa,@Wersja
										,0,@WaznyOd,GETDATE() ,@WaznyOd, @UtworzonyPrzez  
										,GETDATE(),@UtworzonyPrzezNEW
										,@ZmianaOd, @ZmianaDo, @ObowiazujeOD,@ObowiazujeDo

							SELECT @hist = @@IDENTITY


							UPDATE [dbo].[_R_'+@NowaNazwa+']
							SET ValidFrom = GETDATE()
							,[CreatedBy]=@UtworzonyPrzezNEW
							,LastModifiedOn = NULL
							,LastModifiedBy = NULL
							,CreatedOn = GETDATE()
							,IdArchLink = @hist
							,IdArch=NULL
							WHERE ID=@ID

						END
					
						fetch next from cur into @ID , @Nazwa,@WaznyOd , @UtworzonyPrzez 
						,@IdArchLink,@Wersja,@ZmianaOd, @ZmianaDo, @ObowiazujeOD,@ObowiazujeDo
					end
					
					close cur
					deallocate cur	
				END	'
				
		PRINT @str
		EXEC(@str)			
	IF (@CzyHistoria>0)
	BEGIN

			SET @str = 'CREATE TABLE [dbo].[_R_' + @NowaNazwa + '_Cechy_Hist](
						[Id] [int] IDENTITY(1,1) NOT NULL,
						[IdArch] [int] NULL,
						[IdArchLink] [int] NULL,
						[ObiektId] [int] NOT NULL,
						[CechaID] [int] NOT NULL,
						[ColumnsSet] [xml] COLUMN_SET FOR ALL_SPARSE_COLUMNS  NULL,
						[ValInt] [int] SPARSE  NULL,
						[ValString] [nvarchar](max) NULL,
						[ValFloat] [float] SPARSE  NULL,
						[ValBit] [bit] SPARSE  NULL,
						[ValDecimal] [decimal](12, 5) SPARSE  NULL,
						[ValDatetime] [datetime] SPARSE  NULL,
						[ValDate] [date] SPARSE  NULL,
						[ValTime] [time](7) SPARSE  NULL,
						[IsStatus] [bit] NOT NULL DEFAULT (0),
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
						[ZmianaOd] [datetime] NULL,
						[ZmianaDo] [datetime] NULL,
						[ObowiazujeOd] [datetime] NULL,
						[ObowiazujeDo] [datetime] NULL,
						[IsValid] [bit] NOT NULL DEFAULT(1),
						[ValidFrom] [datetime] NOT NULL DEFAULT(GETDATE()),
						[ValidTo] [datetime] NULL,
						[IsArchive] [bit] NOT NULL DEFAULT (0) ,
						[ArchivedFrom] [datetime] NULL,
						[ArchivedBy] [int] NULL,
						[IsDeleted] [bit] NOT NULL DEFAULT (0),
						[DeletedFrom] [datetime] NULL,
						[DeletedBy] [int] NULL,
						[CreatedOn] [datetime] NOT NULL DEFAULT(GETDATE()),
						[CreatedBy] [int] NULL,
						[LastModifiedOn] [datetime] NULL,
						[LastModifiedBy] [int] NULL,
						[Priority] [smallint] NULL,
						[UIOrder] [smallint] NULL
						)
			
					'	
				EXEC(@str)	
				
				SET @str='
				CREATE CLUSTERED INDEX [PK_R_'+@NowaNazwa+ '_Cechy_Hist] ON [dbo].[_R_'+@NowaNazwa+ '_Cechy_Hist]
				(
					[ObiektID] ASC,
					[CechaID] ASC
				)ON [PRIMARY]
				'
				EXEC(@str)
				
				
				SET @str='			
				
				CREATE TRIGGER [dbo].[WartoscZmiany_R_'+ @NowaNazwa +'_Cechy_Hist_UPDATE]
				   ON  [dbo].[_R_'+ @NowaNazwa +'_Cechy_Hist] 
				   AFTER UPDATE
				AS 
				BEGIN
					SET NOCOUNT ON;

					declare @ID int, @ObiektID int, @CechaID int, @ValInt int
					,@ValString nvarchar(max),@ValFloat float
					,@ValBit bit,@ValDecimal decimal(12,5)
					,@ValDatetime datetime, @ValDate date, @ValTime time
					,@WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int
					,@ZmianaOd datetime, @ZmianaDo datetime, @ObowiazujeOd datetime
					,@ObowiazujeDo datetime

					declare @WaznyOdNEW datetime, @UtworzonyPrzezNEW int, @CzyWaznyNEW bit
					,@ValIntNEW int
					,@ValStringNEW nvarchar(max),@ValFloatNEW float
					,@ValBitNEW bit,@ValDecimalNEW decimal(12,5)
					,@ValDatetimeNEW datetime, @ValDateNEW date, @ValTimeNEW time
					

					declare cur cursor for
						select ID , ObiektID , CechaID , ValInt 
									,ValString ,ValFloat 
									,ValBit ,ValDecimal 
									,ValDatetime , ValDate , ValTime 
									,ValidFrom , CreatedBy, IdArchLink
									,ZmianaOd, ZmianaDo, ObowiazujeOD,ObowiazujeDo
						FROM deleted
					open cur	
					fetch next from cur into @ID , @ObiektID , @CechaID , @ValInt 
									,@ValString ,@ValFloat 
									,@ValBit ,@ValDecimal 
									,@ValDatetime , @ValDate , @ValTime 
									,@WaznyOd , @UtworzonyPrzez ,@IdArchLink
									,@ZmianaOd, @ZmianaDo, @ObowiazujeOD,@ObowiazujeDo
					while @@fetch_status=0
					begin
					
						SELECT @WaznyodNEW =ValidFrom, @CzyWaznyNEW = IsValid,
						@UtworzonyPrzezNEW = LastModifiedBy
						FROM inserted WHERE ID=@ID
						
						declare @hist int
					
						IF(@CzyWaznyNEW=1)
							BEGIN
							
							INSERT INTO [dbo].[_R_'+@NowaNazwa+'_Cechy_Hist]
							   ([IdArch],IdArchLink,[ObiektId],[CechaID],[ValInt],[ValString],[ValFloat]
							   ,[ValBit],[ValDecimal],[ValDatetime],[ValDate],[ValTime]
							   ,[IsValid],[ValidFrom],[ValidTo],[CreatedOn],[CreatedBy]
							   ,[LastModifiedOn],[LastModifiedBy]
							   ,ZmianaOd, ZmianaDo, ObowiazujeOd,ObowiazujeDo)
					    
							SELECT @ID,ISNULL(@IdArchLink,@ID) , @ObiektID , @CechaID , @ValInt 
										,@ValString ,@ValFloat 
										,@ValBit ,@ValDecimal 
										,@ValDatetime , @ValDate , @ValTime 
										,0,@WaznyOd,GETDATE() ,@WaznyOd, @UtworzonyPrzez  
										,GETDATE(),@UtworzonyPrzezNEW
										,@ZmianaOd, @ZmianaDo, @ObowiazujeOD,@ObowiazujeDo

							SELECT @hist = @@IDENTITY


							UPDATE [dbo].[_R_'+@NowaNazwa+'_Cechy_Hist]
							SET ValidFrom = GETDATE()
							,[CreatedBy]=@UtworzonyPrzezNEW
							,LastModifiedOn = NULL
							,LastModifiedBy = NULL
							,CreatedOn = GETDATE()
							,IdArchLink = @hist
							,IdArch=NULL
							WHERE ID=@ID

						END
					
						fetch next from cur into @ID , @ObiektID , @CechaID , @ValInt 
									,@ValString ,@ValFloat 
									,@ValBit ,@ValDecimal 
									,@ValDatetime , @ValDate , @ValTime 
									,@WaznyOd , @UtworzonyPrzez ,@IdArchLink
									,@ZmianaOd, @ZmianaDo, @ObowiazujeOD,@ObowiazujeDo
					end
					
					close cur
					deallocate cur	
				END	'
				
				EXEC(@str)
		
	END
	ELSE
	BEGIN
		SET @str = 'CREATE TABLE [dbo].[_R_' + @NowaNazwa + '_Cechy](
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
		
				'	
			EXEC(@str)	
			
			SET @str='
			CREATE CLUSTERED INDEX [PK_R'+@NowaNazwa+ '_Cechy] ON [dbo].[R_'+@NowaNazwa+ '_Cechy]
			(
				[ObiektID] ASC,
				[CechaID] ASC
			)ON [PRIMARY]
			'
			EXEC(@str)
			
		END	
	END

END

GO
DISABLE TRIGGER [dbo].[CreateTableForTypRelacji]
    ON [dbo].[TypRelacji];


GO
CREATE TRIGGER [dbo].[RemoveTablesForTypRelacji]
   ON  dbo.TypRelacji
   AFTER DELETE
AS 
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @CzyHistoria bit = (SELECT CzyPrzechowujeHistorie FROM DELETED)
	DECLARE @Nazwa varchar(32) = (SELECT Nazwa FROM DELETED)
	DECLARE @query_drop_obiekt nvarchar(256)
	DECLARE @query_drop_cechy nvarchar(256)
	
	SET @query_drop_obiekt = N'DROP TABLE [dbo].[R_'+@Nazwa+']'
	
	SET @query_drop_cechy = N'DROP TABLE [dbo]. [R_'+@Nazwa
	
	
	IF(@CzyHistoria > 0)
		BEGIN
			SET @query_drop_cechy += N'_Cechy_Hist'
		END
	SET @query_drop_cechy += ']'
	--print(@query_drop_obiekt)
	--print(@query_drop_cechy)
	exec (@query_drop_cechy)
	exec (@query_drop_obiekt)
END

GO
DISABLE TRIGGER [dbo].[RemoveTablesForTypRelacji]
    ON [dbo].[TypRelacji];


GO
-- DK
-- Last modified on: 2013-01-26
-------------------------------------------------------		
CREATE TRIGGER [dbo].[WartoscZmiany_TypRelacji_UPDATE]
   ON [dbo].[TypRelacji]
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @ID int,@Nazwa nvarchar(64),@CzyPrzechowujeHistorie bit
	,@StatusA varchar(3),@StatusB varchar(3),@StatusC varchar(3)
	,@WaznyOd datetime, @UtworzonyPrzez int, @IdArchLink int
	,@ZmianaOd datetime, @ZmianaDo datetime, @ObowiazujeOD datetime
	,@ObowiazujeDo datetime, @BazowyTypelacjiId int, @WaznyOdNEW datetime, @UtworzonyPrzezNEW int, @CzyWaznyNEW bit
	,@NazwaNEW nvarchar(64), @CzyPrzechowujeHistorieNEW bit, @DataModyfikacjiApp datetime
	,@RealCreatedOn datetime, @RealLastModifiedOn datetime, @hist int, @IsStatus bit, @StatusS int, @StatusW int, @StatusP int, @StatusSBy int, @StatusPBy int, @StatusWBy int 
	,@StatusSFrom datetime, @StatusPFrom datetime, @StatusWFrom datetime, @IsBlocked bit		

	DECLARE cur CURSOR FOR
		SELECT TypRelacji_ID, ValidFrom, CreatedBy, IdArchLink, ObowiazujeOd, ObowiazujeDo, Nazwa, CzyPrzechowujeHistorie, StatusA, StatusB, StatusC, BazowyTypRelacji_Id, 
			IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, StatusWFrom, IsBlocked
		FROM deleted
	OPEN cur 
	FETCH NEXT FROM cur INTO @ID, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo, @Nazwa, @CzyPrzechowujeHistorie, @StatusA, @StatusB, @StatusC, @BazowyTypelacjiId, 
		@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, @IsBlocked
	WHILE @@fetch_status = 0
	BEGIN
	
		SELECT @WaznyodNEW = ValidFrom, @CzyWaznyNEW = IsValid, @UtworzonyPrzezNEW = LastModifiedBy, @NazwaNEW = Nazwa
			,@CzyPrzechowujeHistorieNEW = CzyPrzechowujeHistorie, @DataModyfikacjiApp = LastModifiedOn, @RealCreatedOn = RealCreatedOn, @RealLastModifiedOn = RealLastModifiedOn
		FROM inserted WHERE TypRelacji_ID = @ID

		IF(@CzyWaznyNEW = 1)
		BEGIN
		
			SET @ObowiazujeDo = NULL;	
			
			/*DECLARE @OldN nvarchar(64) = '_R_' + @Nazwa
			DECLARE @NewN nvarchar(64) = '_R_' + @NazwaNEW
			EXEC sp_rename @OldN,@NewN
			
			IF(@CzyPrzechowujeHistorie)>0
				SET @OldN = '_R_' + @Nazwa + '_Cechy_Hist'
			ELSE	
				SET @OldN = '_R_' + @Nazwa + '_Cechy'
			
			IF(@CzyPrzechowujeHistorieNEW)>0
				SET @NewN = '_R_' + @NazwaNEW + '_Cechy_Hist'
			ELSE	
				SET @NewN = '_R_' + @NazwaNEW + '_Cechy'

			EXEC sp_rename @OldN, @NewN
			--SET @OldN = 'R_'+@Nazwa+'_Relacje_Hist'
			--SET @NewN = 'R_'+@NazwaNEW+'_Relacje_Hist'
			--EXEC sp_rename @OldN,@NewN */
									
			
			INSERT INTO dbo.TypRelacji
			   ([IdArch], IdArchLink ,[IsValid], [ValidFrom], [ValidTo], [CreatedOn], [CreatedBy], [LastModifiedOn], [LastModifiedBy], 
			   ObowiazujeOd, ObowiazujeDo, Nazwa, CzyPrzechowujeHistorie, StatusA, StatusB, StatusC, BazowyTypRelacji_Id, 
			   RealCreatedOn, RealLastModifiedOn, IsStatus, StatusS, StatusP, StatusW, StatusSFromBy, StatusPFromBy, StatusWFromBy, StatusSFrom, StatusPFrom, 
				   StatusWFrom, StatusSTo, StatusPTo, StatusWTo, StatusSToBy, StatusPToBy, StatusWToBy, IsBlocked)				    
			SELECT @ID,ISNULL(@IdArchLink,@ID), 0,@WaznyOd, @WaznyodNEW, @WaznyOd, @UtworzonyPrzez, @DataModyfikacjiApp, @UtworzonyPrzezNEW
				,@ObowiazujeOd, @ObowiazujeDo, @Nazwa, @CzyPrzechowujeHistorie, @StatusA
				,@StatusB, @StatusC, @BazowyTypelacjiId, @RealCreatedOn, @RealLastModifiedOn
				,@IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, 
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
					END,
					@IsBlocked 
						
			SELECT @hist = @@IDENTITY

			UPDATE dbo.TypRelacji
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
			WHERE TypRelacji_ID = @ID

		END
	
		FETCH NEXT FROM cur INTO @ID, @WaznyOd, @UtworzonyPrzez, @IdArchLink, @ObowiazujeOD, @ObowiazujeDo, @Nazwa, @CzyPrzechowujeHistorie, @StatusA, @StatusB, @StatusC, 
			@BazowyTypelacjiId, @IsStatus, @StatusS, @StatusP, @StatusW, @StatusSBy, @StatusPBy, @StatusWBy, @StatusSFrom, @StatusPFrom, @StatusWFrom, @IsBlocked
	END
	
	CLOSE cur
	DEALLOCATE cur	
END