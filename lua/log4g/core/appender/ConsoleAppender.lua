--- Appends log events to engine console using a layout specified by the user.
-- Subclassing `Appender`.
-- @classmod ConsoleAppender
local Appender = Log4g.Core.Appender.GetClass()
local ConsoleAppender = Appender:subclass("ConsoleAppender")
local IsLogEvent = include("log4g/core/util/TypeUtil.lua").IsLogEvent
local MsgC = MsgC

function ConsoleAppender:Initialize(name, layout)
    Appender.Initialize(self, name, layout)
end

function ConsoleAppender:Append(event)
    if not IsLogEvent(event) then return end
    MsgC(self:GetLayout():Format(event))
end

function Log4g.Core.Appender.CreateConsoleAppender(name, layout)
    return ConsoleAppender(name, layout)
end