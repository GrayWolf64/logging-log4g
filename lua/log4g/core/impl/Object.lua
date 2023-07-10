--- Class Object is the root of the class hierarchy.
-- @classmod Object
-- @license Apache License 2.0
-- @copyright GrayWolf64
local StripDotExtension = include"../util/StringUtil.lua".StripDotExtension
local Object = include"MiddleClass.lua""Object"

--- A table for storing private properties of an object.
-- @local
-- @table _tPrivate
local _tPrivate = _tPrivate or setmetatable({}, {
    __mode = "k"
})

function Object:Initialize()
    _tPrivate[self] = {}
end

function Object:__tostring()
    return "Object: [name:" .. self:GetName() .. "]"
end

function Object:SetName(name)
    if type(name) ~= "string" then return end
    _tPrivate[self].name = name
end

function Object:GetName()
    return _tPrivate[self].name
end

function Object:SetPrivateField(key, value)
    if not key or not value then return end
    _tPrivate[self][key] = value
end

function Object:GetPrivateField(key)
    if not key then return end

    return _tPrivate[self][key]
end

function Object:DestroyPrivateTable()
    _tPrivate[self] = nil
end

--- Generate all the ancestors' names of a LoggerConfig or something else.
-- The provided name must follow [Named Hierarchy](https://logging.apache.org/log4j/2.x/manual/architecture.html).
-- @lfunction EnumerateAncestors
-- @param name Object's name
-- @return table ancestors' names in a list-styled table
-- @return table parent name but with dots removed in a table
local function EnumerateAncestors(name)
    local nodes, ancestors, ancestNames = StripDotExtension(name, false), {}, {}
    local tableInsert, tableConcat = table.insert, table.concat

    for k, v in ipairs(nodes) do
        tableInsert(ancestNames, v)
        ancestors[tableConcat(ancestNames, ".")] = true
    end

    return ancestors, nodes
end

Log4g.Core.Object = {
    getClass = function() return Object end,
    enumerateAncestors = EnumerateAncestors,
    contextualMixins = {
        SetContext = function(self, ctx)
            if type(ctx) ~= "string" then return end
            self:SetPrivateField(0x0010, ctx)
        end,
        GetContext = function(self) return self:GetPrivateField(0x0010) end
    }
}