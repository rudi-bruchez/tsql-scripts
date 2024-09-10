-----------------------------------------------------------------
-- IN PROGRESS
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
    @epsilon bigint,
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
        -- create continued fraction
        ContinuedFraction cf = new ContinuedFraction() {

		    public double evaluate(double x, double epsilon, int maxIterations) {
        // Delegate to GeneralizedContinuedFraction

        // Get the first coefficient
        final double b0 = getB(0, x);

        // Generate coefficients from (a1,b1)
        final Supplier<Coefficient> gen = new Supplier<Coefficient>() {
            /** Coefficient index. */
            private int n;
            @Override
            public Coefficient get() {
                n++;
                final double a = getA(n, x);
                final double b = getB(n, x);
                return Coefficient.of(a, b);
            }
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
        ret = FastMath.exp(-x + (a * FastMath.log(x)) - logGamma(a)) * ret;
    }

    return ret;
END