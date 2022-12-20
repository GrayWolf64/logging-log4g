--- The LoggerContext.
-- @classmod LoggerContext
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

--- Register a LoggerContext.
-- If the LoggerContext with the same name already exists, its name and folder won't be changed.
-- @param name The name of the LoggerContext
-- @param folder The folder of the LoggerContext
-- @return table loggercontext
function Log4g.RegisterLoggerContext(name, folder)
    local loggercontext = LoggerContext(name, folder)
    table.insert(Log4g.LoggerContexts, loggercontext)

    return loggercontext
end