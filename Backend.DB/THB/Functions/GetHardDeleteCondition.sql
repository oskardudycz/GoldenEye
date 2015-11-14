-- =============================================
-- Author:		DK
-- Create date: 2013-02-14
-- Last modified on: --
-- Description:	Pobiera warunek dla jakiego mozna usuwac dane w trybie twardym.
-- =============================================
CREATE FUNCTION [THB].[GetHardDeleteCondition]
(
)
RETURNS nvarchar(100)
AS
BEGIN
	
	RETURN ' AND StatusW = 2';

END
