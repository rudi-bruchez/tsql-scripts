SELECT d.name
	  ,d.database_id
	  ,d.compatibility_level
	  ,SERVERPROPERTY('ProductMajorVersion') AS ServerVersion
FROM sys.databases d