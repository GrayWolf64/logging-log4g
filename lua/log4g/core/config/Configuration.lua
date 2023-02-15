--- Interface that must be implemented to create a Configuration.
-- @classmod Configuration
local Class = include("log4g/core/impl/MiddleClass.lua")
local Configuration = Class("Configuration")

function Configuration:Initialize()
    self.appender = {}
end

function Configuration:AddAppender(appender)
    self.appender[appender.name] = appender
end

--- All the Configuration objects will be stored here in a ordered table.
-- @local
-- @table INSTANCES
local INSTANCES = INSTANCES or {}

--- Register a Configuration.
function Log4g.Core.Config.Configuration.Register()
    local configuration = Configuration:New()
    table.insert(INSTANCES, configuration)

    return configuration
end