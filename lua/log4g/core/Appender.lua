--- The Appender.
-- Subclassing `LifeCycle`.
-- @classmod Appender
Log4g.Core.Appender = Log4g.Core.Appender or {}
local LifeCycle = Log4g.Core.LifeCycle.getClass()
local Appender = LifeCycle:subclass"Appender"

function Appender:Initialize(name, layout)
    LifeCycle.Initialize(self)
    self:SetPrivateField(0x0017, layout)
    self:SetName(name)
end

function Appender:__tostring()
    return "Appender: [name:" .. self:GetName() .. "]"
end

--- Returns the Layout used by this Appender if applicable.
function Appender:GetLayout()
    return self:GetPrivateField(0x0017)
end

function Appender:Append()
    return true
end

function Log4g.Core.Appender.getClass()
    return Appender
end

Log4g.includeFromDir("log4g/core/appender/")