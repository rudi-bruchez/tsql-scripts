# Extended Events Management

Scripts for managing Extended Events sessions and files.

## 📝 [delete-event-files](./delete-event-files.sql)

Manages cleanup of extended event .xel files by scanning the log directory and deleting event files matching a specified session name. It turns on `show advanced options` and `xp_cmdshell` to delete the files, then puts both back to the values they had before the script ran. Windows only (`xp_cmdshell`).
