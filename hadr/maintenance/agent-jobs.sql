-----------------------------------------------------------------
-- Add this as a frist step of your Agent jobs
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

IF sys.fn_hadr_is_primary_replica ( 'your database' ) = 1
BEGIN
    PRINT 'PRIMARY - Job can proceed'
END ELSE BEGIN
    -- Raise an exception
    ;THROW 51000, 'SECONDARY - Job needs to stop', 16;
END
