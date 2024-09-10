-----------------------------------------------------------------
-- math.fnRegularizedGammaP -- IN PROGRESS
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;



IF SCHEMA_ID('math') IS NULL 
	EXECUTE ('CREATE SCHEMA math;')
GO

CREATE OR ALTER FUNCTION math.fnRegularizedGammaP(
	@a float,
    @x float,
    @epsilon bigint,
    @maxIterations int)
RETURNS FLOAT
WITH RETURNS NULL ON NULL INPUT
AS BEGIN
	-- adapted from
	-- org/apache/commons/math/special/Gamma.java

    DECLARE @ret float;

    if (@a IS NULL OR @x IS NULL) OR (@a <= 0.0 OR @x < 0.0)
        SET @ret = NULL
    else if (@x = 0.0)
        SET @ret = 0.0;
	else if (@x >= @a + 1) begin
        -- use regularizedGammaQ because it should converge faster in this case.
        SET @ret = 1.0 - math.fnRegularizedGammaQ(@a, @x, epsilon, maxIterations);
    end else begin
        -- calculate series
        DECLARE @n float = 0.0; -- current element index
        DECLARE @an float = 1.0 / @a; -- n-th element in the series
        DECLARE @sum float = @an; -- partial sum
        WHILE (ABS(@an / @sum) > @epsilon AND @n < @maxIterations 
		       -- AND @sum < Double.POSITIVE_INFINITY
			   )
		BEGIN
            -- compute next element in the series
            SET @n += 1.0;
            SET @an = @an * (@x / (@a + @n));

            -- update partial sum
            SET @sum = @sum + @an;
        END -- WHILE
        if (@n >= @maxIterations) 
            SET @ret = NULL; --throw new MaxIterationsExceededException(maxIterations);
        --else if (Double.isInfinite(sum)) {
        --    ret = 1.0;
        else 
            SET @ret = EXP(-@x + (@a * LOG(@x)) - dbo.fnLogGamma(@a)) * @sum;
    end

    return @ret;
END