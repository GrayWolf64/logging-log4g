--- The SimpleLogger.
-- This is the default logger that is used when no suitable logging implementation is available.
-- Now it only supports outputing to console.
-- @classmod SimpleLogger
Log4g.API.Simple.SimpleLogger = Log4g.API.Simple.SimpleLogger or {}
local Class = include("log4g/core/impl/MiddleClass.lua")
local SimpleLogger = Class("SimpleLogger")
local SPACE = Log4g.SPACE

function SimpleLogger:Initialize(name, context)
    self.name = name
    self.contextname = context.name
end

--- Make SimpleLogger log a message.
-- @param level The Level object
-- @param ... args to output to console
function SimpleLogger:Log(level, ...)
    print(level:GetColor())
    MsgC(os.date("%Y-%m-%d %H-%M-%S"), SPACE, level:GetColor(), "[" .. level:Name() .. "]", SPACE, color_white, ...)
end

--- Create a SimpleLogger object and add it into the SimpleLoggerContext.
-- @param name The name of the SimpleLogger
-- @param context SimpleLoggerContext object
function Log4g.API.Simple.SimpleLogger.Create(name, context)
    context.logger[name] = SimpleLogger(name, context)
end

--- Returns the SimpleLogger class for subclassing on other files.
-- @return object SimpleLogger
function Log4g.API.Simple.SimpleLogger.Class()
    return SimpleLogger
end