--- The Level (Log Level).
-- @classmod Level
local HasKey = Log4g.Util.HasKey
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

--- Custom Logging Levels created by users.
-- @local
-- @table CustomLevel
local CustomLevel = CustomLevel or {}

--- Get the Custom Levels as a table.
-- @return table customlevel
function Log4g.Level.GetCustomLevel()
    return CustomLevel
end

--- Standard Logging Levels as a table for use internally.
-- @local
-- @table StandardLevel
-- @field ALL All events should be logged.
-- @field TRACE A fine-grained debug message, typically capturing the flow through the game.
-- @field DEBUG A general debugging event.
-- @field INFO An event for informational purposes.
-- @field WARN An event that might possible lead to an error.
-- @field ERROR An error in game, possibly recoverable.
-- @field FATAL A severe error that will prevent the game from continuing.
-- @field OFF No events will be logged.
local StandardLevel = {
    ALL = Level:New("ALL", math.huge),
    TRACE = Level:New("TRACE", 600),
    DEBUG = Level:New("DEBUG", 500),
    INFO = Level:New("INFO", 400),
    WARN = Level:New("WARN", 300),
    ERROR = Level:New("ERROR", 200),
    FATAL = Level:New("FATAL", 100),
    OFF = Level:New("OFF", 0),
}

--- Get the Standard Levels as a table.
-- @return table standardlevel
function Log4g.Level.GetStandardLevel()
    return StandardLevel
end

--- Get the Level.
-- Return the Level associated with the name or nil if the Level cannot be found.
-- @param name The Level's name
-- @return object level
function Log4g.Level.GetLevel(name)
    if HasKey(StandardLevel, name) then
        return StandardLevel[name]
    elseif HasKey(CustomLevel, name) then
        return CustomLevel[name]
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
    if #name == 0 or int < 0 or HasKey(StandardLevel, name) then return end

    if not HasKey(CustomLevel, name) then
        local level = Level:New(name, int)
        CustomLevel[name] = level

        return level
    else
        CustomLevel[name].int = int

        return CustomLevel[name]
    end
end