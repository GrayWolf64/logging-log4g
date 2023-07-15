--- The Level (Log Level).
-- Levels used for identifying the severity of an event.
-- Every standard Level has a [Color](https://wiki.facepunch.com/gmod/Color) by default.
-- Subclassing 'Object'.
-- @classmod Level
local Object        = Log4g.Core.Object.getClass()
local checkClass    = include"util/TypeUtil.lua".checkClass
local Level         = Level or Object:subclass"Level"
local getCLevelRepo = Log4g.Core.Repository.getCLevelRepo
local ErrorHandler  = include"log4g/core/ErrorHandler.lua"
Level:include(Log4g.Core.Object.namedMixins)

function Level:Initialize(name, int, color)
    Object.Initialize(self)
    self.__int = int
    self.__color = color
    self:SetName(name)
end

function Level:__tostring()
    return "Level: [name:" .. self:GetName() .. "]" .. "[int:" .. self:IntLevel() .. "]" .. "[color:" .. self:GetColor():__tostring() .. "]"
end

--- Get the Level's intlevel.
-- @return int intlevel
function Level:IntLevel()
    return self.__int
end

--- Get the Level's Color.
-- @return Color color
function Level:GetColor()
    return self.__color
end

function Level:SetColor(color)
    if not IsColor(color) then return end

    self.__color = color
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

--- Get the Custom Levels as a table.
-- @return table customLevel
local function getCustomLevel() return getCLevelRepo():Access() end

--- Standard Int Levels.
-- @table StdIntLevel
-- @field ALL `math.huge`
-- @field TRACE 600
-- @field DEBUG 500
-- @field INFO 400
-- @field WARN 300
-- @field ERROR 200
-- @field FATAL 100
-- @field OFF 0
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
-- @table StdLevelColor
-- @field ALL [color_white](https://wiki.facepunch.com/gmod/Global_Variables#constants)
-- @field TRACE 42 69 70
-- @field DEBUG 0 255 255
-- @field INFO 0 255 0
-- @field WARN 255 255 0
-- @field ERROR 255 0 0
-- @field FATAL 255 48 48
-- @field OFF [color_black](https://wiki.facepunch.com/gmod/Global_Variables#constants)
local StdLevelColor = {
    ALL = color_white,
    TRACE = Color(139, 145, 233),
    DEBUG = Color(0, 255, 255),
    INFO = Color(0, 255, 0),
    WARN = Color(255, 255, 0),
    ERROR = Color(255, 0, 0),
    FATAL = Color(255, 48, 48),
    OFF = color_black,
}

--- Standard Logging Levels as a table.
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

--- Retrieves an existing CustomLevel or creates one if it didn't previously exist.
-- If the CustomLevel matching the provided name already exists, it's intlevel will be overrode.
-- @param name The Level's name
-- @param int The Level's intlevel
-- @return object level
local function forName(name, int)
    ErrorHandler.Assert(type(name) == "string" and #name > 0, 1, "name for a Level must be a string", 1, nil, "name must have a length > 0")
    ErrorHandler.Assert(type(int) == "number" and int > 0, 2, "intLevel for a Level must be a number", 1, nil, "intlevels must be > 0")
    ErrorHandler.Assert(not StdLevel[name], nil, nil, 2, nil, "if a custom level with the same name already exists, its intlevel will be updated with the supplied int", {{line = 6, startPos = 5, endPos = 38, sign = "*", msg = "a stdLevel with the same name already exists"}})

    if not getCustomLevel()[name] then
        getCustomLevel()[name] = Level(name, int)
    else
        getCustomLevel()[name].__int = int
    end

    return getCustomLevel()[name]
end

Log4g.Core.Level = {
    getCustomLevel = getCustomLevel,
    getStdLevel = function() return StdLevel end,
    getLevel = function(name) return StdLevel[name] or getCLevelRepo():Access()[name] end,
    forName = forName
}