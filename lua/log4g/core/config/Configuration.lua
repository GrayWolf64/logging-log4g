--- Interface that must be implemented to create a Configuration.
-- @classmod Configuration
local Class = include("log4g/core/impl/MiddleClass.lua")
local Configuration = Class("Configuration")

--- A weak table which stores some private attributes of the Configuration object.
-- @local
-- @table PRIVATE
local PRIVATE = PRIVATE or setmetatable({}, {
    __mode = "k"
})

function Configuration:Initialize(name)
    self.name = name

    PRIVATE[self] = {
        appender = {},
        logger = {}
    }
end

function Configuration:AddAppender(appender)
    PRIVATE[self].appender[appender.name] = appender
end

function Configuration:AddLogger(name, loggerconfig)
    PRIVATE[self].logger[name] = loggerconfig
end

function Configuration:GetLoggers()
    return PRIVATE[self].logger
end

function Configuration:GetAppenders()
    return PRIVATE[self].appender
end

--- Register a Configuration.
function Log4g.Core.Config.Configuration.Register(name)
    return Configuration:New(name)
end