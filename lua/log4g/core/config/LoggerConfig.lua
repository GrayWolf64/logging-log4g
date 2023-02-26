--- The LoggerConfig.
-- @classmod LoggerConfig
Log4g.Core.Config.LoggerConfig = Log4g.Core.Config.LoggerConfig or {}
local Class = include("log4g/core/impl/MiddleClass.lua")
local LoggerConfig = Class("LoggerConfig")

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
function LoggerConfig:Initialize(name)
    PRIVATE[self] = {}
    self.name = name
end

--- Sets the logging Level.
-- @param level The Logging Level
function LoggerConfig:SetLevel(level)
    PRIVATE[self].level = level
end

--- Sets the parent of this LoggerConfig.
-- @param lc loggerconfig
function LoggerConfig:SetParent(lc)
    PRIVATE[self].parent = lc.name
end

--- Factory method to create a LoggerConfig.
-- @param loggername The name for the Logger
-- @param config The Configuration
-- @param level The Logging Level
-- @return object loggerconfig
function Log4g.Core.Config.LoggerConfig.Create(loggername, config, level)
    local loggerconfig = LoggerConfig(name)
    loggerconfig:SetLevel(level)
    config:AddLogger(loggername, loggerconfig)

    return loggerconfig
end