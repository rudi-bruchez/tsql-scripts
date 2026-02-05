# Automatic Seeding

Scripts for monitoring AlwaysOn Availability Group automatic seeding operations.

## 📝 [extended-events-session](./extended-events-session.sql)

Creates an Extended Events session to capture automatic seeding events for troubleshooting.

## 📝 [monitoring-on-principal](./monitoring-on-principal.sql)

Monitors physical seeding progress on the principal replica showing transfer rate, transferred size, database size, percentage complete, estimated completion time, and IO/network wait times.

## 📝 [monitoring-on-secondary](./monitoring-on-secondary.sql)

Monitors seeding progress from the secondary replica perspective.

## 📝 [seeding-history](./seeding-history.sql)

Shows automatic seeding history and past operations.
