--- The Appender.
-- Subclassing `LifeCycle`.
-- @classmod Appender
local LifeCycle = Log4g.Core.LifeCycle.getClass()
local Appender = Appender or LifeCycle:subclass"Appender"
Appender:include(Log4g.Core.Object.namedMixins)

function Appender:Initialize(name, layout)
    LifeCycle.Initialize(self, true)
    self.__layout = layout
    self:SetName(name)
end

function Appender:__tostring()
    return "Appender: [name:" .. self:GetName() .. "]"
end

--- Returns the Layout used by this Appender if applicable.
function Appender:GetLayout()
    return self.__layout
end

function Appender:Append()
    return true
end

Log4g.Core.Appender = {
    getClass = function() return Appender end
}

Log4g.includeFromDir("log4g/core/appender/")