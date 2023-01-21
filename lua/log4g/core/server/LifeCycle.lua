Log4g.Core.LifeCycle = Log4g.Core.LifeCycle or {}

Log4g.Core.LifeCycle.State = {
    INITIALIZING = "INITIALIZING",
    INITIALIZED = "INITIALIZED",
    STARTING = "STARTING",
    STARTED = "STARTED",
    STOPPING = "STOPPING",
    STOPPED = "STOPPED"
}

function Log4g.Core.LifeCycle.SetState(obj, state)
    obj.state = state
end

function Log4g.Core.LifeCycle.GetState(obj)
    return obj.state
end