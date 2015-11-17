-- DK
-- Created on: 2012-10-25
-- Description: Porównuje ze soba 2 pliki XML.
-- Zwraca 0 jeśli są równe i 1 jeśli się różnią.

CREATE FUNCTION [THB].[CompareXml]
(
    @xml1 XML,
    @xml2 XML
)
RETURNS INT
AS 
BEGIN
    DECLARE @return int,
    @x1 xml, 
    @x2 xml,
    @elCnt1 int, 
    @elCnt2 int,
    @attCnt1 int,
    @attCnt2 int,
    @elValue1 varchar(MAX), 
    @elValue2 varchar(MAX),
    @cnt int,
    @attName varchar(MAX),
    @attValue varchar(MAX)
    
    SELECT @return = 0

    -- -------------------------------------------------------------
    -- sprawdzenie czy oba z plikow XML sa NULLem
    -- -------------------------------------------------------------
    IF @xml1 IS NULL AND @xml2 IS NULL 
    BEGIN
		RETURN 0;
	END
    
    -- -------------------------------------------------------------
    -- sprawdzenie czy ktorys z plikow XML nie jest NULLem
    -- -------------------------------------------------------------
    IF @xml1 IS NULL OR @xml2 IS NULL BEGIN
        RETURN 1
    END

    -- -------------------------------------------------------------
    -- sprawdzenie nazwy elementu korzenia
    -- -------------------------------------------------------------
    IF  (SELECT @xml1.value('(local-name((/*)[1]))','varchar(MAX)')) <> (SELECT @xml2.value('(local-name((/*)[1]))','varchar(MAX)'))
    BEGIN
        RETURN 1
    END

    -- -------------------------------------------------------------
    -- sprawdzenie wartości elementow
    -- -------------------------------------------------------------
    SELECT
        @elValue1 = @xml1.value('((/*)[1])','varchar(MAX)'),
        @elValue2 = @xml2.value('data((/*)[1])','varchar(MAX)')        

    IF  @elValue1 <> @elValue2
    BEGIN
        RETURN 1
    END
    
    -- -------------------------------------------------------------
    -- sprawdzenie ilosci atrybutow w kazdym z elementow
    -- -------------------------------------------------------------
    SELECT
        @attCnt1 = @xml1.query('count(/*/@*)').value('.','int'),
        @attCnt2 = @xml2.query('count(/*/@*)').value('.','int')
        
    IF  @attCnt1 <> @attCnt2 BEGIN
        RETURN 1
    END

    -- -------------------------------------------------------------
	-- porownanie ze soba wartosci atrybutow w xml 1 i 2
    -- -------------------------------------------------------------    
    SELECT @cnt = 1
        
    WHILE @cnt <= @attCnt1 BEGIN
        SELECT @attName = NULL, @attValue = NULL
        SELECT
            @attName = @xml1.value(
                'local-name((/*/@*[sql:variable("@cnt")])[1])', 
                'varchar(MAX)'),
            @attValue = @xml1.value(
                '(/*/@*[sql:variable("@cnt")])[1]', 
                'varchar(MAX)')
        
        -- check if the attribute exists in the other XML document
        IF @xml2.exist(
                '(/*/@*[local-name()=sql:variable("@attName")])[1]'
            ) = 0
        BEGIN
            RETURN 1
        END
        
        IF  @xml2.value(
                '(/*/@*[local-name()=sql:variable("@attName")])[1]', 
                'varchar(MAX)')
            <>
            @attValue
        BEGIN
            RETURN 1
        END
        
        SELECT @cnt = @cnt + 1
    END

    -- -------------------------------------------------------------
    -- jesli dalej sa zgodne do porownanie elementow dzieci
    -- -------------------------------------------------------------
    SELECT
        @elCnt1 = @xml1.query('count(/*/*)').value('.','INT'),
        @elCnt2 = @xml2.query('count(/*/*)').value('.','INT')        

    IF  @elCnt1 <> @elCnt2
    BEGIN
        RETURN 1
    END            
            
    -- -------------------------------------------------------------
    -- wywolanie rekurencyjne dla kazdego elementu potomnego/dziecka
    -- -------------------------------------------------------------
    SELECT @cnt = 1

    WHILE @cnt <= @elCnt1 BEGIN
        SELECT 
            @x1 = @xml1.query('/*/*[sql:variable("@cnt")]'),
            @x2 = @xml2.query('/*/*[sql:variable("@cnt")]')
        
        IF thb.CompareXml( @x1, @x2 ) = 1
        BEGIN
            RETURN 1
        END
        
        SELECT @cnt = @cnt + 1
    END
    
    RETURN @return
END