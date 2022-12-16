Log4g.Levels = {}
local Level = include("log4g/core/server/impl/Class.lua"):Extend()

function Level:New(name, int)
    self.name = name or ""
    self.int = int or 0
end

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

function Level:HashCode()
    return util.SHA256(tostring(self))
end

function Log4g.RegisterLevel(name, int)
    local level = Level(name, int)
    table.insert(Log4g.Levels, level)

    return level
end

Log4g.Levels.ALL = Level("ALL", math.huge)
Log4g.Levels.TRACE = Level("TRACE", 600)
Log4g.Levels.DEBUG = Level("DEBUG", 500)
Log4g.Levels.INFO = Level("INFO", 400)
Log4g.Levels.WARN = Level("WARN", 300)
Log4g.Levels.ERROR = Level("ERROR", 200)
Log4g.Levels.FATAL = Level("FATAL", 100)
Log4g.Levels.OFF = Level("OFF", 0)