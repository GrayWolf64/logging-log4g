--- The Appender.
-- Subclassing `LifeCycle`.
-- @classmod Appender
Log4g.Core.Appender = Log4g.Core.Appender or {}
local LifeCycle = Log4g.Core.LifeCycle.GetClass()
local Appender = LifeCycle:subclass("Appender")

function Appender:Initialize(name, layout)
    LifeCycle.Initialize(self)
    self:SetPrivateField("layout", layout)
    self:SetName(name)
end

function Appender:__tostring()
    return "Appender: [name:" .. self:GetName() .. "]"
end

--- Returns the Layout used by this Appender if applicable.
function Appender:GetLayout()
    return self:GetPrivateField("layout")
end

function Log4g.Core.Appender.GetClass()
    return Appender
end