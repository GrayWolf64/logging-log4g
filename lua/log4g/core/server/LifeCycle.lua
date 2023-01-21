--- The LifeCycle for objects.
-- @script LifeCycle.lua
Log4g.Core.LifeCycle = Log4g.Core.LifeCycle or {}

Log4g.Core.LifeCycle.State = {
    INITIALIZING = function() return "INITIALIZING" end,
    INITIALIZED = function() return "INITIALIZED" end,
    STARTING = function() return "STARTING" end,
    STARTED = function() return "STARTED" end,
    STOPPING = function() return "STOPPING" end,
    STOPPED = function() return "STOPPED" end
}

--- Set the LifeCycle state for an object.
-- @param obj The object to set state for
-- @param state The state to set, must be a function that returns a string
function Log4g.Core.LifeCycle.SetState(obj, state)
    if not isfunction(state) then
        error("SetState failed: state must be a function.\n")

        return
    end

    obj.state = state
end

--- Get the LifeCycle state that the object is at.
-- @param obj The object to get the state
function Log4g.Core.LifeCycle.GetState(obj)
    return obj.state
end

--- Check whether the obeject's state is STARTED.
-- @param obj The object to check
-- @return bool isstarted
function Log4g.Core.LifeCycle.IsStarted(obj)
    if obj.state == Log4g.Core.LifeCycle.State.STARTED then return true end

    return false
end