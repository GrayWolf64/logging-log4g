--- A simple Status Logger which is meant to be used internally.
-- It records events that occur in the logging system.
-- @script StatusLogger.lua
hook.Add("Log4g_PreLoggerContextTermination", "Log4g_StatusLogging_PreLoggerContextTermination", function(self)
    MsgN("Starting the termination of LoggerContext: " .. self.name .. "...")
end)

hook.Add("Log4g_OnLoggerContextFolderDeletionSuccess", "Log4g_StatusLogging_OnLoggerContextFolderDeletionSuccess", function(self)
    MsgN("LoggerContext termination: Successfully deleted LoggerContext folder: " .. self.folder .. ".")
end)

hook.Add("Log4g_OnLoggerContextFolderDeletionFailure", "Log4g_StatusLogging_OnLoggerContextFolderDeletionFailure", function(self)
    MsgN("LoggerContext termination failed: Can't find the folder for LoggerContext: " .. self.name .. ".")
end)

hook.Add("Log4g_PostLoggerContextObjectRemovalSuccess", "Log4g_StatusLogging_PostLoggerContextObjectRemovalSuccess", function()
    MsgN("LoggerContext termination: Successfully removed LoggerContext object.")
end)

hook.Add("Log4g_OnLoggerContextObjectRemovalFailure", "Log4g_StatusLogging_OnLoggerContextObjectRemovalFailure", function()
    MsgN("LoggerContext termination failed: Can't find the LoggerContext object.")
end)

hook.Add("Log4g_PostLoggerContextTerminationSuccess", "Log4g_StatusLogging_PostLoggerContextTerminationSuccess", function()
    MsgN("LoggerContext termination succeeded.")
end)

hook.Add("Log4g_PreLoggerContextRegistration", "Log4g_StatusLogging_PreLoggerContextRegistration", function(name)
    MsgN("LoggerContext registration: Starting for: " .. name .. "...")
end)

hook.Add("Log4g_PostLoggerContextRegistration", "Log4g_StatusLogging_PostLoggerContextRegistration", function()
    MsgN("LoggerContext registration: Successfully created folder and object.")
end)

hook.Add("Log4g_OnLoggerContextRegistrationFailure", "Log4g_StatusLogging_OnLoggerContextRegistrationFailure", function()
    MsgN("LoggerContext registration not needed: A LoggerContext with the same name already exists.")
end)