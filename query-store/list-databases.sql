-- check is the query store is enabled on some databases.
SELECT 
	d.name,
	d.database_id,
	d.create_date,
	d.state_desc as [state]
FROM sys.databases d
WHERE d.is_query_store_on = 1;