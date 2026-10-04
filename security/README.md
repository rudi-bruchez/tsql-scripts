# Security

Scripts for auditing and managing SQL Server security: logins, users, roles, and permissions.

## 📝 [block-by-logon-trigger](./block-by-logon-trigger.sql)

Creates a logon trigger that acts as a Database Application Firewall (DAF). Blocks connections from unauthorized hosts or IP addresses and logs blocked attempts. Useful when other security solutions are not available.

## 📝 [list-and-generate-role-members](./list-and-generate-role-members.sql)

Lists the members of user-defined database roles in the current database and generates the `ALTER ROLE ... ADD MEMBER` statements to recreate the memberships. Fixed roles (`db_owner`, `db_datareader`, `db_datawriter` and the others) are excluded: their members are not listed. Useful for documenting or migrating database security.

## 📝 [list-and-generate-roles](./list-and-generate-roles.sql)

Lists custom database roles and generates CREATE ROLE DDL statements. Useful for documenting or migrating database roles to another database.

## 📝 [list-logins](./list-logins.sql)

Lists the enabled Windows and SQL logins of the instance (the `sa` login and the `NT SERVICE` and `NT AUTHORITY\SYSTEM` logins excepted) with SID, creation date, default database and language, and generates the CREATE LOGIN statements to recreate them on another instance, with the same SID. With `@withPassword = 1` (default), SQL logins keep their password through its hash (`PASSWORD = 0x... HASHED`). With `@withPassword = 0`, they get a `<password>` placeholder instead, to replace before running the statement.

## 📝 [orphaned-users](./orphaned-users.sql)

Finds orphaned database users - users that exist in a database but have no corresponding server login. Common after database restores or migrations.

## 📝 [permissions-audit](./permissions-audit.sql)

Comprehensive security audit that lists logins with server role memberships, database users with role memberships, and detailed database permissions. Provides a complete view of who has access to what.

## 📝 [permissions-audit-by-object](./permissions-audit-by-object.sql)

Audits SELECT permissions on a table of the `dbo` schema, named in `@table_name`. Shows the users and role members who have SELECT access to it, through a GRANT on the table, a GRANT on the `dbo` schema, or membership of `db_datareader`. Limits: the `dbo` schema is hard-coded, only GRANT SELECT is considered (other permissions are ignored, and a DENY is not reported, so a user listed here may in fact be denied), and roles nested in roles are not followed.

## 📝 [sysadmin-logins](./sysadmin-logins.sql)

Lists all logins that have sysadmin privileges. Essential for security audits to identify who has full administrative access to the SQL Server instance.
