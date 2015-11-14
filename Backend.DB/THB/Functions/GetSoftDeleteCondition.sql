-- =============================================
-- Author:		DK
-- Create date: 2013-02-15
-- Last modified on: --
-- Description:	Pobiera warunek dla jakiego mozna usuwac dane w trybie miekkim.
-- =============================================
CREATE FUNCTION [THB].[GetSoftDeleteCondition]
(
)
RETURNS nvarchar(100)
AS
BEGIN
	
	RETURN ' AND (StatusW IS NULL OR StatusW <> 2)';

END
