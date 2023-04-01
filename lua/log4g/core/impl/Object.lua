--- Class Object is the root of the class hierarchy.
-- @classmod Object
-- @license Apache License 2.0
-- @copyright GrayWolf64
local Object = include("log4g/core/impl/MiddleClass.lua")("Object")

function Object:IsObject()
    return true
end

return Object