--- A flexible layout configurable with pattern string.
-- @classmod PatternLayout
Log4g.Core.Layout.PatternLayout = Log4g.Core.Layout.PatternLayout or {}
local Layout = Log4g.Core.Layout.GetClass()
local PatternLayout = Layout:subclass("PatternLayout")
local IsLogEvent = include("log4g/core/util/TypeUtil.lua").IsLogEvent
local cvar_cp = "log4g.patternlayout.ConversionPattern"
local debug_getinfo = debug.getinfo
CreateConVar(cvar_cp, "%d %p [%t]: %m%n", FCVAR_NOTIFY)

function PatternLayout:Initialize(name)
    Layout.Initialize(self, name)
end

local function DoFormat(event)
    local res = GetConVar(cvar_cp):GetString()

    local rep = {
        ["%%d"] = event:GetTime(),
        ["%%m"] = event:GetMsg(),
        ["%%n"] = "\n",
        ["%%t"] = debug_getinfo(6, "S").source:GetFileFromFilename(),
        ["%%p"] = event:GetLevel():GetName()
    }

    for k, v in pairs(rep) do
        res = res:gsub(k, v)
    end

    return res
end

function PatternLayout:Format(event)
    if not IsLogEvent(event) then return end

    return DoFormat(event)
end

function Log4g.Core.Layout.PatternLayout.CreateDefaultLayout(name)
    return PatternLayout(name)
end