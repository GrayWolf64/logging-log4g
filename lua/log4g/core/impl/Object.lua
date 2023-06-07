--- Class Object is the root of the class hierarchy.
-- @classmod Object
-- @license Apache License 2.0
-- @copyright GrayWolf64
local ipairs = ipairs
local StripDotExtension = include("log4g/core/util/StringUtil.lua").StripDotExtension
local Object = include("log4g/core/impl/MiddleClass.lua")("Object")

--- A table for storing private properties of an object.
-- @local
-- @table Private
local Private = Private or setmetatable({}, {
    __mode = "k"
})

function Object:Initialize()
    Private[self] = {}
end

function Object:__tostring()
    return "Object: [name:" .. self:GetName() .. "]"
end

function Object:SetName(name)
    if type(name) ~= "string" then return end
    Private[self].name = name
end

function Object:GetName()
    return Private[self].name
end

function Object:SetPrivateField(key, value)
    if not key or not value then return end
    Private[self][key] = value
end

function Object:GetPrivateField(key)
    if not key then return end

    return Private[self][key]
end

function Object:DestroyPrivateTable()
    Private[self] = nil
end

local function GetClass()
    return Object
end

--- Generate all the ancestors' names of a LoggerConfig or something else.
-- The provided name must follow [Named Hierarchy](https://logging.apache.org/log4j/2.x/manual/architecture.html).
-- @lfunction EnumerateAncestors
-- @param name Object's name
-- @return table ancestors' names in a list-styled table
-- @return table parent name but with dots removed in a table
local function EnumerateAncestors(name)
    local nodes, ancestors, s = StripDotExtension(name, false), {}, ""

    for k, v in ipairs(nodes) do
        if k ~= 1 then
            s = s .. "." .. v
        else
            s = s .. v
        end

        ancestors[s] = true
    end

    return ancestors, nodes
end

Log4g.Core.Object = {
    getClass = GetClass,
    enumerateAncestors = EnumerateAncestors,
    contextualMixins = {
        SetContext = function(self, ctx)
            if type(ctx) ~= "string" then return end
            self:SetPrivateField(0x0010, ctx)
        end,
        GetContext = function(self) return self:GetPrivateField(0x0010) end
    }
}