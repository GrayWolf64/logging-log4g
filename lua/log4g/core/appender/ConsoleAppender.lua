--- Appends log events to engine console using a layout specified by the user.
-- Subclassing `Appender`.
-- @classmod ConsoleAppender
local Appender = Log4g.Core.Appender.getClass()
local ConsoleAppender = ConsoleAppender or Appender:subclass"ConsoleAppender"
local checkClass = include"../util/TypeUtil.lua".checkClass

function ConsoleAppender:Initialize(name, layout)
    Appender.Initialize(self, name, layout)
end

function ConsoleAppender:Append(event)
    assert(checkClass(event, "LogEvent"), "only Log4g LogEvent objects are accepted")

    MsgC(self:GetLayout():Format(event, true))
end

Log4g.Core.Appender.ConsoleAppender = {
    createConsoleAppender = function(name, layout)
        assert(type(name) == "string" and #name > 0, "name for ConsoleAppender must be a string with a len > 0")
        assert(checkClass(layout, "Layout"), "layout must be a Log4g Layout object")

        return ConsoleAppender(name, layout)
    end
}