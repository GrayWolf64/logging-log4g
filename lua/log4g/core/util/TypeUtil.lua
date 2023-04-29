--- A type(class) checking library to extend `MiddleClass`'s functionality.
-- @module TypeUtil
-- @license Apache License 2.0
-- @copyright GrayWolf64
local TypeUtil = {}
local pairs = pairs
local type = type

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

local function mkfunc_classcheck(cls, subclss)
    return function(o)
        if not o or type(o) ~= "table" then return false end
        local class = o.class
        if not class then return false end
        local clsname = class.name

        if subclss then
            for k in pairs(subclss) do
                if k == clsname then return true end
            end
        end

        if clsname == cls then return true end

        return false
    end
end

print("Log4g-typeutil mkfunc_classcheck finished in ", Log4g.timeit(function()
    for k, v in pairs(Classes) do
        TypeUtil["Is" .. k] = mkfunc_classcheck(k, v)
    end
end), "seconds")

Log4g.RegisterPackageClass("log4g-core", "TypeUtil", TypeUtil)