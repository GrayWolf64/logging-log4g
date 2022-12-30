--- The Level (Log Level).
-- @classmod Level
Log4g.Levels = {}
local Level = include("log4g/core/impl/Class.lua"):Extend()
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

--- Delete the Level.
function Level:Delete()
    Log4g.Levels[self.name] = nil
end

--- Get the Level's name.
-- @return string name
function Level:Name()
    return self.name
end

--- Get the Level's intlevel.
-- @return int intlevel
function Level:IntLevel()
    return self.int
end

--- Check if the Level is a Standard Level.
-- @return bool standard
function Level:Standard()
    return self.standard
end

--- Calculate the Level's SHA256 Hash Code.
-- Convert the Level object to string then use util.SHA256().
-- @return string hashcode
function Level:HashCode()
    return util.SHA256(tostring(self))
end

--- Compares the Level against the Levels passed as arguments and returns true if this level is in between the given levels.
-- @param minlevel The Level with minimal intlevel
-- @param maxlevel The Level with maximal intlevel
-- @return bool isinrange
function Level:IsInRange(minlevel, maxlevel)
    if self.int >= minlevel.int and self.int <= maxlevel.int then
        return true
    else
        return false
    end
end

--- Get the Level.
-- Return the Level associated with the name or nil if the Level cannot be found.
-- @param name The Level's name
-- @return object level
function Log4g.GetLevel(name)
    for k, v in pairs(Log4g.Levels) do
        if k == name then return v end
    end

    return nil
end

--- Register a Custom Level.
-- If the Level already exists, it's intlevel will be overrode, and standard will be set to false.
-- @param name The Level's name
-- @param int The Level's intlevel
-- @return object level
function Log4g.Registrar.RegisterCustomLevel(name, int)
    if name == "" or int < 0 then return end

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