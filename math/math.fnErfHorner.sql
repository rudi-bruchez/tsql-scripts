-----------------------------------------------------------------
-- math.fnErfHorner 
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

IF SCHEMA_ID('math') IS NULL 
	EXECUTE ('CREATE SCHEMA math;')
GO

CREATE OR ALTER FUNCTION math.fnErfHorner
(
        @z decimal (18,10)
)
RETURNS decimal (18,10)
WITH RETURNS NULL ON NULL INPUT
AS 
-- Calculating Erf function using Horner's rule
BEGIN
	declare @t decimal (18,10)
	declare @ans decimal (18,10)
	--erf(a,b)= erf(a)-erf(b)
	--so erf(1,0) = erf(1)-erf(0)=0.84270 -0
	set @t = 1.0 / (1.0 + 0.5 * abs(@z))
	-- use Horner's method
	set @ans = 1 - @t * exp( -@z*@z - 1.26551223 +
		@t * ( 1.00002368 +
		@t * ( 0.37409196 +
		@t * ( 0.09678418 +
		@t * (-0.18628806 +
		@t * ( 0.27886807 +
		@t * (-1.13520398 +
		@t * ( 1.48851587 +
		@t * (-0.82215223 +
		@t * ( 0.17087277))))))))))

	if @z >= 0.0
		RETURN @ans
	
	RETURN -@ans
END
GO
