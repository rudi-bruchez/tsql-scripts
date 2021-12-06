--------------------------------------------------------------------
-- tracking procedure cache removal statistics
--
-- rudi@babaluga.com, go ahead license
--------------------------------------------------------------------

CREATE EVENT SESSION [procedure_removal_statistics] ON SERVER 
ADD EVENT sqlserver.query_cache_removal_statistics(
    WHERE (
		[compiled_object_type]=(2)) -- only stored procedures
	)
ADD TARGET package0.ring_buffer
GO
