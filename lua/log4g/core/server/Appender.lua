Log4g.Appenders = {}
local Appender = include("log4g/core/server/impl/Class.lua"):Extend()

function Appender:New(name, func)
    self.name = name or ""
    self.func = func or function() end
end

function Log4g.RegisterAppender(name, func)
    local appender = Appender(name, func)
    table.insert(Log4g.Appenders, appender)

    return appender
end

local AppendConsole = include("log4g/core/server/appender/ConsoleAppender.lua")
Log4g.Appenders["ConsoleAppender"] = Appender("ConsoleAppender", AppendConsole)