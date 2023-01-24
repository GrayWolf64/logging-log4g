--- The Layout.
-- @classmod Layout
Log4g.Core.Layout = Log4g.Core.Layout or {}
local Class = include("log4g/core/impl/MiddleClass.lua")
local Layout = Class("Layout")

function Layout:Initialize(name, func)
    self.name = name
    self.func = func
end

Log4g.Core.Layout.PatternLayout = Layout:New("PatternLayout", include("log4g/core/layout/PatternLayout.lua"))