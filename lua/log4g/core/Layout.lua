--- The Layout.
-- @classmod Layout
Log4g.Core.Layout = Log4g.Core.Layout or {}
local Layout = include("log4g/core/impl/MiddleClass.lua")("Layout")

local PRIVATE = PRIVATE or setmetatable({}, {
    __mode = "k"
})

function Layout:Initialize(name)
    self.name = name
    PRIVATE[self] = {}
end

function Log4g.Core.Layout.GetClass()
    return Layout
end