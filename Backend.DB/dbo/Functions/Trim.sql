
CREATE FUNCTION dbo.Trim(@Text nvarchar(MAX))
RETURNS nvarchar(MAX)
BEGIN
	RETURN LTRIM(RTRIM(@Text));
END

