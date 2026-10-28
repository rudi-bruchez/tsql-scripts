# Configuration

Instance and database configuration scripts.

## 📝 [indirect-checkpoint](./indirect-checkpoint.sql)

Switches the user databases and model still on automatic checkpoint (`TARGET_RECOVERY_TIME = 0`) to indirect checkpoint, 60 seconds by default. Lists the commands by default and applies them with `@execute = 1`; offline, read-only and AG secondary databases are skipped and reported. On servers with 1 TB of memory or more, automatic checkpoint walks the whole buffer pool and logs error 898 with command 'CHECKPOINT'; count these messages before and after to check the effect.

## 📝 [recovery-simple](./recovery-simple.sql)

Generates T-SQL commands to change recovery model to SIMPLE for all user databases (excluding ReportServer databases).

## 📝 [set-instance-dop](./set-instance-dop.sql)

Configures instance-level parallelism settings based on CPU core count, adjusting max degree of parallelism and cost threshold for parallelism if still at default values.
