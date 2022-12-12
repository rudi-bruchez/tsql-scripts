-----------------------------------------------------------------
-- WIP TODO
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

CREATE FUNCTION fn_GetStatisticsFromPlan (
	@query_plan as XML
)
RETURNS TABLE
AS 
RETURN

    WITH XMLNAMESPACES 
    (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 
    ,GetStatsCTE As (
    SELECT DISTINCT
    cp.SqlHandle,
    cp.PlanHash,
    cp.DbName, 
    schnds.value('(@FieldValue)[1]', 'varchar(128)') AS Schema_Name, 
    tblnds.value('(@FieldValue)[1]', 'varchar(128)') AS Table_Name, 
    obj.value('(@FieldValue)[1]', 'varchar(128)') AS Stats_Name 
    FROM @query_plan.nodes('//Recompile/Field[@FieldName="wszTable"]') AS StatNodes(tblnds) 
    CROSS APPLY tblnds.nodes('../Field[@FieldName="wszSchema"]') AS SchNodes(schnds) 
    CROSS APPLY tblnds.nodes('../ModTrackingInfo') AS TblNodes(stnds) 
    CROSS APPLY stnds.nodes('./Field[@FieldName="wszStatName"]') AS vidx(obj) 
    Where MinElapsedTime_Msec >50
    ) 
    Select DbName,Schema_Name,Table_Name,Stats_Name,Sum(ExecutionCount) As TotalScanCount 
    FROM GetStatsCTE Where Schema_Name<>'sys' Group by DbName,Schema_Name,Table_Name,Stats_Name 