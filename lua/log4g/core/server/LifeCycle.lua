Log4g.Core.LifeCycle = Log4g.Core.LifeCycle or {}

Log4g.Core.LifeCycle.State = {
    INITIALIZING = function() return "INITIALIZING" end,
    INITIALIZED = function() return "INITIALIZED" end,
    STARTING = function() return "STARTING" end,
    STARTED = function() return "STARTED" end,
    STOPPING = function() return "STOPPING" end,
    STOPPED = function() return "STOPPED" end
}

function Log4g.Core.LifeCycle.SetState(obj, state)
    obj.state = state
end

function Log4g.Core.LifeCycle.GetState(obj)
    return obj.state
end

function Log4g.Core.LifeCycle.IsStarted(obj)
    if obj.state == Log4g.Core.LifeCycle.State.STARTED then return true end

    return false
end