--- A flexible layout configurable with pattern string.
-- @classmod PatternLayout
-- @license Apache License 2.0
-- @copyright GrayWolf64
local Layout = Log4g.GetPkgClsFuncs("log4g-core", "Layout").getClass()
local PatternLayout = Layout:subclass("PatternLayout")
local IsLogEvent = Log4g.GetPkgClsFuncs("log4g-core", "TypeUtil").IsLogEvent
local charPos = include("log4g/core/util/StringUtil.lua").CharPos
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
-- @return vararg formatted event in substrs
local function DoFormat(event)
    local cp = GetConVar(cvarConversionPattern):GetString()
    local pos = charPos(cp, "%")
    if pos == true then return cp end
    local substrs = {}
    local headerpos = 1

    for k, v in ipairs(pos) do
        local prevpos, nextpos = pos[k - 1], pos[k + 1]

        if prevpos then
            headerpos = prevpos
        end

        if v - 1 ~= 0 then
            substrs[k] = cp:sub(headerpos, v - 1)
        end

        if not nextpos then
            substrs[k + 1] = cp:sub(v, #cp)
        end
    end

    local lv = event:GetLevel()

    local function getCvarColor(cvar)
        return GetConVar(cvar):GetString():ToColor()
    end

    local tkmap = {
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
            color = lv:GetColor(),
            content = lv:GetName()
        }
    }

    for k in pairs(tkmap) do
        for i, j in ipairs(substrs) do
            if j:find(k, 1, true) then
                local oldvalue = substrs[i]
                tableRemove(substrs, i)
                tableInsert(substrs, i, k)
                tableInsert(substrs, i + 1, oldvalue:sub(#k + 1, #oldvalue))
            end
        end
    end

    --- Make a function that can replace a table's matching values with replacement content(string),
    -- and insert a Color before each replaced value.
    -- @lfunction mkfunc_precolor
    -- @param token String to search for and to be replaced
    -- @param color Color object to insert before each replaced value
    -- @return function output func
    local function mkfunc_precolor(token, color)
        return function(tbl, content)
            for k, v in ipairs(tbl) do
                if v == token then
                    tbl[k] = content

                    if color then
                        tableInsert(tbl, k, color)
                    else
                        tableInsert(tbl, k, defaultColor)
                    end

                    tableInsert(tbl, k + 2, defaultColor)
                end
            end
        end
    end

    for k, v in pairs(tkmap) do
        mkfunc_precolor(k, v.color)(substrs, v.content)
    end

    return unpack(substrs)
end

--- Format a LogEvent.
-- @param event LogEvent
-- @return vararg result
function PatternLayout:Format(event)
    if not IsLogEvent(event) then return end

    return DoFormat(event)
end

local function CreateDefaultLayout(name)
    return PatternLayout(name)
end

Log4g.RegisterPackageClass("log4g-core", "PatternLayout", {
    createDefaultLayout = CreateDefaultLayout,
})