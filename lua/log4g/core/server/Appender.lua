--- The Appender.
-- @classmod Appender
Log4g.Core.Appender = Log4g.Core.Appender or {}
Log4g.Inst._Appenders = Log4g.Inst._Appenders or {}
local Appender = include("log4g/core/impl/Class.lua"):Extend()

function Appender:New(name, func)
    self.name = name or ""
    self.func = func or function() end
end

function Log4g.Core.Appender.RegisterAppender(name, func)
    local appender = Appender(name, func)
    table.insert(Log4g.Inst._Appenders, appender)

    return appender
end

local AppendConsole = include("log4g/core/server/appender/ConsoleAppender.lua")
Log4g.Inst._Appenders.ConsoleAppender = Appender("ConsoleAppender", AppendConsole)