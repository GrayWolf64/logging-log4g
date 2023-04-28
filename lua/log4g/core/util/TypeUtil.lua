--- A type(class) checking library to extend `MiddleClass`'s functionality.
-- @module TypeUtil
-- @license Apache License 2.0
-- @copyright GrayWolf64
local TypeUtil = {}
local pairs = pairs
local getClassNames = Log4g.GetPkgClsFuncs("log4g-core", "Object").getClassNames

local function mkfunc_classcheck(cls, subclss)
    return function(o)
        if not o then return false end
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

local function updateFuncs()
    for k, v in pairs(getClassNames()) do
        TypeUtil["Is" .. k] = mkfunc_classcheck(k, v)
    end
end

function TypeUtil.__index(t, k)
    if not t[k] then
        updateFuncs()
    end

    return t[k]
end

updateFuncs()

return TypeUtil