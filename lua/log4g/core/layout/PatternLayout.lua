--- A flexible layout configurable with pattern string.
-- @classmod PatternLayout
Log4g.Core.Layout.PatternLayout = Log4g.Core.Layout.PatternLayout or {}
local Layout = Log4g.Core.Layout.GetClass()
local PatternLayout = Layout:subclass("PatternLayout")
local IsLogEvent = include("log4g/core/util/TypeUtil.lua").IsLogEvent
local cvar_cp = "log4g.patternlayout.ConversionPattern"
CreateConVar(cvar_cp, "%d %p [%t]: %m%n", FCVAR_NOTIFY)

function PatternLayout:Initialize(name)
    Layout.Initialize(self, name)
end

local function DoFormat(event)
    GetConVar(cvar_cp):GetString()
end

function PatternLayout:Format(event)
    if not IsLogEvent(event) then return end

    return DoFormat(event)
end

function Log4g.Core.Layout.PatternLayout.CreateDefaultLayout(name)
    return PatternLayout(name)
end