--- Provides contextual information about a logged message.
-- A LogEvent must be Serializable so that it may be transmitted over a network connection.
-- @classmod LogEvent
Log4g.Core.LogEvent = Log4g.Core.LogEvent or {}
local Object = Log4g.Core.Object.getClass()
local LogEvent = LogEvent or Object:subclass"LogEvent"
local checkClass = include"util/TypeUtil.lua".checkClass
local SysTime, debugGetInfo = SysTime, debug.getinfo

function LogEvent:Initialize(ln, level, time, msg, src)
    Object.Initialize(self)
    self.__loggerName = ln
    self.__level = level
    self.__time = time
    self.__msg = msg
    self.__src = src
end

function LogEvent:GetLoggerName()
    return self.__loggerName
end

function LogEvent:GetLevel()
    return self.__level
end

function LogEvent:GetSource()
    return self.__src
end

function LogEvent:GetMsg()
    return self.__msg
end

function LogEvent:SetMsg(msg)
    if type(msg) ~= "string" then return end
    self.__msg = msg
end

function LogEvent:GetTime()
    return self.__time
end

--- Build a LogEvent.
-- @param ln Logger name
-- @param level Level object
-- @param msg String message
function Log4g.Core.LogEvent.Builder(ln, level, msg)
    assert(type(ln) == "string", "loggerName(ln) must be a string")
    assert(checkClass(level, "Level"), "level must be a Log4g Level object")
    assert(type(msg) == "string", "message(msg) must be a string")

    return LogEvent(ln, level, SysTime(), msg, debugGetInfo(4, "S").source)
end