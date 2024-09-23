-----------------------------------------------------------------
-- math.fnCumulativeProbability
-- needs the math.fnErfHorner and math.fnErf functions
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

IF SCHEMA_ID('math') IS NULL 
	EXECUTE ('CREATE SCHEMA math;')
GO

CREATE OR ALTER FUNCTION math.fnCumulativeProbability(@x float)
RETURNS FLOAT
WITH RETURNS NULL ON NULL INPUT
AS BEGIN
	--DECLARE @dev float = @x - mean; -- default mean = 0
	if (ABS(@x) > 40 /* * standardDeviation (default 1) */)
	begin
        return @x;
    end

	if (ABS(@x) >= 6.5 /* * standardDeviation (default 1) */)
	begin
        return 1;
    end else if ABS(@x) >= 6.0 begin
		return round(0.5 * (1 - math.fnErfHorner(-@x / sqrt(2.0))), 10);
	end

	return round(0.5 * (1 - math.fnErf(-@x / sqrt(2.0), 100)), 10);
END
GO