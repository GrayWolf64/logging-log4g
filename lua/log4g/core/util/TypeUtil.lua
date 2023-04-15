local TypeUtil = {}
local pairs = pairs

local classes = {
    ["Object"] = {"LifeCycle", "RootLoggerConfig", "LoggerConfig", "LogEvent", "LoggerContext", "Configuration", "Level", "Layout", "Logger", "Appender", "DefaultConfiguration"},
    ["Configuration"] = {"DefaultConfiguration"},
    ["LoggerConfig"] = {"RootLoggerConfig"},
    ["Appender"] = {"ConsoleAppender"},
    ["Layout"] = {"PatternLayout"},
    ["LoggerContext"] = {},
    ["Level"] = {},
    ["Logger"] = {},
    ["LogEvent"] = {},
    ["RootLoggerConfig"] = {}
}

local function mkfunc_classcheck(cls, subclss)
    return function(o)
        if not o then return false end
        local class = o.class
        if not class then return false end
        local clsname = class.name

        if subclss then
            for _, v in pairs(subclss) do
                if v == clsname then return true end
            end
        end

        if clsname == cls then return true end

        return false
    end
end

for k, v in pairs(classes) do
    TypeUtil["Is" .. k] = mkfunc_classcheck(k, v)
end

return TypeUtil