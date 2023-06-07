--- Provides contextual information about a logged message.
-- A LogEvent must be Serializable so that it may be transmitted over a network connection.
-- @classmod LogEvent
Log4g.Core.LogEvent = Log4g.Core.LogEvent or {}
local Object = Log4g.Core.Object.getClass()
local LogEvent = Object:subclass"LogEvent"
local checkClass = include("log4g/core/util/TypeUtil.lua").checkClass
local SysTime, debugGetInfo = SysTime, debug.getinfo

function LogEvent:Initialize(ln, level, time, msg, src)
    Object.Initialize(self)
    self:SetPrivateField(0x001A, ln)
    self:SetPrivateField(0x001B, level)
    self:SetPrivateField(0x001C, time)
    self:SetPrivateField(0x001D, msg)
    self:SetPrivateField(0x001E, src)
end

function LogEvent:GetLoggerName()
    return self:GetPrivateField(0x001A)
end

function LogEvent:GetLevel()
    return self:GetPrivateField(0x001B)
end

function LogEvent:GetSource()
    return self:GetPrivateField(0x001E)
end

function LogEvent:GetMsg()
    return self:GetPrivateField(0x001D)
end

function LogEvent:SetMsg(msg)
    if type(msg) ~= "string" then return end
    self:SetPrivateField(0x001D, msg)
end

function LogEvent:GetTime()
    return self:GetPrivateField(0x001C)
end

--- Build a LogEvent.
-- @param ln Logger name
-- @param level Level object
-- @param msg String message
function Log4g.Core.LogEvent.Builder(ln, level, msg)
    if type(ln) ~= "string" or not checkClass(level, "Level") then return end

    return LogEvent(ln, level, SysTime(), msg, debugGetInfo(4, "S").source)
end