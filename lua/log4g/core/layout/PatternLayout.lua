--- A flexible layout configurable with pattern string.
-- @classmod PatternLayout
Log4g.Core.Layout.PatternLayout = Log4g.Core.Layout.PatternLayout or {}
local Layout = Log4g.Core.Layout.GetClass()
local PatternLayout = Layout:subclass("PatternLayout")
local IsLogEvent = include("log4g/core/util/TypeUtil.lua").IsLogEvent
local cvar_cp = "log4g.patternlayout.ConversionPattern"
local pairs, ipairs = pairs, ipairs
local unpack = unpack
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

    local keys = {"%msg", "%endl", "%uptime", "%file", "%level"}

    for _, v in pairs(keys) do
        for i, j in ipairs(substrs) do
            if j:find("%" .. v) then
                local oldvalue = substrs[i]
                table_remove(substrs, i)
                table_insert(substrs, i, v)
                table_insert(substrs, i + 1, oldvalue:sub(#v + 1, #oldvalue))
            end
        end
    end

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
    mkfunc_precolor("%level", lv:GetColor())(substrs, lv:GetName())
    mkfunc_precolor("%msg", color_white)(substrs, event:GetMsg())
    mkfunc_precolor("%file", color_white)(substrs, event:GetSource():GetFileFromFilename())
    mkfunc_precolor("%endl")(substrs, "\n")
    mkfunc_precolor("%uptime")(substrs, event:GetTime())

    return unpack(substrs)
end

function PatternLayout:Format(event)
    if not IsLogEvent(event) then return end

    return DoFormat(event)
end

function Log4g.Core.Layout.PatternLayout.CreateDefaultLayout(name)
    return PatternLayout(name)
end