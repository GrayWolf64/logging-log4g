--- The Layout.
-- @classmod Layout
Log4g.Core.Layout = Log4g.Core.Layout or {}
local Layout = include("log4g/core/impl/MiddleClass.lua")("Layout")

function Layout:Initialize(name, func)
    self.name = name
    self.func = func
end

local PatternLayout = Layout:subclass("PatternLayout")

function PatternLayout:Initialize(name)
    Layout.Initialize(self, name, "log4g/core/layout/PatternLayout.lua")
end