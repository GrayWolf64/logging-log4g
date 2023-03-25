--- A flexible layout configurable with pattern string.
-- @classmod PatternLayout
local Layout = Log4g.Core.Layout.GetClass()
local PatternLayout = Layout:subclass("PatternLayout")

function PatternLayout:Initialize(name)
    Layout.Initialize(self, name)
end

function Log4g.Core.Layout.CreateDefaultLayout(name)
    return PatternLayout(name)
end