-----------------------------------------------------------------
-- math.fnErfc -- IN PROGRESS
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

IF SCHEMA_ID('math') IS NULL 
	EXECUTE ('CREATE SCHEMA math;')
GO

CREATE OR ALTER FUNCTION math.fnErfc(@x float)
RETURNS FLOAT
WITH RETURNS NULL ON NULL INPUT
AS BEGIN
	if (ABS(@x) > 40)
		RETURN IIF(@x > 0, 0, 2)

	DECLARE @ret float = math.fnRegularizedGammaQ(0.5, @x * @x, 1.0e-15, 10000);
	RETURN IIF(@x < 0, 2 - @ret, @ret);
END