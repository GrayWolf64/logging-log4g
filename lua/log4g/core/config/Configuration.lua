--- Interface that must be implemented to create a Configuration.
-- @classmod Configuration
local Class = include("log4g/core/impl/MiddleClass.lua")
local Configuration = Class("Configuration")

function Configuration:Initialize(name)
    self.name = name
end