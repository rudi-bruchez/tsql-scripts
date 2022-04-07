-----------------------------------------------------------------
-- Clean a large Service Broker queue containing useless messages
-- Beware of transaction log, check with sp_logspace in the 
-- stored-procedures directory.
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;

DECLARE 
	@conversation_handle UNIQUEIDENTIFIER,
	@message_type_name SYSNAME,
	@rowcount int = 1;

WHILE @rowcount > 0
BEGIN
	RECEIVE TOP(1) 
		@conversation_handle = conversation_handle,
		@message_type_name = message_type_name
	FROM [dbo].[my_queue]; -- CHANGE HERE THE NAME OF THE QUEUE

	SET @rowcount = @@ROWCOUNT;

    IF (@message_type_name IN ( N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog',
                                N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'))
    BEGIN
		BEGIN TRY
			END CONVERSATION @conversation_handle;
        END TRY
		BEGIN CATCH
			PRINT ERROR_MESSAGE();
        END CATCH
	END;
END;
