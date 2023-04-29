--- Provides contextual information about a logged message.
-- A LogEvent must be Serializable so that it may be transmitted over a network connection.
-- @classmod LogEvent
Log4g.Core.LogEvent = Log4g.Core.LogEvent or {}
local Object = Log4g.GetPkgClsFuncs("log4g-core", "Object").getClass()
local LogEvent = Object:subclass"LogEvent"
local IsLevel = Log4g.GetPkgClsFuncs("log4g-core", "TypeUtil").IsLevel
local SysTime, debugGetInfo = SysTime, debug.getinfo

function LogEvent:Initialize(ln, level, time, msg, src)
    Object.Initialize(self)
    self:SetPrivateField("ln", ln)
    self:SetPrivateField("lv", level)
    self:SetPrivateField("time", time)
    self:SetPrivateField("msg", msg)
    self:SetPrivateField("src", src)
end

function LogEvent:GetLoggerName()
    return self:GetPrivateField"ln"
end

function LogEvent:GetLevel()
    return self:GetPrivateField"lv"
end

function LogEvent:GetSource()
    return self:GetPrivateField"src"
end

function LogEvent:GetMsg()
    return self:GetPrivateField"msg"
end

function LogEvent:SetMsg(msg)
    if type(msg) ~= "string" then return end
    self:SetPrivateField("msg", msg)
end

function LogEvent:GetTime()
    return self:GetPrivateField"time"
end

--- Build a LogEvent.
-- @param ln Logger name
-- @param level Level object
-- @param msg String message
function Log4g.Core.LogEvent.Builder(ln, level, msg)
    if type(ln) ~= "string" or not IsLevel(level) then return end

    return LogEvent(ln, level, SysTime(), msg, debugGetInfo(4, "S").source)
end