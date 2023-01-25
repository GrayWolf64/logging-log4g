--- The Level (Log Level).
-- @classmod Level
local HasKey = Log4g.Util.HasKey
Log4g.Level.Custom = Log4g.Level.Custom or {}
local Class = include("log4g/core/impl/MiddleClass.lua")
local Level = Class("Level")

function Level:Initialize(name, int)
    self.name = name
    self.int = int
end

function Level:__tostring()
    return "Level: [name:" .. self.name .. "]" .. "[int:" .. self.int .. "]"
end

function Level:__eq(lhs, rhs)
    return lhs == rhs
end

--- Delete the Custom Level.
function Level:Delete()
    local custom = Log4g.Level.Custom

    if HasKey(custom, self.name) then
        custom[self.name] = nil
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
    local standard = Log4g.Level.Standard
    local custom = Log4g.Level.Custom

    if HasKey(standard, name) then
        return standard[name]
    elseif HasKey(custom, name) then
        return custom[name]
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
    local standard = Log4g.Level.Standard
    local custom = Log4g.Level.Custom
    if name == "" or int < 0 or HasKey(standard, name) then return end

    if not HasKey(custom, name) then
        local level = Level:New(name, int)
        custom[name] = level

        return level
    else
        custom[name].int = int

        return custom[name]
    end
end

--- Get the Standard Levels as a table.
function Log4g.Level.GetStandardLevel()
    return Log4g.Level.Standard
end

--- Standard Logging Levels as a table for use internally.
-- @table Log4g.Level.Standard
-- @field ALL All events should be logged.
-- @field TRACE A fine-grained debug message, typically capturing the flow through the game.
-- @field DEBUG A general debugging event.
-- @field INFO An event for informational purposes.
-- @field WARN An event that might possible lead to an error.
-- @field ERROR An error in game, possibly recoverable.
-- @field FATAL A severe error that will prevent the game from continuing.
-- @field OFF No events will be logged.
Log4g.Level.Standard = {
    ALL = Level:New("ALL", math.huge),
    TRACE = Level:New("TRACE", 600),
    DEBUG = Level:New("DEBUG", 500),
    INFO = Level:New("INFO", 400),
    WARN = Level:New("WARN", 300),
    ERROR = Level:New("ERROR", 200),
    FATAL = Level:New("FATAL", 100),
    OFF = Level:New("OFF", 0)
}