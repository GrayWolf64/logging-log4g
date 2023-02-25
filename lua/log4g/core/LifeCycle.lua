--- In Log4j, the main interface for handling the life cycle context of an object is this one.
-- An object first starts in the LifeCycle.State.INITIALIZED state by default to indicate the class has been loaded.
-- From here, calling the start() method will change this state to LifeCycle.State.STARTING.
-- After successfully being started, this state is changed to LifeCycle.State.STARTED.
-- When the stop() is called, this goes into the LifeCycle.State.STOPPING state.
-- After successfully being stopped, this goes into the LifeCycle.State.STOPPED state.
-- In most circumstances, implementation classes should store their LifeCycle.State in a volatile field or inside an AtomicReference dependent on synchronization and concurrency requirements.
-- @script LifeCycle
-- @license Apache License 2.0
-- @copyright GrayWolf64
Log4g.Core.LifeCycle = Log4g.Core.LifeCycle or {}
local Class = include("log4g/core/impl/MiddleClass.lua")
local LifeCycle = Class("LifeCycle")

local PRIVATE = PRIVATE or setmetatable({}, {
    __mode = "k"
})

--- LifeCycle states.
-- @table States
-- @local
-- @field INITIALIZING Object is in its initial state and not yet initialized.
-- @field INITIALIZED Initialized but not yet started.
-- @field STARTING In the process of starting.
-- @field STARTED Has started.
-- @field STOPPING Stopping is in progress.
-- @field STOPPED Has stopped.
local States = {
    INITIALIZING = function() return "INITIALIZING" end,
    INITIALIZED = function() return "INITIALIZED" end,
    STARTING = function() return "STARTING" end,
    STARTED = function() return "STARTED" end,
    STOPPING = function() return "STOPPING" end,
    STOPPED = function() return "STOPPED" end,
}

--- Sets the LifeCycle state.
-- @param state A function in the `States` table which returns a string representing the state
function LifeCycle:SetState(state)
    if not isfunction(state) or not table.HasValue(States, state) then return end
    PRIVATE[self] = state
end

function LifeCycle:Initialize()
    self:SetState(States.INITIALIZED)
end

function LifeCycle:Start()
    self:SetState(States.STARTED)
end

--- Gets the LifeCycle state.
-- @return function state
function LifeCycle:GetState()
    return PRIVATE[self]
end

function Log4g.Core.LifeCycle.GetAll()
    return States
end

function Log4g.Core.LifeCycle.Class()
    return LifeCycle
end