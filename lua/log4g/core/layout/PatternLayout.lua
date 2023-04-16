--- A flexible layout configurable with pattern string.
-- @classmod PatternLayout
-- @license Apache License 2.0
-- @copyright GrayWolf64
Log4g.Core.Layout.PatternLayout = Log4g.Core.Layout.PatternLayout or {}
local Layout = Log4g.Core.Layout.GetClass()
local PatternLayout = Layout:subclass("PatternLayout")
local IsLogEvent = include("log4g/core/util/TypeUtil.lua").IsLogEvent
local pairs, ipairs = pairs, ipairs
local unpack = unpack
local color_default = Color(0, 201, 255)
local insert, remove = table.insert, table.remove
local CharPos = include("log4g/core/util/StringUtil.lua").CharPos
local cvar_cp = "log4g_patternlayout_ConversionPattern"
local cvar_msgc = "log4g_patternlayout_msgcolor"
local cvar_uptimec = "log4g_patternlayout_uptimecolor"
local cvar_filec = "log4g_patternlayout_filecolor"
CreateConVar(cvar_cp, "[%uptime] [%level] @ %file: %msg%endl")
CreateConVar(cvar_msgc, "135 206 250 255")
CreateConVar(cvar_uptimec, "135 206 250 255")
CreateConVar(cvar_filec, "60 179 113 255")

function PatternLayout:Initialize(name)
    Layout.Initialize(self, name)
end

local function DoFormat(event)
    local cp = GetConVar(cvar_cp):GetString()
    local pos = CharPos(cp, "%")
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

    local function getcvarcolor(cvar)
        return GetConVar(cvar):GetString():ToColor()
    end

    local tkmap = {
        ["%msg"] = {
            color = getcvarcolor(cvar_msgc),
            content = event:GetMsg()
        },
        ["%endl"] = {
            content = "\n"
        },
        ["%uptime"] = {
            color = getcvarcolor(cvar_uptimec),
            content = event:GetTime()
        },
        ["%file"] = {
            color = getcvarcolor(cvar_filec),
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
                remove(substrs, i)
                insert(substrs, i, k)
                insert(substrs, i + 1, oldvalue:sub(#k + 1, #oldvalue))
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
                        insert(tbl, k, color)
                    else
                        insert(tbl, k, color_default)
                    end

                    insert(tbl, k + 2, color_default)
                end
            end
        end
    end

    for k, v in pairs(tkmap) do
        mkfunc_precolor(k, v.color)(substrs, v.content)
    end

    return unpack(substrs)
end

function PatternLayout:Format(event)
    if not IsLogEvent(event) then return end

    return DoFormat(event)
end

function Log4g.Core.Layout.PatternLayout.CreateDefaultLayout(name)
    return PatternLayout(name)
end