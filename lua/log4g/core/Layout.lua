--- The Layout.
-- @classmod Layout
Log4g.Core.Layout = Log4g.Core.Layout or {}
local Object = Log4g.Core.Object.GetClass()
local Layout = Object:subclass("Layout")

function Layout:Initialize(name)
    Object.Initialize(self)
    self:SetName(name)
end

function Layout:__tostring()
    return "Layout: [name:" .. self:GetName() .. "]"
end

function Log4g.Core.Layout.GetClass()
    return Layout
end