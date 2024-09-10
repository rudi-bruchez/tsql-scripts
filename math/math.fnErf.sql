-----------------------------------------------------------------
-- math.fnErf
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

IF SCHEMA_ID('math') IS NULL 
	EXECUTE ('CREATE SCHEMA math;')
GO

CREATE OR ALTER FUNCTION math.fnErf
(
        @z FLOAT,
        @MaxIterations TINYINT = 100
)
RETURNS FLOAT
WITH RETURNS NULL ON NULL INPUT
AS BEGIN
        DECLARE @n TINYINT = 1,
                @p FLOAT = 1,
                @a FLOAT = @z

		SET @MaxIterations = COALESCE(ABS(@MaxIterations), 100);

        WHILE @p <> 0.0E AND @n <= @MaxIterations
            SELECT  @p = - @p * @z * @z / @n,
                    @a = @a + (@z /(2.0E * @n + 1.0E)) * @p,
                    @n += 1

        RETURN  @a * 2.0E / SQRT(PI())
END
GO
