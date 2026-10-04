# daily-check

Daily health check for a set of SQL Server instances. It queries each instance, builds a single HTML report and either emails it or writes it to a file.

## 📝 [daily-check](./daily-check.ps1)

Main script. It loops over the instances listed in `InstancesFile` (or a single `-Instance` given on the command line), runs `sql/database-health.sql` against `master` and `sql/job-exceptions.sql` against `msdb`, skips Azure SQL Database engines, and assembles the results into one HTML document with failed and canceled Agent jobs highlighted. Without `-OutputPath` it emails the report through `Send-DailyCheckReport`, writes a timestamped copy under `LogPath`, and deletes copies older than `RetentionDays`; with `-OutputPath` it only writes the HTML to that path. Exit code is `0` on success, `1` when an instance was unreachable or a job failed, and `2` on a configuration or input error.

To run it, copy `config.example.psd1` to `config.psd1` and `config/instances.txt.example` to `config/instances.txt`, then fill both in. The script loads `../modules/sql.psm1`, `../modules/stylesheet.ps1` and `../modules/smtp.ps1`, so keep the `powershell/modules` directory alongside it. Parameters: `-Instance` overrides the instances file with a single server, `-OutputPath` writes the report to a file instead of sending the mail.

## 📝 [config.example.psd1](./config.example.psd1)

Template for `config.psd1`, the PowerShell data file read at startup. It declares the mail settings (`EmailFrom`, `EmailTo`, `SmtpServer`, `SmtpPort`), the job anomaly thresholds (`JobDurationThresholdPercent`, `JobDurationThresholdMinutes`), the lookback and baseline windows (`LookbackHours`, `BaselineDays`), log retention (`RetentionDays`, `LogPath`), the path to the instances list (`InstancesFile`) and the connection encryption flags (`Encrypt`, `TrustServerCertificate`). Copy it to `config.psd1` before running.

## 📝 [instances.txt.example](./config/instances.txt.example)

Template for `config/instances.txt`, the list of instances to check, one server name per line (comment lines start with `#`). Copy it to `config/instances.txt` and list the instances to monitor.

## 📁 [sql](./sql/)

SQL query files.

## 📁 [config](./config/)

Configuration examples.
