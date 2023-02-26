--- The Appender.
-- Subclassing `LifeCycle`.
-- @classmod Appender
Log4g.Core.Appender = Log4g.Core.Appender or {}
local LifeCycle = Log4g.Core.LifeCycle.Class()
local Appender = LifeCycle:subclass("Appender")

function Appender:Initialize(name)
    self.name = name
end

function Log4g.Core.Appender.Class()
    return Appender
end