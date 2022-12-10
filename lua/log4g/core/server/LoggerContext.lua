Log4g.LoggerContexts = {}
local Object = include("log4g/core/server/Class.lua")
local LoggerContext = Object:Extend()

function LoggerContext:New(name, folder)
    self.name = name or ""
    self.folder = folder or ""
end

function LoggerContext:Delete()
    self.name = nil
    self.folder = nil
end

function Log4g.NewLoggerContext(name, folder)
    local loggercontext = LoggerContext(name, folder)
    table.insert(Log4g.LoggerContexts, loggercontext)

    return loggercontext
end