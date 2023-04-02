--- Class Object is the root of the class hierarchy.
-- @classmod Object
-- @license Apache License 2.0
-- @copyright GrayWolf64
Log4g.Core.Object = Log4g.Core.Object or {}
local SHA256 = util.SHA256
local tostring, isstring = tostring, isstring
local Object = include("log4g/core/impl/MiddleClass.lua")("Object")

local PRIVATE = PRIVATE or setmetatable({}, {
    __mode = "k"
})

function Object:Initialize()
    PRIVATE[self] = {}
end

function Object:__tostring()
    return "Object: [name:" .. self:GetName() .. "]"
end

function Object:IsObject()
    return true
end

function Object:SetName(name)
    if not isstring(name) then return end
    PRIVATE[self].name = name
end

function Object:GetName()
    return PRIVATE[self].name
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

--- Returns a hash code value for the object.
function Object:HashCode()
    return SHA256(tostring(self))
end

function Log4g.Core.Object.GetClass()
    return Object
end