--- The Logger.
-- @classmod Logger
local Class = include("log4g/core/impl/MiddleClass.lua")
local Logger = Class("Logger")
local SetState = Log4g.Core.LifeCycle.SetState
local INITIALIZING, INITIALIZED = Log4g.Core.LifeCycle.State.INITIALIZING, Log4g.Core.LifeCycle.State.INITIALIZED
local STARTING, STARTED = Log4g.Core.LifeCycle.State.STARTING, Log4g.Core.LifeCycle.State.STARTED
local STOPPING, STOPPED = Log4g.Core.LifeCycle.State.STOPPING, Log4g.Core.LifeCycle.State.STOPPED
local HasKey = Log4g.Util.HasKey
local RegisterLoggerConfig = Log4g.Core.Config.LoggerConfig.RegisterLoggerConfig
local GetLoggerConfig = Log4g.Core.Config.LoggerConfig.Get

function Logger:Initialize(name)
    SetState(self, INITIALIZING)
    self.name = name
    SetState(self, INITIALIZED)
end

--- Start the Logger.
function Logger:Start(loggerconfig)
    SetState(self, STARTING)
    SetState(self, STARTED)

    return self
end

--- Get the Logger name.
-- @return string name
function Logger:GetName()
    return self.name
end

--- Get the LoggerConfig name of the Logger.
-- @return string loggerconfig
function Logger:GetLoggerConfig()
    return GetLoggerConfig(self.name)
end

--- Set the Log Level for the Logger.
-- @param level The Level object.
function Logger:SetLevel(level)
    self.level = function()
        return level
    end
end

function Logger:ALL()
end

function Logger:TRACE()
end

function Logger:DEBUG()
end

function Logger:INFO()
end

function Logger:WARN()
end

function Logger:ERROR()
end

function Logger:FATAL()
end

function Logger:OFF()
end

--- This is where all the Loggers are stored.
-- @local
-- @table INSTANCES
local INSTANCES = INSTANCES or {}

--- Terminate the Logger.
function Logger:Terminate()
    SetState(self, STOPPING)
    SetState(self, STOPPED)
    INSTANCES[self.name] = nil
end

--- Get all the Loggers.
-- @return table instances
function Log4g.Core.Logger.GetAll()
    return INSTANCES
end

--- Create a Logger.
-- `Log4g_PreLoggerRegistration` will be called before the registration.
-- `Log4g_PostLoggerRegistration` will be called after the registration succeeds.
-- If the Logger with the same name already exists, `Log4g_OnLoggerRegistrationFailure` will be called.
-- @return object logger
function Log4g.Core.Logger.Register(name)
    if not HasKey(INSTANCES, name) then
        INSTANCES[name] = Logger:New(name)
        RegisterLoggerConfig(name)
        hook.Run("Log4g_PostLoggerRegistration", name)

        return logger
    else
        hook.Run("Log4g_OnLoggerRegistrationFailure", name)

        return INSTANCES[name]
    end
end