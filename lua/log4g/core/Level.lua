--- The Level (Log Level).
-- Levels used for identifying the severity of an event.
-- Every standard Level has a [Color](https://wiki.facepunch.com/gmod/Color).
-- Subclassing 'Object'.
-- @classmod Level
local _M = {}
local Object = Log4g.Core.Object.GetClass()
local Level = Object:subclass("Level")
local IsLevel = include"log4g/core/util/TypeUtil.lua".IsLevel
local isstring, isnumber = isstring, isnumber
local GetAllCustomLevel = Log4g.Core.GetAllCustomLevel

function Level:Initialize(name, int, color)
    Object.Initialize(self)
    self:SetPrivateField("int", int)
    self:SetPrivateField("color", color)
    self:SetName(name)
end

function Level:__tostring()
    return "Level: [name:" .. self:GetName() .. "]" .. "[int:" .. self:IntLevel() .. "]" .. "[color:" .. self:GetColor():__tostring() .. "]"
end

function Level:__eq(lhs, rhs)
    if not IsLevel(lhs) or not IsLevel(rhs) then return false end

    return lhs:IntLevel() == rhs:IntLevel() and lhs:GetColor() == rhs:GetColor()
end

--- Get the Level's intlevel.
-- @return int intlevel
function Level:IntLevel()
    return self:GetPrivateField("int")
end

--- Get the Level's Color.
-- @return object color
function Level:GetColor()
    return self:GetPrivateField("color")
end

--- Compares the Level against the Levels passed as arguments and returns true if this level is in between the given levels.
-- @param minlevel The Level with minimal intlevel
-- @param maxlevel The Level with maximal intlevel
-- @return bool isinrange
function Level:IsInRange(minlevel, maxlevel)
    if not IsLevel(minlevel) or not IsLevel(maxlevel) then return end
    if self:IntLevel() >= minlevel:IntLevel() and self:IntLevel() <= maxlevel:IntLevel() then return true end

    return false
end

--- Get the Custom Levels as a table.
-- @return table customlevel
function _M.GetCustomLevel()
    return GetAllCustomLevel()
end

--- Standard Int Levels.
-- @local
-- @table StdIntLevel
local StdIntLevel = {
    ALL = math.huge,
    TRACE = 600,
    DEBUG = 500,
    INFO = 400,
    WARN = 300,
    ERROR = 200,
    FATAL = 100,
    OFF = 0,
}

--- Standard Level Colors.
-- @local
-- @table StdLevelColor
local StdLevelColor = {
    ALL = color_white,
    TRACE = Color(54, 54, 54),
    DEBUG = Color(0, 255, 255),
    INFO = Color(0, 255, 0),
    WARN = Color(255, 255, 0),
    ERROR = Color(255, 0, 0),
    FATAL = Color(255, 48, 48),
    OFF = color_white,
}

--- Standard Logging Levels as a table.
-- @local
-- @table StdLevel
-- @field ALL All events should be logged.
-- @field TRACE A fine-grained debug message, typically capturing the flow through the game.
-- @field DEBUG A general debugging event.
-- @field INFO An event for informational purposes.
-- @field WARN An event that might possible lead to an error.
-- @field ERROR An error in game, possibly recoverable.
-- @field FATAL A severe error that will prevent the game from continuing.
-- @field OFF No events will be logged.
local StdLevel = {}

for k, v in pairs(StdIntLevel) do
    StdLevel[k] = Level(k, v, StdLevelColor[k])
end

--- Get the Standard Levels as a table.
-- @return table StdLevel
function _M.GetStdLevel()
    return StdLevel
end

--- Get the Level.
-- Return the Level associated with the name or nil if the Level cannot be found.
-- @param name The Level's name
-- @return object level
function _M.GetLevel(name)
    local customLevels = GetAllCustomLevel()

    if StdLevel[name] then
        return StdLevel[name]
    elseif customLevels[name] then
        return customLevels[name]
    end
end

--- Retrieves an existing CustomLevel or creates one if it didn't previously exist.
-- If the CustomLevel matching the provided name already exists, it's intlevel will be overrode.
-- @param name The Level's name
-- @param int The Level's intlevel
-- @return object level
function _M.ForName(name, int)
    if not isstring(name) or not isnumber(int) or StdLevel[name] then return end
    if #name == 0 or int <= 0 then return end
    local customLevels = GetAllCustomLevel()

    if not customLevels[name] then
        local level = Level(name, int)
        customLevels[name] = level

        return level
    else
        customLevels[name].int = int

        return customLevels[name]
    end
end

return _M