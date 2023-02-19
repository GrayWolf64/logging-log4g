--- Simple Status Logging which is meant to be used internally.
-- It logs events that occur in the logging system.
-- Subclassing SimpleLogger.
-- @classmod StatusLogger
local CLASS = Log4g.API.Simple.SimpleLogger.Class()
local StatusLogger = CLASS:subclass("StatusLogger")

function StatusLogger:Initialize(name, context)
    CLASS:Initialize(self, name, context)
end