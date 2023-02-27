--- The Appender.
-- Subclassing `LifeCycle`.
-- @classmod Appender
Log4g.Core.Appender = Log4g.Core.Appender or {}
local LifeCycle = Log4g.Core.LifeCycle.Class()
local Appender = LifeCycle:subclass("Appender")

local PRIVATE = PRIVATE or setmetatable({}, {
    __mode = "k"
})

function Appender:Initialize(name)
    LifeCycle.Initialize(self)
    PRIVATE[self] = {}
    self.name = name
end

--- Sets the location of the Appender.
-- It's where this Appender is configured, namely a LoggerConfig.
-- @param name lcname
function Appender:SetLocn(name)
    PRIVATE[self].locn = name
end

function Appender:GetLocn()
    return PRIVATE[self].locn
end

function Log4g.Core.Appender.Class()
    return Appender
end