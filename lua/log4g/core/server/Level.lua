--- The Level (Log Level).
-- @classmod Level
local HasKey = Log4g.Util.HasKey
Log4g.Level.Standard = Log4g.Level.Standard or {}
Log4g.Level.Custom = Log4g.Level.Custom or {}
local Class = include("log4g/core/impl/MiddleClass.lua")
local Level = Class("Level")

function Level:Initialize(name, int)
    self.name = name or ""
    self.int = int or 0
end

Log4g.Level.Standard.ALL = Level:New("ALL", math.huge)
Log4g.Level.Standard.TRACE = Level:New("TRACE", 600)
Log4g.Level.Standard.DEBUG = Level:New("DEBUG", 500)
Log4g.Level.Standard.INFO = Level:New("INFO", 400)
Log4g.Level.Standard.WARN = Level:New("WARN", 300)
Log4g.Level.Standard.ERROR = Level:New("ERROR", 200)
Log4g.Level.Standard.FATAL = Level:New("FATAL", 100)
Log4g.Level.Standard.OFF = Level:New("OFF", 0)

function Level:__tostring()
    return "Level: [name:" .. self.name .. "]" .. "[int:" .. self.int .. "]"
end

--- Delete the Custom Level.
function Level:Delete()
    if HasKey(Log4g.Level.Custom, self.name) then
        Log4g.Level.Custom[self.name] = nil
    end
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
function Log4g.Level.GetLevel(name)
    if HasKey(Log4g.Level.Standard, name) then
        return Log4g.Level.Standard[name]
    elseif HasKey(Log4g.Level.Custom, name) then
        return Log4g.Level.Custom[name]
    else
        return nil
    end
end

--- Register a Custom Level.
-- If the Level already exists, it's intlevel will be overrode.
-- @param name The Level's name
-- @param int The Level's intlevel
-- @return object level
function Log4g.Level.RegisterCustomLevel(name, int)
    if name == "" or int < 0 or HasKey(Log4g.Level.Standard, name) then return end

    if not HasKey(Log4g.Level.Custom, name) then
        local level = Level:New(name, int)
        Log4g.Level.Custom[name] = level

        return level
    else
        Log4g.Level.Custom[name].int = int

        return Log4g.Level.Custom[name]
    end
end