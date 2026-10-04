# Locking

Locking and blocking diagnostic queries.

## 📝 [analyze-blocked-sessions](./analyze-blocked-sessions.sql)

Displays sessions currently waiting on a lock held by a head blocker, with wait type, statement text, and the locked table when the lock resource is an object.

## 📝 [get-deadlock-from-xevents](./get-deadlock-from-xevents.sql)

Retrieves deadlock information from the system_health extended events session with deadlock graphs.

## 📝 [monitor-blocking](./monitor-blocking.sql)

Detects active blocking and sends email alerts with HTML table showing blocked sessions and blocking details. The locked table is named for object locks; for key, page and RID locks the lock resource description is shown instead.

## 📝 [vBlockingGraph](./vBlockingGraph.sql)

Creates a view that displays the blocking chains of the user sessions involved in blocking, with their level in the chain and their last input buffer.

## 📝 [what-is-locked](./what-is-locked.sql)

Shows what objects are locked in the current database including lock mode and resource type information.
