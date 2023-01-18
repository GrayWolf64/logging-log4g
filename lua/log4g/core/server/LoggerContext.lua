--- The LoggerContext.
-- @classmod LoggerContext
Log4g.Core.LoggerContext = Log4g.Core.LoggerContext or {}
local Class = include("log4g/core/impl/MiddleClass.lua")
local LoggerContext = Class("LoggerContext")
local HasKey = Log4g.Util.HasKey

function LoggerContext:Initialize(name)
    self.name = name
    self.folder = "log4g/server/loggercontext/" .. name
    self.timestarted = os.time()
    self.logger = {}
end

--- Delete the LoggerContext.
function LoggerContext:Delete()
    Log4g.Hierarchy[self.name] = nil
end

function LoggerContext:GetLoggers()
    return self.logger
end

--- Check if a LoggerContext with the given name exists.
-- If the LoggerContext exists, return true. Else, return false.
-- @param name The name of the LoggerContext
-- @return bool hascontext
function Log4g.Core.LoggerContext.HasContext(name)
    return HasKey(Log4g.Hierarchy, name)
end

--- Register a LoggerContext.
-- If the LoggerContext with the same name already exists, an error will be thrown without halt.
-- @param name The name of the LoggerContext
-- @param folder The folder of the LoggerContext
-- @return object loggercontext
function Log4g.Core.LoggerContext.RegisterLoggerContext(name)
    if name == "" or folder == "" then return end

    if not HasKey(Log4g.Hierarchy, name) then
        local loggercontext = LoggerContext:New(name)
        Log4g.Hierarchy[name] = loggercontext
        file.CreateDir("log4g/server/loggercontext/" .. name .. "/loggerconfig/")

        return loggercontext
    else
        ErrorNoHalt("LoggerContext registration failed: A LoggerContext with the same name already exists.\n")

        return Log4g.Hierarchy[name]
    end
end