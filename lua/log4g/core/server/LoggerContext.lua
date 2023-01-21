--- The LoggerContext.
-- @classmod LoggerContext
Log4g.Core.LoggerContext = Log4g.Core.LoggerContext or {}
local Class = include("log4g/core/impl/MiddleClass.lua")
local LoggerContext = Class("LoggerContext")
local HasKey = Log4g.Util.HasKey
local SetState = Log4g.Core.LifeCycle.SetState
local INITIALIZING = Log4g.Core.LifeCycle.State.INITIALIZING
local INITIALIZED = Log4g.Core.LifeCycle.State.INITIALIZED
local STARTING = Log4g.Core.LifeCycle.State.STARTING
local STARTED = Log4g.Core.LifeCycle.State.STARTED
local STOPPING = Log4g.Core.LifeCycle.State.STOPPING
local STOPPED = Log4g.Core.LifeCycle.State.STOPPED

function LoggerContext:Initialize(name)
    SetState(self, INITIALIZING)
    self.name = name
    self.folder = "log4g/server/loggercontext/" .. name
    self.timestarted = os.time()
    self.logger = {}
end

function LoggerContext:Start()
    SetState(self, STARTING)
    SetState(self, STARTED)
end

function LoggerContext:__tostring()
    return "LoggerContext: [name:" .. self.name .. "]" .. "[folder:" .. self.folder .. "]" .. "[timestarted:" .. self.timestarted .. "]" .. "[logger:" .. #self.logger .. "]"
end

--- Terminate the LoggerContext.
function LoggerContext:Terminate()
    MsgN("Starting the termination of LoggerContext: " .. self.name .. "...")
    SetState(self, STOPPING)
    local folder = "log4g/server/loggercontext/" .. self.name

    if file.Exists(folder, "DATA") then
        local Files, _ = file.Find(folder .. "/loggerconfig/*.json", "DATA")

        for _, j in pairs(Files) do
            file.Delete(folder .. "/loggerconfig/" .. j)
        end

        file.Delete(folder .. "/loggerconfig")
        file.Delete(folder)
        MsgN("LoggerContext termination: Successfully deleted LoggerContext folder which may contain LoggerConfigs.")
    else
        ErrorNoHalt("LoggerContext termination failed: Can't find the LoggerContext folder data/log4g/server/loggercontext/.\n")
    end

    SetState(self, STOPPED)

    if HasKey(Log4g.Hierarchy, self.name) then
        Log4g.Hierarchy[self.name] = nil
        MsgN("LoggerContext termination: Successfully removed LoggerContext from Hierarchy.")
    else
        ErrorNoHalt("LoggerContext termination failed: Can't find the LoggerContext in Hierarchy, may be nil already.\n")
    end

    MsgN("Termination completed.")
end

--- Get all the Loggers of the LoggerContext.
-- @return tbl loggers
function LoggerContext:GetLoggers()
    return self.logger
end

--- Get the name of the LoggerContext.
-- @return string name
function LoggerContext:GetName()
    return self.name
end

--- Check if a LoggerContext with the given name exists.
-- If the LoggerContext exists, return true.
-- @param name The name of the LoggerContext
-- @return bool hascontext
function Log4g.Core.LoggerContext.HasContext(name)
    if not isstring(name) then
        error("LoggerContext search failed: name must be a string.\n")
    end

    return HasKey(Log4g.Hierarchy, name)
end

--- Register a LoggerContext.
-- If the LoggerContext with the same name already exists, an error will be thrown without halt.
-- @param name The name of the LoggerContext
-- @return object loggercontext
function Log4g.Core.LoggerContext.RegisterLoggerContext(name)
    if not isstring(name) then
        error("LoggerContext registration failed: name must be a string.\n")
    end

    MsgN("Starting the registration of LoggerContext: " .. name .. "...")

    if not HasKey(Log4g.Hierarchy, name) then
        local loggercontext = LoggerContext:New(name)
        Log4g.Hierarchy[name] = loggercontext
        file.CreateDir("log4g/server/loggercontext/" .. name .. "/loggerconfig")
        SetState(Log4g.Hierarchy[name], INITIALIZED)
        Log4g.Hierarchy[name]:Start()
        MsgN("LoggerContext registration: Successfully created folder and Hierarchy item.")

        return Log4g.Hierarchy[name]
    else
        MsgN("LoggerContext registration not needed: A LoggerContext with the same name already exists.")

        return Log4g.Hierarchy[name]
    end
end