--- The Appender.
-- @classmod Appender
      Log4g.Core.Appender = Log4g.Core.Appender or {}
local HasKey              = Log4g.Util.HasKey
local Class               = include("log4g/core/impl/MiddleClass.lua")
local Appender            = Class("Appender")

function Appender:Initialize(name, func)
    self.name = name
    self.func = func
end

local ConsoleAppender = Appender:subclass("ConsoleAppender")

function ConsoleAppender:Initialize(name, func)
    Appender.Initialize(self, name, func)
end

local INSTANCES = {
    ConsoleAppender = ConsoleAppender:New("ConsoleAppender", include("log4g/core/layout/PatternLayout.lua"))
}

function Log4g.Core.Appender.GetAppender(name)
    if HasKey(INSTANCES, name) then
        return INSTANCES[name]
    else
        return nil
    end
end