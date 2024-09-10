-----------------------------------------------------------------
-- math.fnLogGamma
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;



IF SCHEMA_ID('math') IS NULL 
	EXECUTE ('CREATE SCHEMA math;')
GO

CREATE OR ALTER FUNCTION math.fnLogGamma(@x float)
RETURNS FLOAT
WITH RETURNS NULL ON NULL INPUT
AS BEGIN
	
	DECLARE @ret float;

	if @x IS NULL OR @x <= 0.0
		SET @ret = NULL;
	else begin
		DECLARE @g float = 607.0 / 128.0;

		DECLARE @sum float = 0.0;

		/** Lanczos coefficients */
		SET @sum += 0.99999999999999709182;
		SET @sum += 57.156235665862923517;
		SET @sum += -59.597960355475491248;
		SET @sum += 14.136097974741747174;
		SET @sum += -0.49191381609762019978;
		SET @sum += .33994649984811888699e-4;
		SET @sum += .46523628927048575665e-4;
		SET @sum += -.98374475304879564677e-4;
		SET @sum += .15808870322491248884e-3;
		SET @sum += -.21026444172410488319e-3;
		SET @sum += .21743961811521264320e-3;
		SET @sum += -.16431810653676389022e-3;
		SET @sum += .84418223983852743293e-4;
		SET @sum += -.26190838401581408670e-4;
		SET @sum += .36899182659531622704e-5;

		DECLARE @tmp float = @x + @g + .5;
		-- HALF_LOG_2_PI = 0.5 * FastMath.log(MathUtils.TWO_PI);
	
		SET @ret = ((@x + .5) * LOG(@tmp)) - @tmp +
			(0.5 * LOG(6.28318530718)) /* HALF_LOG_2_PI*/ 
			+ LOG(@sum / @x);
	END

	RETURN @ret;
END;