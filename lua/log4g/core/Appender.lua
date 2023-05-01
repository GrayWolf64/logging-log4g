--- Appends LogEvents.
-- @classmod Appender
local LifeCycle = Log4g.GetPkgClsFuncs("log4g-core", "LifeCycle").getClass()
local Object = Log4g.GetPkgClsFuncs("log4g-core", "Object").getClass()
--- Lays out a LogEvent in different formats.
-- @type Layout
local Layout = Object:subclass"Layout"

--- Initialize the Layout.
-- @param name String name
function Layout:Initialize(name)
    Object.Initialize(self)
    self:SetName(name)
end

function Layout:__tostring()
    return "Layout: [name:" .. self:GetName() .. "]"
end

--- Gets Layout class.
local function GetLayoutClass()
    return Layout
end

--- An Appender can contain a Layout if applicable.
-- @type Appender
local Appender = LifeCycle:subclass"Appender"

function Appender:Initialize(name, layout)
    LifeCycle.Initialize(self)
    self:SetPrivateField("layout", layout)
    self:SetName(name)
end

function Appender:__tostring()
    return "Appender: [name:" .. self:GetName() .. "]"
end

--- Returns the Layout used by this Appender if applicable.
-- @return object Layout
function Appender:GetLayout()
    return self:GetPrivateField"layout"
end

function Appender:Append()
    return true
end

--- Gets Appender class.
local function GetAppenderClass()
    return Appender
end

--- The goal of this class is to format a LogEvent and return the results. The format of the result depends on the conversion pattern.
-- @type PatternLayout
local PatternLayout = Layout:subclass"PatternLayout"
local TypeUtil = Log4g.GetPkgClsFuncs("log4g-core", "TypeUtil")
local IsLogEvent = TypeUtil.IsLogEvent
local PropertiesPlugin = Log4g.GetPkgClsFuncs("log4g-core", "PropertiesPlugin")
local pairs, ipairs = pairs, ipairs
local unpack = unpack
local defaultColor = Color(0, 201, 255)
local tableInsert, tableRemove = table.insert, table.remove
local propertyConversionPattern = "patternlayoutConversionPattern"
local propertyMessageColor = "patternlayoutMessageColor"
local propertyUptimeColor = "patternlayoutUptimeColor"
local propertyFileColor = "patternlayoutFileColor"
PropertiesPlugin.registerProperty(propertyConversionPattern, "[%uptime] [%level] @ %file: %msg%endl", true)
PropertiesPlugin.registerProperty(propertyMessageColor, "135 206 250 255", true)
PropertiesPlugin.registerProperty(propertyUptimeColor, "135 206 250 255", true)
PropertiesPlugin.registerProperty(propertyFileColor, "60 179 113 255", true)

function PatternLayout:Initialize(name)
    Layout.Initialize(self, name)
end

