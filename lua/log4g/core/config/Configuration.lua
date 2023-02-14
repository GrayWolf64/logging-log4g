--- Interface that must be implemented to create a Configuration.
-- @classmod Configuration
local Class = include("log4g/core/impl/MiddleClass.lua")
local Configuration = Class("Configuration")

function Configuration:Initialize()
end

--- Register a Configuration for the LoggerContext.
function Log4g.Core.Config.Register(context)
    context.configuration = Configuration:New()
end