--- A flexible layout configurable with pattern string.
-- @classmod PatternLayout
-- @license Apache License 2.0
-- @copyright GrayWolf64
local Layout = Log4g.Core.Layout.getClass()
local PatternLayout = PatternLayout or Layout:subclass"PatternLayout"
local checkClass = include"../util/TypeUtil.lua".checkClass
local charPos = include"../util/StringUtil.lua".CharPos
local pairs, ipairs = pairs, ipairs
local unpack = unpack
local defaultColor = Color(0, 201, 255)
local tableInsert, tableRemove = table.insert, table.remove
local cvarConversionPattern = "log4g_patternlayout_ConversionPattern"
local cvarMessageColor = "log4g_patternlayout_msgcolor"
local cvarUptimeColor = "log4g_patternlayout_uptimecolor"
local cvarFileColor = "log4g_patternlayout_filecolor"
CreateConVar(cvarConversionPattern, "[%uptime] [%level] @ %file: %msg%endl")
CreateConVar(cvarMessageColor, "135 206 250 255")
CreateConVar(cvarUptimeColor, "135 206 250 255")
CreateConVar(cvarFileColor, "60 179 113 255")

function PatternLayout:Initialize(name)
    Layout.Initialize(self, name)
end

--- Format the LogEvent using patterns.
-- @lfunction DoFormat
-- @param event LogEvent
-- @param colored If use `Color`s.
-- @return vararg formatted event in sub strings
local function DoFormat(event, colored)
    local conversionPattern = GetConVar(cvarConversionPattern):GetString()
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

    local function getCvarColor(cvar)
        if not colored then return end

        return GetConVar(cvar):GetString():ToColor()
    end

    local eventLevel = event:GetLevel()

    local tokenMap = {
        ["%msg"] = {
            color = getCvarColor(cvarMessageColor),
            content = event:GetMsg()
        },
        ["%endl"] = {
            content = "\n"
        },
        ["%uptime"] = {
            color = getCvarColor(cvarUptimeColor),
            content = event:GetTime()
        },
        ["%file"] = {
            color = getCvarColor(cvarFileColor),
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
    if not checkClass(event, "LogEvent") then return end

    return DoFormat(event, colored)
end

local function CreateDefaultLayout(name)
    return PatternLayout(name)
end

Log4g.Core.Layout.PatternLayout = {
    createDefaultLayout = CreateDefaultLayout
}