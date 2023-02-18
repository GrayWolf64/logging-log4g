--- The LoggerContext.
-- @classmod LoggerContext
local Class = include("log4g/core/impl/MiddleClass.lua")
local LoggerContext = Class("LoggerContext")
local SetState = Log4g.Core.LifeCycle.SetState
local INITIALIZING, INITIALIZED = Log4g.Core.LifeCycle.State.INITIALIZING, Log4g.Core.LifeCycle.State.INITIALIZED
local STOPPING, STOPPED = Log4g.Core.LifeCycle.State.STOPPING, Log4g.Core.LifeCycle.State.STOPPED
local GetDefaultConfiguration = Log4g.Core.Config.GetDefaultConfiguration
--- This is where all the LoggerContexts are stored.
-- @local
-- @table INSTANCES
local INSTANCES = INSTANCES or {}

--- A weak table which stores some private attributes of the LoggerContext object.
-- @local
-- @table PRIVATE
local PRIVATE = PRIVATE or setmetatable({}, {
    __mode = "k"
})

function LoggerContext:Initialize(name)
    SetState(PRIVATE, INITIALIZING)
    self.name = name

    PRIVATE[self] = {
        logger = {}
    }

    SetState(PRIVATE, INITIALIZED)
end

--- Get the name of the LoggerContext.
-- @return string name
function LoggerContext:GetName()
    return self.name
end

--- Gets a table of the current loggers.
-- @return table loggers
function LoggerContext:GetLoggers()
    return PRIVATE[self].logger
end

--- Sets the Configuration to be used.
-- @param configuration Configuration
function LoggerContext:SetConfiguration(configuration)
    PRIVATE[self].configuration = configuration
end

--- Returns the current Configuration of the LoggerContext.
-- @return object configuration
function LoggerContext:GetConfiguration()
    return PRIVATE[self].configuration
end

function LoggerContext:__tostring()
    return "LoggerContext: [name:" .. self.name .. "]"
end

--- Terminate the LoggerContext.
function LoggerContext:Terminate()
    SetState(PRIVATE, STOPPING)
    PRIVATE[self] = nil
    SetState(PRIVATE, STOPPED)
    INSTANCES[self.name] = nil
end

function Log4g.Core.LoggerContext.GetAll()
    return INSTANCES
end

local GetCurrentFQSN = Log4g.Util.GetCurrentFQSN

--- Get the LoggerContext with the right name.
-- @param T A string or a function
-- @return object loggercontext
function Log4g.Core.LoggerContext.Get(T)
    if isstring(T) then
        if INSTANCES[T] then return INSTANCES[T] end
    elseif isfunction(T) then
        local fqsn = GetCurrentFQSN(T)
        if INSTANCES[fqsn] then return INSTANCES[fqsn] end
    end
end

--- Register a LoggerContext.
-- This is used for APIs.
-- @param name The name of the LoggerContext
-- @return object loggercontext
function Log4g.Core.LoggerContext.Register(name)
    if INSTANCES[name] then return INSTANCES[name] end
    INSTANCES[name] = LoggerContext:New(name)
    INSTANCES[name]:SetConfiguration(GetDefaultConfiguration())

    return INSTANCES[name]
end