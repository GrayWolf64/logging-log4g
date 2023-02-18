--- The SimpleLogger.
-- @classmod SimpleLogger
local Class = include("log4g/core/impl/MiddleClass.lua")
local SimpleLogger = Class("SimpleLogger")

function SimpleLogger:Initialize(name, context)
    self.name = name
    self.contextname = context.name
end

function SimpleLogger:Log(level, ...)
    Msg(level:GetColor(), ...)
end

function Log4g.API.Simple.SimpleLogger.Create(name, context)
    context.logger[name] = SimpleLogger(name, context)
end