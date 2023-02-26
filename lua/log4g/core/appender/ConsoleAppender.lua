local Appender = Log4g.Core.Appender.Class()
local ConsoleAppender = Appender:subclass("ConsoleAppender")

function ConsoleAppender:Initialize(name)
    Appender.Initialize(self, name)
end

function ConsoleAppender:Append()
end