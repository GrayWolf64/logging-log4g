--- The Logger.
-- @classmod Logger
Log4g.Core.Logger = Log4g.Core.Logger or {}
local Class = include("log4g/core/impl/MiddleClass.lua")
local Logger = Class("Logger")
local SetState = Log4g.Core.LifeCycle.SetState
local INITIALIZING, INITIALIZED = Log4g.Core.LifeCycle.State.INITIALIZING, Log4g.Core.LifeCycle.State.INITIALIZED
local STARTING, STARTED = Log4g.Core.LifeCycle.State.STARTING, Log4g.Core.LifeCycle.State.STARTED
local STOPPING, STOPPED = Log4g.Core.LifeCycle.State.STOPPING, Log4g.Core.LifeCycle.State.STOPPED
local CreateLoggerConfig = Log4g.Core.Config.LoggerConfig.Create

--- A weak table which stores some private attributes of the Logger object.
-- @local
-- @table PRIVATE
local PRIVATE = PRIVATE or setmetatable({}, {
    __mode = "k"
})

function Logger:Initialize(name, context, level)
    PRIVATE[self] = {}
    SetState(PRIVATE[self], INITIALIZING)
    self.name = name
    PRIVATE[self].contextname = context.name
    PRIVATE[self].loggerconfig = CreateLoggerConfig(name, context:GetConfiguration(), level)
    SetState(PRIVATE[self], INITIALIZED)
end

--- Start the Logger.
function Logger:Start()
    SetState(PRIVATE[self], STARTING)
    SetState(PRIVATE[self], STARTED)
end

--- Get the LoggerConfig of the Logger.
-- @return object loggerconfig
function Logger:GetLoggerConfig()
    return PRIVATE[self].loggerconfig
end

--- Terminate the Logger.
function Logger:Terminate()
    SetState(PRIVATE[self], STOPPING)
    SetState(PRIVATE[self], STOPPED)
    PRIVATE[self] = nil
end

function Log4g.Core.Logger.Create(name, context, level)
    context:GetLoggers()[name] = Logger(name, context, level)
end