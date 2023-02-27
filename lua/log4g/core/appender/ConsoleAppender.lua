--- Appends log events to engine console using a layout specified by the user.
-- Subclassing `Appender`.
-- @classmod ConsoleAppender
local Appender = Log4g.Core.Appender.Class()
local ConsoleAppender = Appender:subclass("ConsoleAppender")

function ConsoleAppender:Initialize(name)
    Appender.Initialize(self, name)
end

function ConsoleAppender:Append()
end

function Log4g.Core.Appender.CreateConsoleAppender(name)
    return ConsoleAppender(name)
end