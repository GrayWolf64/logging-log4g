--- The Appender.
-- @classmod Appender
Log4g.Core.Appender = Log4g.Core.Appender or {}
Log4g.Core.Appender.Buffer = Log4g.Core.Appender.Buffer or {}
local Class = include("log4g/core/impl/MiddleClass.lua")
local Appender = Class("Appender")

function Appender:Initialize(name, func)
    self.name = name
    self.func = func
end

function Log4g.Core.Appender.RegisterAppender(name, func)
    local appender = Appender:New(name, func)
    table.insert(Log4g.Core.Appender.Buffer, appender)

    return appender
end

Log4g.Core.Appender.Buffer.ConsoleAppender = Appender:New("ConsoleAppender", include("log4g/core/appender/ConsoleAppender.lua"))