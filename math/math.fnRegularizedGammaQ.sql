-----------------------------------------------------------------
-- math.fnRegularizedGammaQ
-- needs the math.fnLogGamma, math.ContinuedFraction and
-- math.fnRegularizedGammaP functions
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;



IF SCHEMA_ID('math') IS NULL 
	EXECUTE ('CREATE SCHEMA math;')
GO

CREATE OR ALTER FUNCTION math.fnRegularizedGammaQ(
	@a float,
    @x float,
    @epsilon float,
    @maxIterations int)
RETURNS FLOAT
WITH RETURNS NULL ON NULL INPUT
AS BEGIN

	DECLARE @ret float;

    if (@a IS NULL OR @x IS NULL) OR (@a <= 0.0 OR @x < 0.0)
        SET @ret = NULL
    else if (@x = 0.0)
        SET @ret = 1.0;
    else if @x < @a + 1.0 begin
        --use regularizedGammaP because it should converge faster in this case.
        SET @ret = 1.0 - math.fnRegularizedGammaP(@a, @x, @epsilon, @maxIterations);
    end else begin
        -- evaluate the continued fraction
        SET @ret = 1.0 / math.ContinuedFraction(@a, @x, @epsilon, @maxIterations);
        SET @ret = EXP(-@x + (@a * LOG(@x)) - math.fnLogGamma(@a)) * @ret;
    end

    return @ret;
END
GO
