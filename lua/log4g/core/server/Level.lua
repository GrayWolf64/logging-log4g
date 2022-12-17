Log4g.Levels = {}
local Level = include("log4g/core/server/impl/Class.lua"):Extend()
local HasKey = Log4g.Util.HasKey

function Level:New(name, int, standard)
    self.name = name or ""
    self.int = int or 0
    self.standard = standard or false
end

Log4g.Levels.ALL = Level("ALL", math.huge, true)
Log4g.Levels.TRACE = Level("TRACE", 600, true)
Log4g.Levels.DEBUG = Level("DEBUG", 500, true)
Log4g.Levels.INFO = Level("INFO", 400, true)
Log4g.Levels.WARN = Level("WARN", 300, true)
Log4g.Levels.ERROR = Level("ERROR", 200, true)
Log4g.Levels.FATAL = Level("FATAL", 100, true)
Log4g.Levels.OFF = Level("OFF", 0, true)

function Level:Delete()
    for k, _ in pairs(self) do
        self.k = nil
    end
end

function Level:Name()
    return self.name
end

function Level:IntLevel()
    return self.int
end

function Level:Standard()
    return self.standard
end

function Level:HashCode()
    return util.SHA256(tostring(self))
end

function Log4g.RegisterCustomLevel(name, int)
    if int < 0 then return end

    if not HasKey(Log4g.Levels, name) then
        local level = Level(name, int, false)
        Log4g.Levels[name] = level

        return level
    else
        Log4g.Levels[name].int = int
        Log4g.Levels[name].standard = false

        return Log4g.Levels[name]
    end
end