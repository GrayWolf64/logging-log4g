--- In Log4g, the main interface for handling the life cycle context of an object is this one.
-- An object first starts in the LifeCycle.State.INITIALIZED state by default to indicate the class has been loaded.
-- From here, calling the `Start()` method will change this state to LifeCycle.State.STARTING.
-- After successfully being started, this state is changed to LifeCycle.State.STARTED.
-- When the `Stop()` is called, this goes into the LifeCycle.State.STOPPING state.
-- After successfully being stopped, this goes into the LifeCycle.State.STOPPED state.
-- In most circumstances, implementation classes should store their LifeCycle.State in a volatile field dependent on synchronization and concurrency requirements.
-- @script LifeCycle
-- @license Apache License 2.0
-- @copyright GrayWolf64
Log4g.Core.LifeCycle = Log4g.Core.LifeCycle or {}
local LifeCycle = include("log4g/core/impl/MiddleClass.lua")("LifeCycle")
local tableHasValue = table.HasValue
local isfunction = isfunction

local PRIVATE = PRIVATE or setmetatable({}, {
    __mode = "k"
})

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
    INITIALIZING = function() return "INITIALIZING" end,
    INITIALIZED = function() return "INITIALIZED" end,
    STARTING = function() return "STARTING" end,
    STARTED = function() return "STARTED" end,
    STOPPING = function() return "STOPPING" end,
    STOPPED = function() return "STOPPED" end,
}

--- Sets the LifeCycle state.
-- @param state A function in the `State` table which returns a string representing the state
function LifeCycle:SetState(state)
    if not isfunction(state) or not tableHasValue(State, state) then return end
    PRIVATE[self] = state
end

function LifeCycle:Initialize()
    self:SetState(State.INITIALIZED)
end

function LifeCycle:Start()
    self:SetState(State.STARTED)
end

--- Gets the LifeCycle state.
-- @return function state
function LifeCycle:GetState()
    return PRIVATE[self]
end

function Log4g.Core.LifeCycle.GetAll()
    return State
end

function Log4g.Core.LifeCycle.Class()
    return LifeCycle
end