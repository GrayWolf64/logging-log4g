--- The LoggerContext.
-- @classmod LoggerContext
Log4g.LoggerContexts = {}
local LoggerContext = include("log4g/core/impl/Class.lua"):Extend()
local HasKey = Log4g.Util.HasKey

function LoggerContext:New(name, folder)
    self.name = name or ""
    self.folder = folder or ""
end

--- Delete the LoggerContext.
function LoggerContext:Delete()
    Log4g.LoggerContexts[self.name] = nil
end

--- Check if a LoggerContext with the given name exists.
-- If the LoggerContext exists, return true. Else, return false.
-- @param name The name of the LoggerContext
-- @return bool hascontext
function Log4g.HasContext(name)
    for k, _ in pairs(Log4g.LoggerContexts) do
        if k == name then return true end
    end

    return false
end

--- Register a LoggerContext.
-- If the LoggerContext with the same name already exists, its folder will be overrode.
-- @param name The name of the LoggerContext
-- @param folder The folder of the LoggerContext
-- @return object loggercontext
function Log4g.Registrar.RegisterLoggerContext(name, folder)
    if name == "" or folder == "" then return end

    if not HasKey(Log4g.LoggerContexts, name) then
        local loggercontext = LoggerContext(name, folder)
        Log4g.LoggerContexts[name] = loggercontext

        return loggercontext
    else
        Log4g.LoggerContexts[name].folder = folder

        return Log4g.LoggerContexts[name]
    end
end