--- Simple Status Logging which is meant to be used internally.
-- It records events that occur in the logging system.
-- @script StatusLogger.lua
local function AddHookAutoPrefix(eventname, func)
    hook.Add("Log4g_" .. eventname, "Log4g_StatusLogger", func)
end

AddHookAutoPrefix("PreLoggerContextTermination", function(self)
    MsgN("Starting the termination of LoggerContext: " .. self.name .. "...")
end)

AddHookAutoPrefix("OnLoggerContextFolderDeletionSuccess", function(self)
    MsgN("LoggerContext termination: Successfully deleted LoggerContext folder " .. self.folder .. ".")
end)

AddHookAutoPrefix("OnLoggerContextFolderDeletionFailure", function(self)
    MsgN("LoggerContext termination failed: Can't find the folder for LoggerContext " .. self.name .. ".")
end)

AddHookAutoPrefix("PostLoggerContextObjectRemovalSuccess", function()
    MsgN("LoggerContext termination: Successfully removed LoggerContext object.")
end)

AddHookAutoPrefix("OnLoggerContextObjectRemovalFailure", function()
    MsgN("LoggerContext termination failed: Can't find the LoggerContext object.")
end)

AddHookAutoPrefix("PostLoggerContextTerminationSuccess", function()
    MsgN("LoggerContext termination succeeded.")
end)

AddHookAutoPrefix("PreLoggerContextRegistration", function(name)
    MsgN("LoggerContext registration: Starting for " .. name .. "...")
end)

AddHookAutoPrefix("PostLoggerContextRegistration", function()
    MsgN("LoggerContext registration: Successfully created folder and object.")
end)

AddHookAutoPrefix("OnLoggerContextRegistrationFailure", function()
    MsgN("LoggerContext registration not needed: A LoggerContext with the same name already exists.")
end)