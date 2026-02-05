# Service Broker

Scripts for managing and troubleshooting SQL Server Service Broker.

## 📝 [clean-receive-queue](./clean-receive-queue.sql)

Cleans a Service Broker queue by receiving and discarding messages in a loop. Properly ends conversations for EndDialog and Error messages. Use when a queue has accumulated useless messages. Monitor transaction log usage during execution.

## 📝 [drop-routes](./drop-routes.sql)

Drops all Service Broker routes in a database except the AutoCreatedLocal route. Useful for cleanup when decommissioning Service Broker or resetting routing configuration.

## 📝 [queues-internal-information](./queues-internal-information.sql)

Retrieves internal details about Service Broker queues including their underlying internal tables, indexes, row counts, compression settings, and page allocation. Useful for troubleshooting queue performance and storage issues.
