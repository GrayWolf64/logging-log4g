--- Class Object is the root of the class hierarchy.
-- @classmod Object
-- @license Apache License 2.0
-- @copyright GrayWolf64
Log4g.Core.Object = Log4g.Core.Object or {}
local SHA256 = util.SHA256
local tostring, isstring = tostring, isstring
local ipairs = ipairs
local table_insert, table_concat = table.insert, table.concat
local StripDotExtension = include("log4g/core/util/StringUtil.lua").StripDotExtension
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

--- Generate all the ancestors' names of a LoggerConfig or something else.
-- The provided name must follow [Named Hierarchy](https://logging.apache.org/log4j/2.x/manual/architecture.html).
-- @lfunction EnumerateAncestors
-- @param name Object's name
-- @return table ancestors' names in a list-styled table
-- @return table parent name but with dots removed in a table
function Log4g.Core.Object.EnumerateAncestors(name)
    local nodes, ancestors = StripDotExtension(name, false), {}

    for k in ipairs(nodes) do
        local ancestor = {}

        for i = 1, k do
            table_insert(ancestor, nodes[i])
        end

        ancestors[table_concat(ancestor, ".")] = true
    end

    return ancestors, nodes
end