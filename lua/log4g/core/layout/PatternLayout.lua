--- A flexible layout configurable with pattern string.
-- @classmod PatternLayout
Log4g.Core.Layout.PatternLayout = Log4g.Core.Layout.PatternLayout or {}
local Layout = Log4g.Core.Layout.GetClass()
local PatternLayout = Layout:subclass("PatternLayout")
local IsLogEvent = include("log4g/core/util/TypeUtil.lua").IsLogEvent
CreateConVar("log4g.patternlayout.ConversionPattern", "%-5p [%t]: %m%n", FCVAR_NOTIFY)

function PatternLayout:Initialize(name)
    Layout.Initialize(self, name)
end

function PatternLayout:Format(event)
    if not IsLogEvent(event) then return end
    local lv = event:GetLevel()

    return lv:GetColor(), lv:GetName(), " ", Color(255, 255, 255), event:GetMsg(), "\n"
end

function Log4g.Core.Layout.PatternLayout.CreateDefaultLayout(name)
    return PatternLayout(name)
end