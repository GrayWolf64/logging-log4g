--- The Layout.
-- @classmod Layout
local Object = Log4g.Core.Object.getClass()
local Layout = Object:subclass"Layout"

function Layout:Initialize(name)
    Object.Initialize(self)
    self:SetName(name)
end

function Layout:__tostring()
    return "Layout: [name:" .. self:GetName() .. "]"
end

local function GetClass()
    return Layout
end

Log4g.Core.Layout = {
    getClass = GetClass
}