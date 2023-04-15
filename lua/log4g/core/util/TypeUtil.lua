local TypeUtil = {}
local type, assert = type, assert
local tostring = tostring

local classes = {"Object", "LoggerContext", "Configuration", "Level", "Appender", "Layout", "Logger", "LogEvent", "LoggerConfig", "RootLoggerConfig"}

local function mkfunc_classcheck(cls)
    return function(o)
        local class = o.class
        assert(class, "MiddleClass object expected, got " .. type(o) .. ".")
        local clsname = class.name
        assert(clsname == cls, "'" .. cls .. "' object expected, got " .. tostring(clsname) .. ".")
    end
end

for k in pairs(classes) do
    TypeUtil["Is" .. k] = mkfunc_classcheck(k)
end

return TypeUtil