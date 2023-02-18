--- The Logger.
-- @classmod Logger
local Class = include("log4g/core/impl/MiddleClass.lua")
local Logger = Class("Logger")
local SetState = Log4g.Core.LifeCycle.SetState
local INITIALIZING, INITIALIZED = Log4g.Core.LifeCycle.State.INITIALIZING, Log4g.Core.LifeCycle.State.INITIALIZED
local STARTING, STARTED = Log4g.Core.LifeCycle.State.STARTING, Log4g.Core.LifeCycle.State.STARTED
local STOPPING, STOPPED = Log4g.Core.LifeCycle.State.STOPPING, Log4g.Core.LifeCycle.State.STOPPED
local RegisterLoggerConfig = Log4g.Core.Config.LoggerConfig.RegisterLoggerConfig

--- A weak table which stores some private attributes of the Logger object.
-- @local
-- @table PRIVATE
local PRIVATE = PRIVATE or setmetatable({}, {
    __mode = "k"
})

function Logger:Initialize(name, contextname)
    SetState(PRIVATE, INITIALIZING)
    self.name = name

    PRIVATE[self] = {
        contextname = contextname,
        loggerconfig = RegisterLoggerConfig(name)
    }

    SetState(PRIVATE, INITIALIZED)
end

--- Start the Logger.
function Logger:Start(loggerconfig)
    SetState(PRIVATE, STARTING)
    SetState(PRIVATE, STARTED)

    return self
end

--- Get the Logger name.
-- @return string name
function Logger:GetName()
    return self.name
end

--- Get the LoggerConfig of the Logger.
-- @return object loggerconfig
function Logger:GetLoggerConfig()
    return PRIVATE[self].loggerconfig
end

--- Terminate the Logger.
function Logger:Terminate()
    SetState(PRIVATE, STOPPING)
    PRIVATE[self] = nil
    SetState(PRIVATE, STOPPED)
end