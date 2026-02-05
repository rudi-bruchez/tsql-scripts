# Configuration

Instance and database configuration scripts.

## 📝 [recovery-simple](./recovery-simple.sql)

Generates T-SQL commands to change recovery model to SIMPLE for all user databases (excluding ReportServer databases).

## 📝 [set-instance-dop](./set-instance-dop.sql)

Configures instance-level parallelism settings based on CPU core count, adjusting max degree of parallelism and cost threshold for parallelism if still at default values.
