--- The Logger.
-- @classmod Logger
local Class = include("log4g/core/impl/MiddleClass.lua")
local Logger = Class("Logger")
local SetState = Log4g.Core.LifeCycle.SetState
local INITIALIZING, INITIALIZED = Log4g.Core.LifeCycle.State.INITIALIZING, Log4g.Core.LifeCycle.State.INITIALIZED
local STARTING, STARTED = Log4g.Core.LifeCycle.State.STARTING, Log4g.Core.LifeCycle.State.STARTED
local STOPPING, STOPPED = Log4g.Core.LifeCycle.State.STOPPING, Log4g.Core.LifeCycle.State.STOPPED
local HasKey = Log4g.Util.HasKey

function Logger:Initialize(name)
	SetState(self, INITIALIZING)
	self.name = name
	SetState(self, INITIALIZED)
end

--- Start the Logger with a LoggerConfig.
function Logger:Start(loggerconfig)
	SetState(self, STARTING)
	self.loggerconfig = loggerconfig.name
	SetState(self, STARTED)

	return self
end

--- Terminate the Logger.
function Logger:Terminate()
	SetState(self, STOPPING)
	SetState(self, STOPPED)
	self = nil
end

--- Get the Logger name.
-- @return string name
function Logger:GetName()
	return self.name
end

--- Get the LoggerConfig name of the Logger.
-- @return string loggerconfig
function Logger:GetLoggerConfig()
	if not HasKey(self, "loggerconfig") then
		return
	end

	return self.loggerconfig
end

--- This is where all the Loggers are stored.
-- @local
-- @table INSTANCES
local INSTANCES = INSTANCES or {}

--- Get all the Loggers.
-- @return table instances
function Log4g.Core.Logger.GetAll()
	return INSTANCES
end

--- Create a Logger.
-- `Log4g_PreLoggerRegistration` will be called before the registration.
-- `Log4g_PostLoggerRegistration` will be called after the registration succeeds.
-- If the Logger with the same name already exists, `Log4g_OnLoggerRegistrationFailure` will be called.
-- @param loggerconfig The Loggerconfig
-- @return object logger
function Log4g.Core.Logger.Register(name, loggerconfig)
	if not isstring(name) or not istable(loggerconfig) or table.IsEmpty(loggerconfig) then
		return
	end

	if not HasKey(INSTANCES, name) then
		local logger = Logger:New(name):Start(loggerconfig)
		INSTANCES[name] = logger
		hook.Run("Log4g_PostLoggerRegistration", name)

		return logger
	else
		hook.Run("Log4g_OnLoggerRegistrationFailure", name)

		return INSTANCES[name]
	end
end
