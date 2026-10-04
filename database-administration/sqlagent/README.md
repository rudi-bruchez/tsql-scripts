# SQL Agent

SQL Server Agent job management and monitoring scripts.

## 📝 [add-notification-to-all-jobs](./add-notification-to-all-jobs.sql)

Updates all enabled jobs to add email notification on failure to an operator: the first enabled operator with an email address (lowest id). Stops with an error if there is none.

## 📝 [disable-all-jobs](./disable-all-jobs.sql)

Disables all enabled SQL Agent jobs through `sp_update_job`, so that SQL Agent stops running them at once, and prints the name of each job disabled so they can be enabled again. For maintenance or troubleshooting purposes.

## 📝 [increase-agent-history](./increase-agent-history.sql)

Increases SQL Agent job history retention to 10,000 total rows with 500 rows maximum per job.

## 📝 [job-by-id](./job-by-id.sql)

Finds and displays job details including steps and last execution date for a specific job identified by its GUID.

## 📝 [jobs](./jobs.sql)

Lists all enabled SQL Agent jobs with their descriptions and categories, ordered alphabetically for inventory purposes.

## 📝 [jobs-history](./jobs-history.sql)

Shows enabled jobs with their steps that ran for more than one minute, sorted by job name and descending execution date.

## 📝 [job-steps-perf-analysis](./job-steps-perf-analysis.sql)

Analyzes job step execution history showing average and maximum duration, execution count, and first/last run dates for performance trending.

## 📝 [sqlagentroles](./sqlagentroles.sql)

Lists all users and accounts that are members of SQL Server Agent roles (SQLAgent*) in the msdb database.
