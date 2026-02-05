# Alerts

SQL Server Agent alert configuration scripts.

## 📝 [long-transactions](./long-transactions.sql)

Creates a SQL Agent alert that triggers when a transaction runs for more than 60 seconds to monitor long-running transactions.

## 📝 [transaction-log-filling-up](./transaction-log-filling-up.sql)

Creates a SQL Agent alert that fires when a database's transaction log reaches 60% capacity, with configurable database name.
