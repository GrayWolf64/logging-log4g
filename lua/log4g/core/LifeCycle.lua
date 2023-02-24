--- The LifeCycle for objects.
-- LifeCycles of objects are stored in their private tables.
-- @script LifeCycle
-- @license Apache License 2.0
-- @copyright GrayWolf64
Log4g.Core.LifeCycle = Log4g.Core.LifeCycle or {}

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
    INITIALIZED = function() return "INITIALIZED" end,
    STARTING = function() return "STARTING" end,
    STARTED = function() return "STARTED" end,
    STOPPING = function() return "STOPPING" end,
    STOPPED = function() return "STOPPED" end,
}

--- Set the LifeCycle state for an object.
-- @param tbl The object's private table
-- @param state The state to set, must be a function that returns a string
function Log4g.Core.LifeCycle.SetState(tbl, state)
    if not isfunction(state) then return end
    tbl.state = state
end

--- Get the LifeCycle state that the object is at.
-- @param tbl The object's private table
-- @return function state
function Log4g.Core.LifeCycle.GetState(tbl)
    if not tbl["state"] then return end

    return tbl.state
end

local STARTED = Log4g.Core.LifeCycle.State.STARTED

--- Check whether the obeject's state is STARTED.
-- @param tbl The object's private table
-- @return bool isstarted
function Log4g.Core.LifeCycle.IsStarted(tbl)
    if not tbl["state"] then return end
    if tbl.state == STARTED then return true end

    return false
end