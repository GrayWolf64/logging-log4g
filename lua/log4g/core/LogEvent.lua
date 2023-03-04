--- Provides contextual information about a logged message.
-- A LogEvent must be Serializable so that it may be transmitted over a network connection.
-- @classmod LogEvent
Log4g.Core.LogEvent = Log4g.Core.LogEvent or {}
local LogEvent = include("log4g/core/impl/MiddleClass.lua")("LogEvent")

function LogEvent:Initialize()
end