Log4g.Core.LifeCycle = Log4g.Core.LifeCycle or {}
Log4g.Core.LifeCycle._States = Log4g.Core.LifeCycle._States or {}
local Class = include("log4g/core/impl/MiddleClass.lua")
local State = Class("State")

function State:Initialize(name, int)
    self.name = name or ""
    self.int = int or 0
end

Log4g.Core.LifeCycle._States.INITIALIZING = State:New("INITIALIZING", 100)
Log4g.Core.LifeCycle._States.INITIALIZED = State:New("INITIALIZED", 200)
Log4g.Core.LifeCycle._States.STARTING = State:New("STARTING", 300)
Log4g.Core.LifeCycle._States.STARTED = State:New("STARTED", 400)
Log4g.Core.LifeCycle._States.STOPPING = State:New("STOPPING", 500)
Log4g.Core.LifeCycle._States.STOPPED = State:New("STOPPED", 600)

function Log4g.Core.LifeCycle.GetState(name)
    if not isstring(name) then return end

    for k, v in pairs(Log4g.Core.LifeCycle.States) do
        if k == name then return v end
    end
end