-----------------------------------------------------------------
-- disable all SQL agent jobs
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

UPDATE msdb.dbo.sysjobs
SET Enabled = 0
WHERE Enabled = 1;