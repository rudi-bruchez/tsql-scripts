# Extended Events Metadata

Scripts for querying Extended Events metadata and configuration.

## 📝 [event-fields](./event-fields.sql)

Displays all data fields available for extended event objects, including field names, data types, and descriptions across all packages.

## 📝 [events-in-package](./events-in-package.sql)

Lists all events available within a specified extended event package (defaults to 'filestream'), including their descriptions and capabilities.

## 📝 [file-targets](./file-targets.sql)

Reports extended event file targets and their current file status, showing filename patterns, current active files, and execution statistics for all event sessions.

## 📝 [packages](./packages.sql)

Queries available extended event packages on the server, showing their GUIDs, names, and descriptions.

## 📝 [xevent-sessions](./xevent-sessions.sql)

Lists all extended event sessions on the server with their configuration details (state, memory limits, dispatch latency, auto-start settings, and start time).