--- Format the LogEvent using patterns.
-- @param event LogEvent
-- @param colored If use `Color`s.
-- @return vararg formatted event in sub strings
local function DoFormat(event, colored)
    local conversionPattern = PropertiesPlugin.getProperty(propertyConversionPattern, true)

    --- Get all the positions of a char in a string.
    -- @param str String to search in
    -- @param char A Single character to search for
    -- @return table positions or true if not found
    local function charPos(str, char)
        if type(str) ~= "string" or type(char) ~= "string" or not #char == 1 then return end
        local pos = {}
        char = char:byte()

        for k, v in ipairs({str:byte(1, #str)}) do
            if v == char then
                tableInsert(pos, k)
            end
        end

        return not #pos or pos
    end

    local pos = charPos(conversionPattern, "%")
    if pos == true then return conversionPattern end
    local subStrings = {}
    local pointerPos = 1

    for k, v in ipairs(pos) do
        local previousPos, nextPos = pos[k - 1], pos[k + 1]

        if previousPos then
            pointerPos = previousPos
        end

        if v - 1 ~= 0 then
            subStrings[k] = conversionPattern:sub(pointerPos, v - 1)
        end

        if not nextPos then
            subStrings[k + 1] = conversionPattern:sub(v, #conversionPattern)
        end
    end

    local function getPropertyColor(cvar)
        if not colored then return end

        return PropertiesPlugin.getProperty(cvar, true):ToColor()
    end

    local eventLevel = event:GetLevel()

    local tokenMap = {
        ["%msg"] = {
            color = getPropertyColor(propertyMessageColor),
            content = event:GetMsg()
        },
        ["%endl"] = {
            content = "\n"
        },
        ["%uptime"] = {
            color = getPropertyColor(propertyUptimeColor),
            content = event:GetTime()
        },
        ["%file"] = {
            color = getPropertyColor(propertyFileColor),
            content = event:GetSource():GetFileFromFilename()
        },
        ["%level"] = {
            color = eventLevel:GetColor(),
            content = eventLevel:GetName()
        }
    }

    for tokenName in pairs(tokenMap) do
        for index, subString in ipairs(subStrings) do
            if subString:find(tokenName, 1, true) then
                local previousValue = subStrings[index]
                tableRemove(subStrings, index)
                tableInsert(subStrings, index, tokenName)
                tableInsert(subStrings, index + 1, previousValue:sub(#tokenName + 1, #previousValue))
            end
        end
    end

    --- Make a function that can replace a table's matching values with replacement content(string),
    -- and insert a Color before each replaced value. Based on `colored` bool, it will decide if `Color`s will be inserted.
    -- @lfunction mkfunc_precolor
    -- @param tokenName String to search for and to be replaced
    -- @param color Color object to insert before each replaced value
    -- @return function output func
    local function mkfunc_precolor(tokenName, color)
        return function(subStringTable, content)
            for index, subString in ipairs(subStringTable) do
                if subString == tokenName then
                    subStringTable[index] = content

                    if colored then
                        if color then
                            tableInsert(subStringTable, index, color)
                        else
                            tableInsert(subStringTable, index, defaultColor)
                        end

                        tableInsert(subStringTable, index + 2, defaultColor)
                    end
                end
            end
        end
    end

    for tokenName, mappedReplacements in pairs(tokenMap) do
        mkfunc_precolor(tokenName, mappedReplacements.color)(subStrings, mappedReplacements.content)
    end

    return unpack(subStrings)
end

--- Format a LogEvent.
-- @param event LogEvent
-- @param colored If use `Color`s.
-- @return vararg result
function PatternLayout:Format(event, colored)
    if not IsLogEvent(event) then return end

    return DoFormat(event, colored)
end

--- Create a default PatternLayout.
local function CreateDefaultPatternLayout(name)
    return PatternLayout(name)
end

--- Appends log events to console using a layout specified by the user.
-- @type ConsoleAppender
local ConsoleAppender = Appender:subclass"ConsoleAppender"
local IsLayout = TypeUtil.IsLayout
local print = print

function ConsoleAppender:Initialize(name, layout)
    Appender.Initialize(self, name, layout)
end

--- Append a LogEvent to Console.
-- @param event LogEvent
function ConsoleAppender:Append(event)
    if not IsLogEvent(event) then return end
    local layout = self:GetLayout()
    if not IsLayout(layout) then return end

    if gmod then
        MsgC(layout:Format(event, true))
    else
        print(layout:Format(event, false))
    end
end

--- Create a default ConsoleAppender.
local function CreateConsoleAppender(name, layout)
    return ConsoleAppender(name, layout)
end

Log4g.RegisterPackageClass("log4g-core", "Appender", {
    getLayoutClass = GetLayoutClass,
    getAppenderClass = GetAppenderClass,
    createConsoleAppender = CreateConsoleAppender,
    createDefaultPatternLayout = CreateDefaultPatternLayout
})