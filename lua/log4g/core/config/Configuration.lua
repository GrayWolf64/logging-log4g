--- Interface that must be implemented to create a Configuration.
-- @classmod Configuration
local Class = include("log4g/core/impl/MiddleClass.lua")
local Configuration = Class("Configuration")
local HasKey = Log4g.Util.HasKey
--- All the Configuration objects will be stored here in a ordered table.
-- @local
-- @table INSTANCES
local INSTANCES = INSTANCES or {}

--- A weak table which stores some private attributes of the Configuration object.
-- @local
-- @table PRIVATE
local PRIVATE = PRIVATE or setmetatable({}, {
    __mode = "k"
})

function Configuration:Initialize(name)
    self.name = name

    PRIVATE[self] = {
        appender = {}
    }
end

function Configuration:AddAppender(appender)
    PRIVATE[self].appender[appender.name] = appender
end

--- Register a Configuration.
function Log4g.Core.Config.Configuration.Register(name)
    if HasKey(INSTANCES, name) then return INSTANCES[name] end
    INSTANCES[name] = Configuration:New(name)

    return INSTANCES[name]
end