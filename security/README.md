# Security

Scripts for auditing and managing SQL Server security: logins, users, roles, and permissions.

## 📝 [block-by-logon-trigger](./block-by-logon-trigger.sql)

Creates a logon trigger that acts as a Database Application Firewall (DAF). Blocks connections from unauthorized hosts or IP addresses and logs blocked attempts. Useful when other security solutions are not available.

## 📝 [list-and-generate-role-members](./list-and-generate-role-members.sql)

Lists database role members and generates DDL (ALTER ROLE ADD MEMBER) statements to recreate the role memberships. Useful for documenting or migrating database security.

## 📝 [list-and-generate-roles](./list-and-generate-roles.sql)

Lists custom database roles and generates CREATE ROLE DDL statements. Useful for documenting or migrating database roles to another database.

## 📝 [list-logins](./list-logins.sql)

Lists all logins in the SQL Server instance with details including SID, creation date, and default database. Generates CREATE LOGIN DDL statements with password hashes for migration purposes.

## 📝 [orphaned-users](./orphaned-users.sql)

Finds orphaned database users - users that exist in a database but have no corresponding server login. Common after database restores or migrations.

## 📝 [permissions-audit](./permissions-audit.sql)

Comprehensive security audit that lists logins with server role memberships, database users with role memberships, and detailed database permissions. Provides a complete view of who has access to what.

## 📝 [permissions-audit-by-object](./permissions-audit-by-object.sql)

Audits SELECT permissions on a specific database object. Shows all users and role members who have SELECT access to a table, including permissions inherited through roles like db_datareader.

## 📝 [sysadmin-logins](./sysadmin-logins.sql)

Lists all logins that have sysadmin privileges. Essential for security audits to identify who has full administrative access to the SQL Server instance.
