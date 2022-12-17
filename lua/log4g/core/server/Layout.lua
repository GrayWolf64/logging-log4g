Log4g.Layouts = {}
local Layout = include("log4g/core/server/impl/Class.lua"):Extend()

function Layout:New(name, func)
    self.name = name or ""
    self.func = func or function() end
end

function Log4g.RegisterLayout(name, func)
    local layout = Layout(name, func)
    table.insert(Log4g.Layouts, layout)

    return layout
end

local PatternLayout = include("log4g/core/server/layout/PatternLayout.lua")
Log4g.Layouts.PatternLayout = Layout("PatternLayout", PatternLayout)