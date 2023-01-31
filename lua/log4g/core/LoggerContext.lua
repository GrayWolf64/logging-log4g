--- The LoggerContext.
-- @classmod LoggerContext
local Class                      = include("log4g/core/impl/MiddleClass.lua")
local LoggerContext              = Class("LoggerContext")
local HasKey                     = Log4g.Util.HasKey
local DeleteFolderRecursive      = Log4g.Util.DeleteFolderRecursive
local AddContextLookupContext    = Log4g.Core.LoggerContext.Lookup.AddContext
local RemoveContextLookupContext = Log4g.Core.LoggerContext.Lookup.RemoveContext
local SetState                   = Log4g.Core.LifeCycle.SetState
local INITIALIZING,               INITIALIZED = Log4g.Core.LifeCycle.State.INITIALIZING, Log4g.Core.LifeCycle.State.INITIALIZED
local STARTING,                   STARTED     = Log4g.Core.LifeCycle.State.STARTING,     Log4g.Core.LifeCycle.State.STARTED
local STOPPING,                   STOPPED     = Log4g.Core.LifeCycle.State.STOPPING,     Log4g.Core.LifeCycle.State.STOPPED

function LoggerContext:Initialize(name)
    SetState(self, INITIALIZING)
    self.name = name
    self.folder = "log4g/server/loggercontext/" .. name
    self.timestarted = os.time()
    SetState(self, INITIALIZED)
end

--- Get the name of the LoggerContext.
-- @return string name
function LoggerContext:GetName()
    return self.name
end

--- Get the folder of the LoggerContext.
-- @return string folder
function LoggerContext:GetFolder()
    return self.folder
end

--- Get when the LoggerContext was started in UNIX time.
-- @return string timestarted
function LoggerContext:TimeStarted()
    return self.timestarted
end

function LoggerContext:Start()
    SetState(self, STARTING)
    SetState(self, STARTED)

    return self
end

function LoggerContext:__tostring()
    return "LoggerContext: [name:" .. self:GetName() .. "]" .. "[folder:" .. self:GetFolder() .. "]" .. "[timestarted:" .. self:TimeStarted() .. "]"
end

--- Terminate the LoggerContext.
function LoggerContext:Terminate()
    SetState(self, STOPPING)
    RemoveContextLookupContext(self:GetName())
    local folder = self:GetFolder()

    if file.Exists(folder, "DATA") then
        DeleteFolderRecursive(folder, "DATA")
    else
        hook.Run("Log4g_OnLoggerContextFolderDeletionFailure", self)
    end

    SetState(self, STOPPED)
    hook.Run("Log4g_PostLoggerContextTermination")
    self = nil
end

--- This is where all the LoggerContexts are stored.
-- LoggerContexts may include some Loggers which may also include Appender, Level objects and so on.
-- @local
-- @table INSTANCES
local INSTANCES = INSTANCES or {}

function Log4g.Core.LoggerContext.GetAll()
    return INSTANCES
end

--- Get the LoggerContext with the right name.
-- @return object loggercontext
function Log4g.Core.LoggerContext.Get(name)
    if not HasKey(INSTANCES, name) then return end

    return INSTANCES[name]
end

--- Register a LoggerContext.
-- This is used for APIs.
-- If the LoggerContext with the same name already exists, `Log4g_OnLoggerContextRegistrationFailure` will be called.
-- @param collection Where to put the LoggerContext, must be a table
-- @param name The name of the LoggerContext
-- @return object loggercontext
function Log4g.Core.LoggerContext.Register(name)
    if not HasKey(INSTANCES, name) then
        local loggercontext = LoggerContext:New(name)
        INSTANCES[name] = loggercontext:Start()
        AddContextLookupContext(name)
        file.CreateDir("log4g/server/loggercontext/" .. name .. "/loggerconfig")
        hook.Run("Log4g_PostLoggerContextRegistration", name)

        return INSTANCES[name]
    else
        hook.Run("Log4g_OnLoggerContextRegistrationFailure")

        return INSTANCES[name]
    end
end