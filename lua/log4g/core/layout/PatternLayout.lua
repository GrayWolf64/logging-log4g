--- A flexible layout configurable with pattern string.
-- @classmod PatternLayout
local Layout = Log4g.Core.Layout.Class()
local PatternLayout = Layout:subclass("PatternLayout")

function PatternLayout:Initialize(name)
    Layout.Initialize(self, name)
end