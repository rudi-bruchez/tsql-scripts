# Connections

Scripts for analyzing SQL Server connections.

## 📝 [connection-encryption](./connection-encryption.sql)

Lists user connections grouped by login, host, and encryption setting. Useful for auditing which connections are encrypted and which are not.

## 📝 [opened-connections](./opened-connections.sql)

Lists all open user sessions excluding the current session and common system applications (SQL Agent, SSMS, CEIP). Shows database, login, host, and session details.
