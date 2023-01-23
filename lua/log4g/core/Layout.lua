--- The Layout.
-- @classmod Layout
Log4g.Core.Layout = Log4g.Core.Layout or {}
Log4g.Core.Layout.Buffer = Log4g.Core.Layout.Buffer or {}
local Class = include("log4g/core/impl/MiddleClass.lua")
local Layout = Class("Layout")

function Layout:Initialize(name, func)
    self.name = name
    self.func = func
end

--- Register a Layout.
-- If the Layout with the same name already exists, its function will be overrode.
-- @param name The name of the Layout
-- @param func The function of the layouting process
-- @return object layout
function Log4g.Core.Layout.RegisterLayout(name, func)
    local layout = Layout:New(name, func)
    table.insert(Log4g.Core.Layout.Buffer, layout)

    return layout
end

Log4g.Core.Layout.Buffer.PatternLayout = Layout:New("PatternLayout", include("log4g/core/layout/PatternLayout.lua"))