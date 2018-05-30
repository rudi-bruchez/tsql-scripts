-----------------------------------------------------------------
-- Look at page allocations in a sample database
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

USE PachaDataFormation
GO

CREATE TABLE #ind (
	PageFID int,
	PagePID int,
	IAMFID int,
	IAMPID int,
	ObjectId int,
	IndexId int,
	PartitionNumber int,
	PartitionId bigint,
	iam_chain_type varchar(50),
	PageType tinyint,
	IndexLevel tinyint,
	NextPageFID int,
	NextPagePID int,
	PrevPageFID int,
	PrevPagePID int
)

-- DBCC IND ('PachadataFormation', 'Contact.Contact', 0) WITH TABLERESULTS
INSERT INTO #ind (
	PageFID, PagePID, IAMFID, IAMPID, ObjectId, IndexId, PartitionNumber, PartitionId, iam_chain_type,
	PageType, IndexLevel, NextPageFID, NextPagePID, PrevPageFID, PrevPagePID )
EXEC ('DBCC IND (PachadataFormation, ''Contact.Contact'', 0) WITH TABLERESULTS');

-- find IAM
SELECT * FROM #ind
SELECT PageFID, PagePID FROM #ind WHERE PageType = 10
/* PageType :
1    – data page
2    – index page
3, 4 – text pages
8    – GAM page
9    – SGAM page
10   – IAM page
11   – PFS page
*/

-- Look at the IAM content
DBCC TRACEON (3604);
GO

DBCC PAGE (PachadataFormation, 1, 1717, 3);
GO 

/* -- last parameter : 
0 – print just the page header
1 – page header plus per-row hex dumps and a dump of the page slot array
2 – page header plus whole page hex dump
3 – page header plus detailed per-row interpretation
*/

-- and GAM ?
DBCC PAGE (PachadataFormation, 1, 1, 3);
GO 

-- SQL Server 2012 onward
-- SELECT * FROM sys.dm_db_database_page_allocations
SELECT
	allocated_page_file_id AS PageFID
	,allocated_page_page_id AS PagePID
	,allocated_page_iam_file_id AS IAMFID
	,allocated_page_iam_page_id AS IAMPID
	,object_id AS ObjectID
	,index_id AS IndexID
	,partition_id AS PartitionNumber
	,rowset_id AS PartitionID
	,allocation_unit_type_desc AS iam_chain_type
	,page_type AS PageType
	,page_level AS IndexLevel
	,next_page_file_id AS NextPageFID
	,next_page_page_id AS NextPagePID
	,previous_page_file_id AS PrevPageFID
	,previous_page_page_id AS PrevPagePID
FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('Person.Person'), 1, NULL, 'DETAILED')
WHERE is_allocated = 1;
GO
