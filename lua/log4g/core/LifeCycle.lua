--- The LifeCycle for objects.
-- @script LifeCycle
-- @license Apache License 2.0
-- @copyright GrayWolf64
Log4g.Core.LifeCycle = Log4g.Core.LifeCycle or {}
local HasKey = Log4g.Util.HasKey

--- LifeCycle states (status of a life cycle).
-- @table Log4g.Core.LifeCycle.State
-- @field INITIALIZING Object is in its initial state and not yet initialized.
-- @field INITIALIZED Initialized but not yet started.
-- @field STARTING In the process of starting.
-- @field STARTED Has started.
-- @field STOPPING Stopping is in progress.
-- @field STOPPED Has stopped.
Log4g.Core.LifeCycle.State = {
    INITIALIZING = function() return "INITIALIZING" end,
    INITIALIZED  = function() return "INITIALIZED" end,
    STARTING     = function() return "STARTING" end,
    STARTED      = function() return "STARTED" end,
    STOPPING     = function() return "STOPPING" end,
    STOPPED      = function() return "STOPPED" end
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
-- If the object doesn't have a state, an error will be returned.
-- @param obj The object to get the state
-- @return function state
function Log4g.Core.LifeCycle.GetState(obj)
    if not HasKey(obj, "state") then
        error("GetState failed: The object doesn't have a state.\n")

        return
    end

    return obj.state
end

--- Check whether the obeject's state is STARTED.
-- If the object doesn't have a state, an error will be returned.
-- @param obj The object to check
-- @return bool isstarted
function Log4g.Core.LifeCycle.IsStarted(obj)
    if not HasKey(obj, "state") then
        error("Failed to check IsStarted: The object doesn't have a state.\n")

        return
    end

    if obj.state == Log4g.Core.LifeCycle.State.STARTED then return true end

    return false
end