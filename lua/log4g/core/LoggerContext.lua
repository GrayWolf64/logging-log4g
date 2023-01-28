--- The LoggerContext.
-- @classmod LoggerContext
Log4g.Core.LoggerContext = Log4g.Core.LoggerContext or {}
local Class = include("log4g/core/impl/MiddleClass.lua")
local LoggerContext = Class("LoggerContext")
local HasKey = Log4g.Util.HasKey
local DeleteFolderRecursive = Log4g.Util.DeleteFolderRecursive
local SetState = Log4g.Core.LifeCycle.SetState
local INITIALIZING, INITIALIZED = Log4g.Core.LifeCycle.State.INITIALIZING, Log4g.Core.LifeCycle.State.INITIALIZED
local STARTING, STARTED = Log4g.Core.LifeCycle.State.STARTING, Log4g.Core.LifeCycle.State.STARTED
local STOPPING, STOPPED = Log4g.Core.LifeCycle.State.STOPPING, Log4g.Core.LifeCycle.State.STOPPED

function LoggerContext:Initialize(name)
    SetState(self, INITIALIZING)
    self.name = name
    self.folder = "log4g/server/loggercontext/" .. name
    self.timestarted = os.time()
    self.logger = {}
    SetState(self, INITIALIZED)
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
    hook.Run("Log4g_PreLoggerContextTermination", self)
    SetState(self, STOPPING)

    if file.Exists(self.folder, "DATA") then
        DeleteFolderRecursive(self.folder, "DATA")
    else
        hook.Run("Log4g_OnLoggerContextFolderDeletionFailure", self)
    end

    SetState(self, STOPPED)
    self = nil
    hook.Run("Log4g_PostLoggerContextTermination")
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

--- Register a LoggerContext.
-- This is used for APIs.
-- If the LoggerContext with the same name already exists, an error will be thrown without halt.
-- @param collection Where to put the LoggerContext, must be a table
-- @param name The name of the LoggerContext
-- @return object loggercontext
function Log4g.Core.LoggerContext.Register(collection, name)
    hook.Run("Log4g_PreLoggerContextRegistration", name)

    if not HasKey(collection, name) then
        local loggercontext = LoggerContext:New(name)
        collection[name] = loggercontext
        collection[name]:Start()
        file.CreateDir("log4g/server/loggercontext/" .. name .. "/loggerconfig")
        hook.Run("Log4g_PostLoggerContextRegistration", name)

        return collection[name]
    else
        hook.Run("Log4g_OnLoggerContextRegistrationFailure")

        return collection[name]
    end
end