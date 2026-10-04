# Extended Event Sessions (On-Prem)

Extended event sessions to track events on on-prem SQL Server instances.

## How to get session events

If you are using the "event file" target, the session files will usually be in the `log` directory of SQL Server.

You can find this directory by using [this query](../../server-information/get-sqlserver-log-directory.sql)

A more complete query to identify file targets name is [available here](./metadata/file-targets.sql).

- Identify all `<extended event session name>*.xel` files in the directory. There should be 5 at most, if you didn't change the default max number of files.
- Compress it using zip, 7-zip, etc. The compression ratio is important on these files.
- Grab files locally and open them using SQL Server Management Studio

## 📝 [Blocked processes: create](./blocked-processes-create.sql)

Sets `blocked process threshold (s)` to 10 seconds with `sp_configure` (the event is never raised while it is 0), then creates and starts the `blocked_processes` session (`event_file`, 10 files of 50 MB) and shows the file it writes to. Edit the threshold, or the `filename` to write outside the error log directory. Needs `ALTER ANY EVENT SESSION` and `ALTER SETTINGS`.

## 📝 [Blocked processes: read](./blocked-processes-read.sql)

Reads all rollover files of the `blocked_processes` session on the local instance, running or stopped, and returns one row per report: duration, lock mode, resolved database and object, then the blocked and blocking process (spid, wait resource, isolation level, login, host, application, input buffer, transaction count). `@last` sets the number of rows (100). SQL Server 2017+ (`timestamp_utc` column).

## 📝 [Blocked processes: read collected files](./blocked-processes-read-file.sql)

Same report as the previous script, for `.xel` files copied from another instance (a customer server, for example). Set `@file` to the path of the files (wildcard allowed) and `@utc_offset_hours` to the time zone of the source server. Database and object ids are left unresolved, since they belong to the source instance. SQL Server 2017+.

## 📝 [Blocked processes: cleanup](./blocked-processes-cleanup.sql)

Stops and drops the `blocked_processes` session, then sets `blocked process threshold (s)` back to 0. Run it once the `.xel` files are collected; they stay on disk (see [delete-event-files](./management/delete-event-files.sql)).

## 📝 [Errors: create](./errors-create.sql)

Creates the `errors` session on `error_reported` with a severity above 10, with client, database, `query_hash`, `sql_text` and `tsql_stack` actions, written to `errors.xel`. The script creates and starts the session; the stop statement is commented out, to run once you are done collecting.

## 📝 [Errors: create (alternate version)](./monitor-errors-create.sql)

Another definition of the same `errors` session (severity above 10, without `query_hash`, explicit memory and dispatch options), started and left running. It uses the same session name as [errors-create](./errors-create.sql): run one or the other, not both.

## 📝 [Errors: read](./errors-read.sql)

Reads all the rollover files of the running `errors` session and returns the errors of the last 24 hours: number, severity, message, login, database, host, application and statement. The `Timestamp` column is in UTC, as recorded by the session.

## 📝 [Errors: read procedure](./errors-read-procedure.sql)

Creates `dbo.ReadErrorsXEvent` in `master`, a procedure that runs the same read (all rollover files, `Timestamp` in UTC) for the last hour and leaves out error 17830 (network error during login). Handy to give a support team a single command to run.

## 📝 [Timeouts: create](./timeouts-create.sql)

Creates and starts the `timeouts` session, which captures `rpc_completed` and `sql_batch_completed` events whose `result` is Abort (2): client timeouts and cancelled queries. Written to `timeouts*.xel`, 100 MB per file, and restarted with the instance (`STARTUP_STATE=ON`).

## 📝 [Timeouts: read](./timeouts-read.sql)

Reads all the rollover files of the running `timeouts` session and returns the last `@last` (100) aborted calls with CPU, duration, row count, login, database, host, application and statement. SQL Server 2017+ (`timestamp_utc` column).

## 📝 [Long running queries](./long-running-queries-create.sql)

Creates and starts the `long_running_queries` session: `rpc_completed` and `sql_batch_completed` longer than 1 second, written to `long_running_queries*.xel` (200 MB per file) and restarted with the instance. Edit the duration threshold (in microseconds), the excluded application (`telegraf` is an example) and `STARTUP_STATE`.

## 📝 [Performances](./performances-create.sql)

Creates the `performances` session: user `rpc_completed` (without connection resets) and `sql_batch_completed` events of 10 ms or more, to `performances*.xel`. The script creates and starts the session; the stop statement is commented out, to run once you are done collecting.

## 📝 [Performance session for SQL Server 2008 R2](./xevents-perfs-2008r2.sql)

Old exploration script for SQL Server 2008 R2: lists the events whose name contains `complet`, the columns of `sql_statement_completed` and the available targets, then creates a `perfs` session on `rpc_completed` and `sql_statement_completed` (duration above 100000) with the legacy `asynchronous_file_target`, and lists the running sessions. The session is created but not started.

## 📝 [Monitor a stored procedure](./monitor-procedure-execution.sql)

Creates and starts the `stored_procedure` session, which captures `rpc_completed` and the actual plan (`query_post_execution_plan_profile`) for one procedure, to `stored_procedure*.xel`. Replace the `<procedure name, sysname, >` template parameter (Ctrl+Shift+M in SSMS); a commented block adds `sp_statement_completed` for the statements inside the procedure. The plan event needs SQL Server 2017 CU14+ or 2019+.

## 📝 [Actual plans with lightweight profiling](./lightweight-profiling-v3-create.sql)

