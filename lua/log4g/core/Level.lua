--- The Level (Log Level).
-- Levels used for identifying the severity of an event.
-- Every standard Level has a [Color](https://wiki.facepunch.com/gmod/Color).
-- Subclassing 'Object'.
-- @classmod Level
Log4g.Core.Level = Log4g.Core.Level or {}
local Object = Log4g.Core.Object.getClass()
local checkClass = include("log4g/core/util/TypeUtil.lua").checkClass
local Level = Level or Object:subclass"Level"
local type = type

function Level:Initialize(name, int, color)
    Object.Initialize(self)
    self:SetPrivateField(0x00DD, int)
    self:SetPrivateField(0x00DE, color)
    self:SetName(name)
end

function Level:__tostring()
    return "Level: [name:" .. self:GetName() .. "]" .. "[int:" .. self:IntLevel() .. "]" .. "[color:" .. self:GetColor():__tostring() .. "]"
end

--- Get the Level's intlevel.
-- @return int intlevel
function Level:IntLevel()
    return self:GetPrivateField(0x00DD)
end

--- Get the Level's Color.
-- @return object color
function Level:GetColor()
    return self:GetPrivateField(0x00DE)
end

--- Compares the Level against the Levels passed as arguments and returns true if this level is in between the given levels.
-- @param l1 The Level with a certain intlevel
-- @param l2 The Level with another intlevel
-- @return bool isinrange
function Level:IsInRange(l1, l2)
    if not checkClass(l1, "Level") or not checkClass(l2, "Level") then return end
    if (self:IntLevel() >= l1:IntLevel() and self:IntLevel() <= l2:IntLevel()) or (self:IntLevel() <= l1:IntLevel() and self:IntLevel() >= l2:IntLevel()) then return true end

    return false
end

--- Custom Logging Levels created by users.
-- @local
-- @table customLevel
local customLevel = customLevel or {}

--- Get the Custom Levels as a table.
-- @return table customLevel
function Log4g.Core.Level.getCustomLevel()
    return customLevel
end

--- Standard Int Levels.
-- `ALL` has a intlevel of `math.huge`.
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
function Log4g.Core.Level.getStdLevel()
    return StdLevel
end

--- Get the Level.
-- Return the Level associated with the name or nil if the Level cannot be found.
-- @param name The Level's name
-- @return object level
function Log4g.Core.Level.getLevel(name)
    if StdLevel[name] then
        return StdLevel[name]
    elseif customLevel[name] then
        return customLevel[name]
    end
end

--- Retrieves an existing CustomLevel or creates one if it didn't previously exist.
-- If the CustomLevel matching the provided name already exists, it's intlevel will be overrode.
-- @param name The Level's name
-- @param int The Level's intlevel
-- @return object level
function Log4g.Core.Level.forName(name, int)
    if type(name) ~= "string" or type(int) ~= "number" or StdLevel[name] then return end
    if #name == 0 or int <= 0 then return end

    if not customLevel[name] then
        local level = Level(name, int)
        customLevel[name] = level

        return level
    else
        customLevel[name].int = int

        return customLevel[name]
    end
end