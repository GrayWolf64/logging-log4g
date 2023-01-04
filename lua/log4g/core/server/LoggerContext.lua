--- The LoggerContext.
-- @classmod LoggerContext
Log4g.Core.LoggerContext.Instances = Log4g.Core.LoggerContext.Instances or {}
local LoggerContext = include("log4g/core/impl/Class.lua"):Extend()
local HasKey = Log4g.Util.HasKey

function LoggerContext:New(name, folder)
    self.name = name or ""
    self.folder = folder or ""
end

--- Delete the LoggerContext.
function LoggerContext:Delete()
    Log4g.Core.LoggerContext.Instances[self.name] = nil
end

--- Check if a LoggerContext with the given name exists.
-- If the LoggerContext exists, return true. Else, return false.
-- @param name The name of the LoggerContext
-- @return bool hascontext
function Log4g.Core.LoggerContext.HasContext(name)
    for k, _ in pairs(Log4g.Core.LoggerContext.Instances) do
        if k == name then return true end
    end

    return false
end

--- Register a LoggerContext.
-- If the LoggerContext with the same name already exists, its folder will be overrode.
-- @param name The name of the LoggerContext
-- @param folder The folder of the LoggerContext
-- @return object loggercontext
function Log4g.Core.LoggerContext.RegisterLoggerContext(name, folder)
    if name == "" or folder == "" then return end

    if not HasKey(Log4g.Core.LoggerContext.Instances, name) then
        local loggercontext = LoggerContext(name, folder)
        Log4g.Core.LoggerContext.Instances[name] = loggercontext

        return loggercontext
    else
        Log4g.Core.LoggerContext.Instances[name].folder = folder

        return Log4g.Core.LoggerContext.Instances[name]
    end
end