--- The Appender.
-- @classmod Appender
Log4g.Instances._Appenders = Log4g.Instances._Appenders or {}
local Appender = include("log4g/core/impl/Class.lua"):Extend()

function Appender:New(name, func)
    self.name = name or ""
    self.func = func or function() end
end

function Log4g.Core.Appenders.RegisterAppender(name, func)
    local appender = Appender(name, func)
    table.insert(Log4g.Instances._Appenders, appender)

    return appender
end

local AppendConsole = include("log4g/core/server/appender/ConsoleAppender.lua")
Log4g.Instances._Appenders.ConsoleAppender = Appender("ConsoleAppender", AppendConsole)