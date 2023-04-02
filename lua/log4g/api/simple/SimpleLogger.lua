--- The SimpleLogger.
-- This is the default logger that is used when no suitable logging implementation is available.
-- @classmod SimpleLogger
Log4g.API.Simple.SimpleLogger = Log4g.API.Simple.SimpleLogger or {}
local Logger = Log4g.Core.Logger.GetClass()
local SimpleLogger = Logger:subclass("SimpleLogger")
local IsSimpleLoggerContext = include("log4g/core/util/TypeUtil.lua").IsSimpleLoggerContext

function SimpleLogger:Initialize(name, context)
    Logger.Initialize(self, name, context)
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

--- Overrides `Logger:SetLevel()`.
-- @return bool false
function SimpleLogger:SetLevel()
    return false
end

--- Overrides `Logger:GetLevel()`.
-- @return bool false
function SimpleLogger:GetLevel()
    return false
end

--- Create a SimpleLogger object and add it into the SimpleLoggerContext.
-- @param name The name of the SimpleLogger
-- @param context SimpleLoggerContext object
function Log4g.API.Simple.SimpleLogger.Create(name, context)
    if not IsSimpleLoggerContext(context) then return end
    context:GetLoggers()[name] = SimpleLogger(name, context)
end

--- Returns the SimpleLogger class for subclassing on other files.
-- @return object SimpleLogger
function Log4g.API.Simple.SimpleLogger.GetClass()
    return SimpleLogger
end