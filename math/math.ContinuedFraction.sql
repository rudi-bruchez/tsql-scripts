-----------------------------------------------------------------
-- File: math.ContinuedFraction.sql
-- Continued fraction of the regularized upper incomplete gamma
-- function, used by math.fnRegularizedGammaQ.
-- T-SQL cannot pass functions as parameters, so unlike the generic
-- ContinuedFraction class of Apache Commons Math, the coefficients
-- of the gamma Q fraction are written in the loop:
--   a(n) = 2n + 1 - @a + @x,  b(n) = n * (@a - n)
-- Evaluated with the modified Lentz algorithm, as in
-- org/apache/commons/math3/util/ContinuedFraction.java.
-- Returns NULL when @maxIterations is reached.
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;



IF SCHEMA_ID('math') IS NULL 
	EXECUTE ('CREATE SCHEMA math;')
GO

CREATE OR ALTER FUNCTION math.ContinuedFraction
(
	@a float, 
	@x float, 
	@epsilon float,
	@maxIterations int
)
RETURNS FLOAT
WITH RETURNS NULL ON NULL INPUT
AS BEGIN
	DECLARE @small float = 1e-50;

	-- first coefficient a(0)
	DECLARE @hPrev float = 1.0E0 - @a + @x;
	IF ABS(@hPrev) < @small SET @hPrev = @small;

	DECLARE @n int = 1;
	DECLARE @dPrev float = 0.0E0;
	DECLARE @cPrev float = @hPrev;
	DECLARE @hN float = @hPrev;
	DECLARE @an float, @bn float, @dN float, @cN float, @deltaN float;

	WHILE @n < @maxIterations
	BEGIN
		SET @an = ((2.0E0 * @n) + 1.0E0) - @a + @x;
		SET @bn = @n * (@a - @n);

		SET @dN = @an + @bn * @dPrev;
		IF ABS(@dN) < @small SET @dN = @small;
		SET @cN = @an + @bn / @cPrev;
		IF ABS(@cN) < @small SET @cN = @small;

		SET @dN = 1.0E0 / @dN;
		SET @deltaN = @cN * @dN;
		SET @hN = @hPrev * @deltaN;

		IF ABS(@deltaN - 1.0E0) < @epsilon BREAK;

		SET @dPrev = @dN;
		SET @cPrev = @cN;
		SET @hPrev = @hN;
		SET @n += 1;
	END

	IF @n >= @maxIterations RETURN NULL; -- MaxCountExceededException in Apache Commons Math

	RETURN @hN;
END
GO
