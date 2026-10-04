# Bugs Identification

Extended Events sessions to identify known SQL Server bugs or issues.

## 📝 [Preemptive_QueryRegistry](./Preemptive_QueryRegistry.sql)

Creates an extended event session to identify PREEMPTIVE_OS_QUERYREGISTRY waits (SQL Server 2022 bug that causes registry lookups during query execution). The session has no target and is created stopped: start it and watch it with Watch Live Data in SSMS, or add a target before starting it.
