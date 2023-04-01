--- Provides contextual information about a logged message.
-- A LogEvent must be Serializable so that it may be transmitted over a network connection.
-- @classmod LogEvent
Log4g.Core.LogEvent = Log4g.Core.LogEvent or {}
local Object = Log4g.Core.Object.GetClass()
local LogEvent = Object:subclass("LogEvent")

function LogEvent:Initialize(loggern, level, time, msg)
    Object.Initialize(self)
    self:SetPrivateField("loggern", loggern)
    self:SetPrivateField("level", level)
    self:SetPrivateField("time", time)
    self:SetPrivateField("msg", msg)
end

function LogEvent:GetLoggerName()
    return self:GetPrivateField("loggern")
end

function LogEvent:GetLevel()
    return self:GetPrivateField("level")
end

function Log4g.Core.LogEvent.Builder(loggern, level, time, msg)
    return LogEvent(loggern, level, time, msg)
end