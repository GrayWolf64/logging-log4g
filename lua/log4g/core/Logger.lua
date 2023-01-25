--- The Logger.
-- @classmod Logger
local Class = include("log4g/core/impl/MiddleClass.lua")
local Logger = Class("Logger")
local HasKey = Log4g.Util.HasKey
local SetState = Log4g.Core.LifeCycle.SetState
local INITIALIZING, INITIALIZED = Log4g.Core.LifeCycle.State.INITIALIZING, Log4g.Core.LifeCycle.State.INITIALIZED
local STARTING, STARTED = Log4g.Core.LifeCycle.State.STARTING, Log4g.Core.LifeCycle.State.STARTED
local STOPPING, STOPPED = Log4g.Core.LifeCycle.State.STOPPING, Log4g.Core.LifeCycle.State.STOPPED

function Logger:Initialize(tbl)
    SetState(self, INITIALIZING)
    self.name = tbl.name
    self.loggerconfig = tbl
    SetState(self, INITIALIZED)
end

function Logger:Start()
    SetState(self, STARTING)
    hook.Add(self.loggerconfig.eventname, self.loggerconfig.uid, CompileString(self.loggerconfig.func))
    SetState(self, STARTED)
end

--- Terminate the Logger.
function Logger:Terminate()
    SetState(self, STOPPING)
    file.Delete(self.loggerconfig.file)
    hook.Remove(self.loggerconfig.eventname, self.loggerconfig.uid)
    SetState(self, STOPPED)
    Log4g.LogManager[self.loggerconfig.loggercontext].logger[self.name] = nil
end

--- Get the Logger name.
-- @return string name
function Logger:GetName()
    return self.name
end

--- Get the Level associated with the Logger.
-- @return object level
function Logger:GetLevel()
    return self.loggerconfig.level
end

local function HasLogger(name)
    local manager = Log4g.LogManager

    for _, v in pairs(manager) do
        if HasKey(v.logger, name) then return true end
    end

    return false
end

--- Register a Logger.
-- `Log4g_PreLoggerRegistration` will be called before the registration.
-- `Log4g_PostLoggerRegistration` will be called after the registration succeeds.
-- If the Logger with the same name already exists, `Log4g_OnLoggerRegistrationFailure` will be called.
-- @param loggerconfig The Loggerconfig
-- @return object logger
function Log4g.Core.Logger.RegisterLogger(loggerconfig)
    if not istable(loggerconfig) or table.IsEmpty(loggerconfig) then return end
    hook.Run("Log4g_PreLoggerRegistration", loggerconfig.name)

    if not HasLogger(loggerconfig.name) then
        local logger = Logger:New(loggerconfig)
        local manager = Log4g.LogManager
        manager[loggerconfig.loggercontext].logger[loggerconfig.name] = logger
        manager[loggerconfig.loggercontext].logger[loggerconfig.name]:Start()
        hook.Run("Log4g_PostLoggerRegistration", loggerconfig.name)

        return manager[loggerconfig.loggercontext].logger[loggerconfig.name]
    else
        hook.Run("Log4g_OnLoggerRegistrationFailure", loggerconfig.name)

        return manager[loggerconfig.loggercontext].logger[loggerconfig.name]
    end
end