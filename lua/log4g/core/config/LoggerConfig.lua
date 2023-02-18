--- The LoggerConfig.
-- @classmod LoggerConfig
local Class = include("log4g/core/impl/MiddleClass.lua")
local LoggerConfig = Class("LoggerConfig")
local SetState = Log4g.Core.LifeCycle.SetState
local INITIALIZING, INITIALIZED = Log4g.Core.LifeCycle.State.INITIALIZING, Log4g.Core.LifeCycle.State.INITIALIZED
local STOPPING, STOPPED = Log4g.Core.LifeCycle.State.STOPPING, Log4g.Core.LifeCycle.State.STOPPED

--- A weak table which stores some private attributes of the LoggerConfig object.
-- @local
-- @table PRIVATE
local PRIVATE = PRIVATE or setmetatable({}, {
    __mode = "k"
})

--- Initialize the LoggerConfig object.
-- This is meant to be used internally.
-- @param name The name of the LoggerConfig
-- @param level The Level object
function LoggerConfig:Initialize(name, level)
    PRIVATE[self] = {}
    SetState(PRIVATE[self], INITIALIZING)
    self.name = name
    PRIVATE[self].level = level
    SetState(PRIVATE[self], INITIALIZED)
end

--- Get the name of the LoggerConfig, same as `loggerconfig.name`.
function LoggerConfig:GetName()
    return self.name
end

--- Remove the LoggerConfig.
function LoggerConfig:Remove()
    SetState(PRIVATE[self], STOPPING)
    SetState(PRIVATE[self], STOPPED)
    PRIVATE[self] = nil
end

--- Factory method to create a LoggerConfig.
-- @param loggername The name for the Logger
-- @param config The Configuration
-- @return object loggerconfig
function Log4g.Core.Config.LoggerConfig.Create(loggername, config, level)
    local loggerconfig = LoggerConfig(name, level)
    config:AddLogger(loggername, loggerconfig)

    return loggerconfig
end