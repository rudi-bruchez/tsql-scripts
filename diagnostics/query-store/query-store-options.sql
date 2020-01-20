SELECT *,
	CASE qso.readonly_reason
		WHEN 1 THEN 'db is in read only'
		WHEN 2 THEN 'db is in single user'
		WHEN 4 THEN 'db is in emergency mode'
		WHEN 8 THEN 'db is in secondary replica'
		WHEN 65536 THEN 'MAX_STORAGE_SIZE_MB is reached'
		ELSE 'Azure db ?'
	END
FROM  sys.database_query_store_options qso