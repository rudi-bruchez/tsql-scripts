# Transaction log information queries

## 📝 [Transaction logs](./transaction-logs.sql)

A richer `DBCC SQLPERF(LOGSPACE)` for every database of the instance: log size and used space (from performance counters), `log_reuse_wait_desc`, recovery model, last log backup from `msdb`, and the log file name, path, max size and growth.

## 📝 [Transaction log active portion](./active-portion.sql)

Gives information about the position of the active VLFs inside the transaction log, and size before and after this active position. Useful to know where is the active portion within the transaction log, and how much space can be reclaimed by a file shrink.