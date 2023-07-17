--- Class Object is the root of the class hierarchy.
-- @classmod Object
-- @license Apache License 2.0
-- @copyright GrayWolf64
local StripDotExtension = include"../util/StringUtil.lua".StripDotExtension
local Object = include"MiddleClass.lua""Object"

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
            assert(type(ctx) == "string", "setContext can only accept a string name of a lContext")
            self.__lContextName = ctx
        end,
        GetContext = function(self) return self.__lContextName end
    },
    namedMixins = {
        SetName = function(self, name)
            assert(type(name) == "string" and #name > 0, "name for an Object must be a string with a len > 0")
            self.__name = name
        end,
        GetName = function(self)
            return self.__name
        end
    }
}