--- Interface that must be implemented to create a Configuration.
-- @classmod Configuration
Log4g.Core.Config.Configuration = Log4g.Core.Config.Configuration or {}
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
        lc = {}
    }
end

--- Sets the LoggerContext name for the Configuration.
-- This is meant to be used internally when creating a LoggerContext,
-- and associating the DefaultConfiguration with it, then the Configuration will have a string field of the LoggerContext's name.
-- @param name ctxname
function Configuration:SetContext(name)
    PRIVATE[self].context = name
end

function Configuration:AddAppender(appender)
    PRIVATE[self].appender[appender.name] = appender
end

function Configuration:AddLogger(name, lc)
    PRIVATE[self].lc[name] = lc
end

--- Locates the appropriate LoggerConfig for a Logger name.
function Configuration:GetLoggerConfig(name)
    if PRIVATE[self].lc[name] then return PRIVATE[self].lc[name] end
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