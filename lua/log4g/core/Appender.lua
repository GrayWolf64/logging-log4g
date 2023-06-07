--- The Appender.
-- Subclassing `LifeCycle`.
-- @classmod Appender
local LifeCycle = Log4g.LifeCycle.getClass()
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

local function GetClass()
    return Appender
end

Log4g.RegisterPackageClass("log4g-core", "Appender", {
    getClass = GetClass,
})