-----------------------------------------------------------------
-- change the session_id, change the destination folder
-- use wait_completed if available
-- 
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

-------------------------------------------------
--    Parse the XML to show wait details       --
-------------------------------------------------
SELECT
    event_xml.value('(./@name)', 'varchar(1000)') as Event_Name,
    event_xml.value('(./data[@name="wait_type"]/text)[1]', 'nvarchar(max)') as Wait_Type,
    event_xml.value('(./data[@name="duration"]/value)[1]', 'int') as Duration,
    event_xml.value('(./data[@name="opcode"]/text)[1]', 'varchar(100)') as Operation,
    event_xml.value('(./action[@name="session_id"]/value)[1]', 'int') as SPID,
    event_xml.value('(./action[@name="sql_text"]/value)[1]', 'nvarchar(max)') as TSQLQuery,
    event_xml.value('(./action[@name="plan_handle"]/value)[1]', 'nvarchar(max)') as PlanHandle
FROM    
	(SELECT CAST(event_data AS XML) xml_event_data FROM sys.fn_xe_file_target_read_file('d:\traces\Waits_of_Particular_Session*.xel', 'd:\traces\Waits_of_Particular_Session*.xem', NULL, NULL)) AS event_table
	CROSS APPLY xml_event_data.nodes('//event') n (event_xml)
WHERE  
	event_xml.value('(./@name)', 'varchar(1000)') IN ('wait_info','wait_info_external')   
