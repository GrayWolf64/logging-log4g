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
        context = {},
        appender = {},
        loggerconfig = {}
    }
end

--- Sets the LoggerContext for the Configuration.
-- This is meant to be used internally when creating a LoggerContext,
-- and associating the DefaultConfiguration with it.
-- @param ctx LoggerContext object
function Configuration:SetContext(ctx)
    PRIVATE[self].context[ctx.name] = ctx
end

function Configuration:AddAppender(appender)
    PRIVATE[self].appender[appender.name] = appender
end

function Configuration:AddLogger(name, loggerconfig)
    PRIVATE[self].loggerconfig[name] = loggerconfig
end

function Configuration:GetLoggerConfigs()
    return PRIVATE[self].loggerconfig
end

function Configuration:GetAppenders()
    return PRIVATE[self].appender
end

--- Register a Configuration.
-- @param name The name of the Configuration
-- @return object configuration
function Log4g.Core.Config.Configuration.Register(name)
    return Configuration(name)
end