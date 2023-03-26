--- The SimpleLogger.
-- This is the default logger that is used when no suitable logging implementation is available.
-- @classmod SimpleLogger
Log4g.API.Simple.SimpleLogger = Log4g.API.Simple.SimpleLogger or {}
local Logger = Log4g.Core.Logger.GetClass()
local SimpleLogger = Logger:subclass("SimpleLogger")
local istable = istable

function SimpleLogger:Initialize(name, context, level)
    Logger.Initialize(self, name, context)
    self.level = level
end

--- Overrides `Logger:SetLoggerConfig()`.
-- @return bool false
function SimpleLogger:SetLoggerConfig()
    return false
end

--- Overrides `Logger:GetLoggerConfigN()`.
-- @return bool false
function SimpleLogger:GetLoggerConfigN()
    return false
end

--- Overrides `Logger:GetLoggerConfig()`.
-- @return bool false
function SimpleLogger:GetLoggerConfig()
    return false
end

--- Gets the Level associated with the Logger.
-- Overrides `Logger:GetLevel()`.
-- @return object level
function SimpleLogger:GetLevel()
    return self.level
end

function SimpleLogger:SetLevel(level)
    if not istable(level) then return end
    if self.level == level then return end
    self.level = level
end

--- Create a SimpleLogger object and add it into the SimpleLoggerContext.
-- @param name The name of the SimpleLogger
-- @param context SimpleLoggerContext object
function Log4g.API.Simple.SimpleLogger.Create(name, context, level)
    context.logger[name] = SimpleLogger(name, context, level)
end

--- Returns the SimpleLogger class for subclassing on other files.
-- @return object SimpleLogger
function Log4g.API.Simple.SimpleLogger.GetClass()
    return SimpleLogger
end