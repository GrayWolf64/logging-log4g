--- In Log4g, the main interface for handling the life cycle context of an object is this one.
-- An object first starts in the LifeCycle.State.INITIALIZED state by default to indicate the class has been loaded.
-- From here, calling the `Start()` method will change this state to LifeCycle.State.STARTING.
-- After successfully being started, this state is changed to LifeCycle.State.STARTED.
-- When the `Stop()` is called, this goes into the LifeCycle.State.STOPPING state.
-- After successfully being stopped, this goes into the LifeCycle.State.STOPPED state.
-- In most circumstances, implementation classes should store their LifeCycle.State in a volatile field dependent on synchronization and concurrency requirements.
-- Subclassing 'Object'.
-- @classmod LifeCycle
-- @license Apache License 2.0
-- @copyright GrayWolf64
local _M = _M or {}
local t = t or 0
if t >= 1 then return _M end
t = t + 1
local Object = Log4g.Core.Object.GetClass()
local LifeCycle = Object:subclass("LifeCycle")
local isfunction = isfunction

--- LifeCycle states.
-- @table State
-- @local
-- @field INITIALIZING Object is in its initial state and not yet initialized.
-- @field INITIALIZED Initialized but not yet started.
-- @field STARTING In the process of starting.
-- @field STARTED Has started.
-- @field STOPPING Stopping is in progress.
-- @field STOPPED Has stopped.
local State = {
    INITIALIZING = function() return 100 end,
    INITIALIZED = function() return 200 end,
    STARTING = function() return 300 end,
    STARTED = function() return 400 end,
    STOPPING = function() return 500 end,
    STOPPED = function() return 600 end,
}

function LifeCycle:Initialize()
    Object.Initialize(self)
    self:SetState(State.INITIALIZED)
end

--- Sets the LifeCycle state.
-- @param state A function in the `State` table which returns a string representing the state
function LifeCycle:SetState(state)
    if not isfunction(state) then return end
    self:SetPrivateField("state", state)
end

function LifeCycle:Start()
    self:SetState(State.STARTED)
end

function LifeCycle:SetStopping()
    self:SetState(State.STOPPING)
end

function LifeCycle:SetStopped()
    self:SetState(State.STOPPED)
end

--- Gets the LifeCycle state.
-- @return function state
function LifeCycle:GetState()
    return self:GetPrivateField("state")
end

function _M.GetAllStates()
    return State
end

function _M.GetClass()
    return LifeCycle
end

return _M