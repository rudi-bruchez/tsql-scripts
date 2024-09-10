-----------------------------------------------------------------
-- math.fnInverseCumulativeProbability
-- needs the math.fnErfInv function
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

IF SCHEMA_ID('math') IS NULL 
	EXECUTE ('CREATE SCHEMA math;')
GO

CREATE OR ALTER FUNCTION math.fnInverseCumulativeProbability(@p float)
RETURNS FLOAT
WITH RETURNS NULL ON NULL INPUT
AS BEGIN

	IF (@p < 0.0 OR @p > 1.0)
	BEGIN
		--;THROW 51000, 'The @p parameter is out of range.', 1;
		RETURN NULL
	END
		
	return ROUND(sqrt(2.0) * math.fnErfInv(2 * @p - 1), 10);
END
GO