Creates and starts the `plans_proc` session, which keeps the actual execution plans (`query_post_execution_plan_profile`) of one procedure in a ring buffer. Run the first `SELECT OBJECT_ID('<MY PROCEDURE>')` in the right database, then replace `<OBJECT ID>` with the result and `<DB NAME>` with the database name: the session is not created until `<OBJECT ID>` is replaced. The database filter uses the global `sqlserver.database_name` field, since the event's own `database_name` field is left empty. SQL Server 2017 CU14+ or 2019+.

## 📝 [Follow a session_id](./follow-a-session_id.sql)

Creates the `trace_session_id` session (ring buffer) with the statements, batches and actual plans of one session. Replace `<session_id>`. The script then starts the session; the stop and drop statements are commented out, to run once the ring buffer is read. The plan event needs SQL Server 2017 CU14+ or 2019+.

## 📝 [Waits of a session: create](./waits-on-a-session-create.sql)

Creates the `Waits_of_Particular_Session` session with statement start and completion, `wait_info` and `wait_info_external` for one session, written to `D:\traces\`. Edit the `session_id` (68) and the path. The script then starts the session; the stop and drop statements are commented out, to run once the files are read.

## 📝 [Waits of a session: read](./waits-on-a-session-read.sql)

Reads the files of `Waits_of_Particular_Session` from `d:\traces\` and returns the wait events with wait type, duration, opcode, session, statement and plan handle. Edit the path to match the create script.

## 📝 [Latches](./latches-create.sql)

Creates and starts the `latches` session: `wait_completed` for `LATCH_EX` waits longer than 2 ms, and `latch_suspend_end` longer than 1 ms, with application, database, statement and login, to `latches*.xel` (100 MB per file). Edit the wait type and durations to suit.

## 📝 [Recompilations](./recompilations-create.sql)

Creates and starts the `recompilations` session on `sql_statement_recompile`, leaving out `OPTION (RECOMPILE)` and deferred compiles, with object name, statement and client details, to `recompilations*.xel`.

## 📝 [Statement recompilations: create](./tracking_statement_recompilations-create.sql)

Creates the `tracking_statement_recompilations` session (ring buffer) on `sql_statement_recompile`, without `OPTION (RECOMPILE)`. The script creates and starts the session; the stop statement is commented out, to run once the ring buffer is read, since a stopped session loses it.

## 📝 [Statement recompilations: read](./tracking_statement_recompilations-read.sql)

Reads the ring buffer of the running `tracking_statement_recompilations` session: time, recompile cause, database, object, statement, application, host and login.

## 📝 [Procedure cache removals: create](./procedure_cache_removal_statistics-create.sql)

Creates the `procedure_removal_statistics` session (ring buffer) on `query_cache_removal_statistics`, filtered on stored procedures, to see the execution statistics of plans leaving the cache. The session is created but not started.

## 📝 [Procedure cache removals: read](./procedure_cache_removal_statistics-read.sql)

Reads the ring buffer of the running `procedure_removal_statistics` session and returns, for each removed plan, the `sql_handle`, the object id, database and name, the object type, the `execution_statistics` XML and the time the plan was cached. The event has no database id: it is taken from the procedure text still in cache (`sys.dm_exec_sql_text`), and the database and object stay empty when that text left the cache too.

## 📝 [Implicit conversions](./implicit-conversion-create.sql)

Creates and starts the `implicit_conversions` session on `plan_affecting_convert` where the conversion prevents a seek (`Seek Plan`), with application, host, database and statement, to `implicit_conversions*.xel`.

## 📝 [Spills to tempdb](./spills-to-tempdb-create.sql)

Creates and starts the `spills_to_tempdb` session on `exchange_spill`, `hash_spill_details`, `hash_warning` and `sort_warning`, in a ring buffer. Uncomment the `event_file` target to keep the results.

## 📝 [Query memory grants](./query_memory_grants-create.sql)

Creates the `query_memory` session on `query_memory_grant_usage`, to `query memory*.xel`. Add a filter on `granted_memory_kb`, `used_memory_kb` or `usage_percent` before using it on a busy server. The script creates and starts the session; the stop statement is commented out, to run once you are done collecting.

## 📝 [Auto stats](./auto-stats-create.sql)

Creates and starts the `auto_stats` session, which captures automatic statistics creation and updates outside tempdb (statistics loads are left out), with application, host, database, statement and login, to `auto_stats*.xel`.

## 📝 [Lock escalation: create](./lock-escalation-create.sql)

Creates the `lock_escalations` session on `lock_escalation` with application, database, session and statement, to `LockEscalation*.xel` (100 MB per file). The session is created but not started.

## 📝 [Lock escalation: read](./lock-escalation-read.sql)

Reads all the rollover files of the `lock_escalations` session, running or stopped, and returns the last `@last` (100) escalations: local time, database, object, hobt, resource type, lock mode, escalation cause, number of locks escalated, session, application and statement. SQL Server 2017+ (`timestamp_utc` column).

## 📝 [Logins and logouts from the connection pool](./login-logout-from-connection-pool-create.sql)

Creates and starts the `login_logout_from_pool` session, which keeps in a ring buffer the `login` and `logout` events of pooled connections (`is_cached = 1`) with application, host, client process id, database and login, to see how the applications use connection pooling.

## Subdirectories

### 📁 [bugs-identification](./bugs-identification/)

Extended Events sessions to identify known SQL Server bugs.

### 📁 [management](./management/)

Scripts for managing Extended Events sessions and files.

### 📁 [metadata](./metadata/)

Scripts for querying Extended Events metadata and configuration.