--- The Appender.
-- @classmod Appender
Log4g.Core.Appender = Log4g.Core.Appender or {}
Log4g.Inst._Appenders = Log4g.Inst._Appenders or {}
local Class = include("log4g/core/impl/MiddleClass.lua")
local Appender = Class("Appender")

function Appender:Initialize(name, func)
    self.name = name or ""
    self.func = func or function() end
end

local AppendConsole = include("log4g/core/server/appender/ConsoleAppender.lua")
Log4g.Inst._Appenders.ConsoleAppender = Appender:New("ConsoleAppender", AppendConsole)

function Log4g.Core.Appender.RegisterAppender(name, func)
    local appender = Appender:New(name, func)
    table.insert(Log4g.Inst._Appenders, appender)

    return appender
end