-----------------------------------------------------------------
-- sp_lock2 -- replacement for sp_lock
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;



USE Master;
GO

CREATE OR ALTER PROCEDURE dbo.sp_lock2
	@session_id int = NULL
AS BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION	ISOLATION LEVEL READ UNCOMMITTED;

	SELECT 
	  tl.request_session_id as [session_id],
	  tl.resource_type, 
	  tl.resource_subtype,
	  CASE 
		 WHEN resource_type = 'OBJECT' THEN OBJECT_NAME(tl.resource_associated_entity_id, tl.resource_database_id)
		 ELSE '' 
	  END AS object,
	  tl.resource_description,
	  request_mode, 
	  request_type, 
	  request_status,
	  wt.blocking_session_id as blocking_session_id
	FROM sys.dm_tran_locks tl 
	LEFT JOIN sys.dm_os_waiting_tasks AS wt 
	    ON tl.lock_owner_address = wt.resource_address
	WHERE (tl.request_session_id = @session_id
	       OR @session_id IS NULL);

	SET TRANSACTION	ISOLATION LEVEL READ COMMITTED;
END;
GO