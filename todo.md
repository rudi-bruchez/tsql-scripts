# TODO

## Memory

```sql
SELECT c.value_in_use AS [max memory KB]
FROM sys.configurations c
WHERE c.configuration_id = 1544

SELECT *
FROM sys.dm_os_process_memory dopm
```

## Understand the result of this DMV

```sql
SELECT
    session_id,
    connect_time,
    net_transport,
    encrypt_option,
    auth_scheme,
    client_net_address
FROM sys.dm_exec_connections
```