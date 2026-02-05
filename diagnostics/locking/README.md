# Locking

Locking and blocking diagnostic queries.

## 📝 [analyze-blocked-sessions](./analyze-blocked-sessions.sql)

Displays current blocking sessions with session IDs, wait types, and the tables involved in locks.

## 📝 [get-deadlock-from-xevents](./get-deadlock-from-xevents.sql)

Retrieves deadlock information from the system_health extended events session with deadlock graphs.

## 📝 [monitor-blocking](./monitor-blocking.sql)

Detects active blocking and sends email alerts with HTML table showing blocked sessions and blocking details.

## 📝 [vBlockingGraph](./vBlockingGraph.sql)

Creates a view that displays the blocking graph of all active sessions showing blocking chains and levels.

## 📝 [what-is-locked](./what-is-locked.sql)

Shows what objects are locked in the current database including lock mode and resource type information.
