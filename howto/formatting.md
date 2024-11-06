# T-SQL formatting howto

## how to format an integer with thousand separators

```sql
SELECT FORMAT(1234567, '#,0')
-- or
SELECT FORMAT(1234567, 'N0')
```

warning: `FORMAT` is not available in SQL Server 2008, and it is a .NET function, so it is not as fast as a native SQL function.