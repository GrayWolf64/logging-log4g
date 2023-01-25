--- The Appender.
-- @classmod Appender
Log4g.Core.Appender = Log4g.Core.Appender or {}
local Class = include("log4g/core/impl/MiddleClass.lua")
local Appender = Class("Appender")

function Appender:Initialize(name, func)
    self.name = name
    self.func = func
end

local ConsoleAppender = Appender:subclass("ConsoleAppender")

function ConsoleAppender:Initialize(name, func, layout)
    Appender.Initialize(self, name, func)
    self.layout = layout
end