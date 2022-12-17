Log4g.LoggerContexts = {}
local LoggerContext = include("log4g/core/server/impl/Class.lua"):Extend()

function LoggerContext:New(name, folder)
    self.name = name or ""
    self.folder = folder or ""
end

function LoggerContext:Delete()
    for k, _ in pairs(self) do
        self.k = nil
    end
end

function Log4g.RegisterLoggerContext(name, folder)
    local loggercontext = LoggerContext(name, folder)
    table.insert(Log4g.LoggerContexts, loggercontext)

    return loggercontext
end