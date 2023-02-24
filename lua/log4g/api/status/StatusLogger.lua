--- Simple Status Logging which is meant to be used internally.
-- It logs events that occur in the logging system.
-- Subclassing SimpleLogger.
-- @classmod StatusLogger
local SimpleLogger = Log4g.API.Simple.SimpleLogger.Class()
local StatusLogger = SimpleLogger:subclass("StatusLogger")

function StatusLogger:Initialize(name, context)
    SimpleLogger:Initialize(self, name, context)
end