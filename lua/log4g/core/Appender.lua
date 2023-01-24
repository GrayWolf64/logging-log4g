--- The Appender.
-- @classmod Appender
Log4g.Core.Appender = Log4g.Core.Appender or {}
local Class = include("log4g/core/impl/MiddleClass.lua")
local Appender = Class("Appender")

function Appender:Initialize(name, func)
    self.name = name
    self.func = func
end

function Log4g.Core.Appender.RegisterAppender(name, func)
    local appender = Appender:New(name, func)
    table.insert(Log4g.Core.Appender, appender)

    return appender
end

Log4g.Core.Appender.ConsoleAppender = Appender:New("ConsoleAppender", include("log4g/core/appender/ConsoleAppender.lua"))