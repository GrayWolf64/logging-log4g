--- The Appender.
-- Subclassing `LifeCycle`.
-- @classmod Appender
Log4g.Core.Appender = Log4g.Core.Appender or {}
local LifeCycle = Log4g.Core.LifeCycle.GetClass()
local Appender = LifeCycle:subclass("Appender")

local PRIVATE = PRIVATE or setmetatable({}, {
    __mode = "k"
})

function Appender:Initialize(name, layout)
    LifeCycle.Initialize(self)
    PRIVATE[self] = {}
    PRIVATE[self].layout = layout
    self.name = name
end

function Appender:GetLayout()
    return PRIVATE[self].layout
end

function Log4g.Core.Appender.GetClass()
    return Appender
end