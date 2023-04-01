--- Appends log events to engine console using a layout specified by the user.
-- Subclassing `Appender`.
-- @classmod ConsoleAppender
local Appender = Log4g.Core.Appender.GetClass()
local ConsoleAppender = Appender:subclass("ConsoleAppender")
local pcall = pcall

function ConsoleAppender:Initialize(name, layout)
    Appender.Initialize(self, name, layout)
end

function ConsoleAppender:Append(logevent)
    if not pcall(function()
        logevent:IsLogEvent()
    end) then
        return
    end
end

function Log4g.Core.Appender.CreateConsoleAppender(name, layout)
    return ConsoleAppender(name, layout)
end