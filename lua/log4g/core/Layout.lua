--- The Layout.
-- @classmod Layout
local Object = Log4g.Core.Object.getClass()
local Layout = Layout or Object:subclass"Layout"

function Layout:Initialize()
    Object.Initialize(self)
end

Log4g.Core.Layout = {
    getClass = function() return Layout end
}

Log4g.includeFromDir("log4g/core/layout/")