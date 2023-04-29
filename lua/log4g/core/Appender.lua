--- The Appender.
-- Subclassing `LifeCycle`.
-- @classmod Appender
local LifeCycle = Log4g.GetPkgClsFuncs("log4g-core", "LifeCycle").getClass()
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

function Appender:Append()
    return true
end

local function GetClass()
    return Appender
end

Log4g.RegisterPackageClass("log4g-core", "Appender", {
    getClass = GetClass,
})