--- A flexible layout configurable with pattern string.
-- @classmod PatternLayout
-- @license Apache License 2.0
-- @copyright GrayWolf64
Log4g.Core.Layout.PatternLayout = Log4g.Core.Layout.PatternLayout or {}
local Layout = Log4g.Core.Layout.GetClass()
local PatternLayout = Layout:subclass("PatternLayout")
local IsLogEvent = include("log4g/core/util/TypeUtil.lua").IsLogEvent
local cvar_cp = "log4g.patternlayout.ConversionPattern"
local pairs, ipairs = pairs, ipairs
local unpack = unpack
local color_white = color_white
local table_insert, table_remove = table.insert, table.remove
local CharPos = include("log4g/core/util/StringUtil.lua").CharPos
CreateConVar(cvar_cp, "%uptime %level [%file]: %msg%endl", FCVAR_NOTIFY)

function PatternLayout:Initialize(name)
    Layout.Initialize(self, name)
end

local function DoFormat(event)
    local cp = GetConVar(cvar_cp):GetString()
    local pos = CharPos(cp, "%")
    if pos == true then return cp end
    local substrs = {}

    for k, v in ipairs(pos) do
        local n = pos[k + 1]

        if n then
            substrs[k] = cp:sub(v, n - 1)
        else
            substrs[k] = cp:sub(v, #cp)
        end
    end

    local tokens = {"%msg", "%endl", "%uptime", "%file", "%level"}

    for _, v in pairs(tokens) do
        for i, j in ipairs(substrs) do
            if j:find(v, 1, true) then
                local oldvalue = substrs[i]
                table_remove(substrs, i)
                table_insert(substrs, i, v)
                table_insert(substrs, i + 1, oldvalue:sub(#v + 1, #oldvalue))
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
            local i = {}

            for k, v in ipairs(tbl) do
                if v == token then
                    i[k] = true
                end
            end

            for idx in pairs(i) do
                tbl[idx] = content

                if color then
                    table_insert(tbl, idx - 1, color)
                end
            end
        end
    end

    local lv = event:GetLevel()
    mkfunc_precolor(tokens[5], lv:GetColor())(substrs, lv:GetName())
    mkfunc_precolor(tokens[1], color_white)(substrs, event:GetMsg())
    mkfunc_precolor(tokens[4], color_white)(substrs, event:GetSource():GetFileFromFilename())
    mkfunc_precolor(tokens[2])(substrs, "\n")
    mkfunc_precolor(tokens[3])(substrs, event:GetTime())

    return unpack(substrs)
end

function PatternLayout:Format(event)
    if not IsLogEvent(event) then return end

    return DoFormat(event)
end

function Log4g.Core.Layout.PatternLayout.CreateDefaultLayout(name)
    return PatternLayout(name)
end