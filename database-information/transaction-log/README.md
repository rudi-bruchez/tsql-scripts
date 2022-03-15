# Transaction log information queries

## 📝 [Transaction log active portion](./active-portion.sql)

Gives information about the position of the active VLFs inside the transaction log, and size before and after this active position. Useful to know where is the active portion within the transaction log, and how much space can be reclaimed by a file shrink.