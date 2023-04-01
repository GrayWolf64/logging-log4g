--- Class Object is the root of the class hierarchy.
-- @classmod Object
-- @license Apache License 2.0
-- @copyright GrayWolf64
Log4g.Core.Object = Log4g.Core.Object or {}
local Object = include("log4g/core/impl/MiddleClass.lua")("Object")

local PRIVATE = PRIVATE or setmetatable({}, {
    __mode = "k"
})

function Object:Initialize()
    PRIVATE[self] = {}
end

function Object:IsObject()
    return true
end

function Object:SetPrivateField(key, value)
    if not key or not value then return end
    PRIVATE[self][key] = value
end

function Object:GetPrivateField(key)
    if not key then return end

    return PRIVATE[self][key]
end

function Object:DestroyPrivateTable()
    PRIVATE[self] = nil
end

function Log4g.Core.Object.GetClass()
    return Object
end