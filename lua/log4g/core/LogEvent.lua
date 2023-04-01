--- Provides contextual information about a logged message.
-- A LogEvent must be Serializable so that it may be transmitted over a network connection.
-- @classmod LogEvent
Log4g.Core.LogEvent = Log4g.Core.LogEvent or {}
local Object = Log4g.Core.Object.GetClass()
local LogEvent = Object:subclass("LogEvent")
local IsLevel = include("log4g/core/util/TypeUtil.lua").IsLevel
local SysTime = SysTime
local isstring = isstring

function LogEvent:Initialize(ln, level, time, msg)
    Object.Initialize(self)
    self:SetPrivateField("ln", ln)
    self:SetPrivateField("level", level)
    self:SetPrivateField("time", time)
    self:SetPrivateField("msg", msg)
end

function LogEvent:IsLogEvent()
    return true
end

function LogEvent:GetLoggerName()
    return self:GetPrivateField("ln")
end

function LogEvent:GetLevel()
    return self:GetPrivateField("level")
end

--- Build a LogEvent.
-- @param ln Logger name
-- @param level Level object
-- @param msg String message
function Log4g.Core.LogEvent.Builder(ln, level, msg)
    if not isstring(ln) or not isstring(msg) or not IsLevel(level) then return end

    return LogEvent(ln, level, SysTime(), msg)
end