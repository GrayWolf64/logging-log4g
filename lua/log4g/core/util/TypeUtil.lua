--- A type(class) checking library to extend `MiddleClass`'s functionality.
-- @module TypeUtil
-- @license Apache License 2.0
-- @copyright GrayWolf64
local TypeUtil = {}
local pairs = pairs
local istable = istable
local print = print

--- All the `Class` names in Log4g.
-- @local
-- @table Classes
local Classes = {
    ["Object"] = {
        ["LifeCycle"] = true,
        ["LoggerConfig.RootLogger"] = true,
        ["LoggerConfig"] = true,
        ["LogEvent"] = true,
        ["LoggerContext"] = true,
        ["Configuration"] = true,
        ["Level"] = true,
        ["Layout"] = true,
        ["Logger"] = true,
        ["Appender"] = true,
        ["DefaultConfiguration"] = true,
        ["PatternLayout"] = true,
        ["ConsoleAppender"] = true
    },
    ["Configuration"] = {
        ["DefaultConfiguration"] = true
    },
    ["LoggerConfig"] = {
        ["LoggerConfig.RootLogger"] = true
    },
    ["Appender"] = {
        ["ConsoleAppender"] = true
    },
    ["Layout"] = {
        ["PatternLayout"] = true
    },
    ["LoggerContext"] = {},
    ["Level"] = {},
    ["Logger"] = {},
    ["LogEvent"] = {},
    ["LoggerConfig.RootLogger"] = {}
}

function print(...)
    print("Log4g-userinput:", ...)
end

local function mkfunc_classcheck(cls, subclss)
    return function(o)
        if not o or not istable(o) then
            print("expecting table, got", type(o), ".")

            return false
        end

        local class = o.class

        if not class then
            print("expecting MiddleClass object, got a normal table.")

            return false
        end

        local clsname = class.name

        if subclss then
            for k in pairs(subclss) do
                if k == clsname then return true end
            end
        end

        if clsname == cls then return true end
        print(clsname, "is not the expected class or is not its subclass.")

        return false
    end
end

for k, v in pairs(Classes) do
    TypeUtil["Is" .. k] = mkfunc_classcheck(k, v)
end

return TypeUtil