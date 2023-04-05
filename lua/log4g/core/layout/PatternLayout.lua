--- A flexible layout configurable with pattern string.
-- @classmod PatternLayout
Log4g.Core.Layout.PatternLayout = Log4g.Core.Layout.PatternLayout or {}
local Layout = Log4g.Core.Layout.GetClass()
local PatternLayout = Layout:subclass("PatternLayout")
local IsLogEvent = include("log4g/core/util/TypeUtil.lua").IsLogEvent
local cvar_cp = "log4g.patternlayout.ConversionPattern"
local color_white = color_white
CreateConVar(cvar_cp, "%-5p [%t]: %m%n", FCVAR_NOTIFY)

function PatternLayout:Initialize(name)
    Layout.Initialize(self, name)
end

local function DoFormat(event)
    local cp = GetConVar(cvar_cp):GetString()

    if cp:find("%%") then
        local lv = event:GetLevel()
        cp = cp:gsub("%%%p%d%l", lv:GetColor():__tostring() .. lv:GetName())
        cp = cp:gsub("%%%m", color_white:__tostring() .. event:GetMsg()):gsub("%%%n", "\n")

        return cp
    end
end

function PatternLayout:Format(event)
    if not IsLogEvent(event) then return end

    return DoFormat(event)
end

function Log4g.Core.Layout.PatternLayout.CreateDefaultLayout(name)
    return PatternLayout(name)
end