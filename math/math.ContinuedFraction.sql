-----------------------------------------------------------------
-- File: math.ContinuedFraction.sql IN PROGRESS
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

        -- Get the first coefficient
		DECLARE @b0 float = 0;

        -- Generate coefficients from (a1,b1)
            /** Coefficient index. */
            DECLARE @n int = 0;

            --Coefficient get() {
            SET @n += 1;
            DECLARE @ra float = ((2.0 * @n) + 1.0) - @a + @x;
            DECLARE @rb float = @n * (@a - @n)
            return Coefficient.of(a, b);
        };

            @Override
            protected double getA(int n, double x) {
                return ((2.0 * n) + 1.0) - a + x;
            }

            @Override
            protected double getB(int n, double x) {
                return n * (a - n);
            }
        };

        ret = 1.0 / cf.evaluate(x, epsilon, maxIterations);
