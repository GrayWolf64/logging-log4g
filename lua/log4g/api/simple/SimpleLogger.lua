--- The SimpleLogger.
-- This is the default logger that is used when no suitable logging implementation is available.
-- Now it only supports outputing to console.
-- @classmod SimpleLogger
Log4g.API.Simple.SimpleLogger = Log4g.API.Simple.SimpleLogger or {}
local Logger = Log4g.Core.Logger.GetClass()
local SimpleLogger = Logger:subclass("SimpleLogger")

function SimpleLogger:Initialize(name, context)
    Logger.Initialize(self, name, context)
end

--- Create a SimpleLogger object and add it into the SimpleLoggerContext.
-- @param name The name of the SimpleLogger
-- @param context SimpleLoggerContext object
function Log4g.API.Simple.SimpleLogger.Create(name, context)
    context.logger[name] = SimpleLogger(name, context)
end

--- Returns the SimpleLogger class for subclassing on other files.
-- @return object SimpleLogger
function Log4g.API.Simple.SimpleLogger.GetClass()
    return SimpleLogger
end