--- The LoggerContext.
-- @classmod LoggerContext
local Class = include("log4g/core/impl/MiddleClass.lua")
local LoggerContext = Class("LoggerContext")
local HasKey = Log4g.Util.HasKey
local RemoveLoggerConfigByContext = Log4g.Core.Config.LoggerConfig.RemoveByContext
local SetState = Log4g.Core.LifeCycle.SetState
local INITIALIZING, INITIALIZED = Log4g.Core.LifeCycle.State.INITIALIZING, Log4g.Core.LifeCycle.State.INITIALIZED
local STOPPING, STOPPED = Log4g.Core.LifeCycle.State.STOPPING, Log4g.Core.LifeCycle.State.STOPPED
local RegisterConfiguration = Log4g.Core.Config.Configuration.Register
--- This is where all the LoggerContexts are stored.
-- LoggerContexts may include some Loggers which may also include Appender, Level objects and so on.
-- @local
-- @table INSTANCES
local INSTANCES = INSTANCES or {}

--- A weak table which stores some private attributes of the LoggerContext object.
-- @local
-- @table PRIVATE
local PRIVATE = setmetatable({}, {
    __mode = "k"
})

function LoggerContext:Initialize(name)
    SetState(self, INITIALIZING)
    self.name = name

    PRIVATE[self] = {
        configuration = RegisterConfiguration()
    }

    SetState(self, INITIALIZED)
end

--- Get the name of the LoggerContext.
-- @return string name
function LoggerContext:GetName()
    return self.name
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
    SetState(self, STOPPING)
    PRIVATE[self] = nil
    RemoveLoggerConfigByContext(self.name)
    SetState(self, STOPPED)
    hook.Run("Log4g_PostLoggerContextTermination")
    INSTANCES[self.name] = nil
end

function Log4g.Core.LoggerContext.GetAll()
    return INSTANCES
end

--- Get the LoggerContext with the right name.
-- @return object loggercontext
function Log4g.Core.LoggerContext.Get(name)
    if HasKey(INSTANCES, name) then return INSTANCES[name] end
end

--- Register a LoggerContext.
-- This is used for APIs.
-- If the LoggerContext with the same name already exists, `Log4g_OnLoggerContextRegistrationFailure` will be called.
-- @param name The name of the LoggerContext
-- @return object loggercontext
function Log4g.Core.LoggerContext.Register(name)
    if not HasKey(INSTANCES, name) then
        INSTANCES[name] = LoggerContext:New(name)
        hook.Run("Log4g_PostLoggerContextRegistration", name)

        return INSTANCES[name]
    else
        hook.Run("Log4g_OnLoggerContextRegistrationFailure")

        return INSTANCES[name]
    end
end