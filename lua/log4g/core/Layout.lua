--- The Layout.
-- @classmod Layout
      Log4g.Core.Layout = Log4g.Core.Layout or {}
local HasKey            = Log4g.Util.HasKey
local Class             = include("log4g/core/impl/MiddleClass.lua")
local Layout            = Class("Layout")

function Layout:Initialize(name, func)
    self.name = name
    self.func = func
end

local PatternLayout = Layout:subclass("PatternLayout")

function PatternLayout:Initialize(name, func)
    Layout.Initialize(self, name, func)
end

local INSTANCES = {
    PatternLayout = PatternLayout:New("PatternLayout", include("log4g/core/layout/PatternLayout.lua"))
}

function Log4g.Core.Layout.GetLayoutAll()
    return INSTANCES
end

function Log4g.Core.Layout.GetLayout(name)
    if HasKey(INSTANCES, name) then
        return INSTANCES[name]
    else
        return nil
    end
end