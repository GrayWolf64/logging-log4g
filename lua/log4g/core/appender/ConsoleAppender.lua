--- Appends log events to engine console using a layout specified by the user.
-- Subclassing `Appender`.
-- @classmod ConsoleAppender
local Appender = Log4g.Core.Appender.getClass()
local ConsoleAppender = ConsoleAppender or Appender:subclass"ConsoleAppender"
local checkClass = include"../util/TypeUtil.lua".checkClass
local MsgC = MsgC

function ConsoleAppender:Initialize(name, layout)
    Appender.Initialize(self, name, layout)
end

function ConsoleAppender:Append(event)
    if not checkClass(event, "LogEvent") then return end
    local layout = self:GetLayout()
    if not checkClass(layout, "Layout") then return end
    MsgC(layout:Format(event, true))
end

local function CreateConsoleAppender(name, layout)
    return ConsoleAppender(name, layout)
end

Log4g.Core.Appender.ConsoleAppender = {
    createConsoleAppender = CreateConsoleAppender
}