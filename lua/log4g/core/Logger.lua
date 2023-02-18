--- The Logger.
-- @classmod Logger
local Class = include("log4g/core/impl/MiddleClass.lua")
local Logger = Class("Logger")
local SetState = Log4g.Core.LifeCycle.SetState
local INITIALIZING, INITIALIZED = Log4g.Core.LifeCycle.State.INITIALIZING, Log4g.Core.LifeCycle.State.INITIALIZED
local STARTING, STARTED = Log4g.Core.LifeCycle.State.STARTING, Log4g.Core.LifeCycle.State.STARTED
local STOPPING, STOPPED = Log4g.Core.LifeCycle.State.STOPPING, Log4g.Core.LifeCycle.State.STOPPED
local RegisterLoggerConfig = Log4g.Core.Config.LoggerConfig.RegisterLoggerConfig
local GetLoggerConfig = Log4g.Core.Config.LoggerConfig.Get
local GetStandardIntLevel = Log4g.Level.GetStandardIntLevel

--- A weak table which stores some private attributes of the Logger object.
-- @local
-- @table PRIVATE
local PRIVATE = PRIVATE or setmetatable({}, {
    __mode = "k"
})

function Logger:Initialize(name)
    SetState(PRIVATE, INITIALIZING)
    self.name = name

    PRIVATE[self] = {
        loggerconfig = RegisterLoggerConfig(name)
    }

    SetState(PRIVATE, INITIALIZED)
end

--- Start the Logger.
function Logger:Start(loggerconfig)
    SetState(PRIVATE, STARTING)
    SetState(PRIVATE, STARTED)

    return self
end

--- Get the Logger name.
-- @return string name
function Logger:GetName()
    return self.name
end

--- Get the LoggerConfig name of the Logger.
-- @return string loggerconfig
function Logger:GetLoggerConfig()
    return GetLoggerConfig(self.name)
end

--- Set the Log Level for the Logger.
-- @param level The Level object.
function Logger:SetLevel(level)
    self.level = function()
        return level
    end
end

function Logger:ALL(arg)
    if self.level().int == math.huge then
        Msg(arg)
    end
end

function Logger:TRACE(arg)
    if self.level().int >= GetStandardIntLevel().TRACE then
        Msg(arg)
    end
end

function Logger:DEBUG(arg)
    if self.level().int >= GetStandardIntLevel().DEBUG then
        Msg(arg)
    end
end

function Logger:INFO(arg)
    if self.level().int >= GetStandardIntLevel().INFO then
        Msg(arg)
    end
end

function Logger:WARN(arg)
    if self.level().int >= GetStandardIntLevel().WARN then
        Msg(arg)
    end
end

function Logger:ERROR(arg)
    if self.level().int >= GetStandardIntLevel().ERROR then
        Msg(arg)
    end
end

function Logger:FATAL(arg)
    if self.level().int >= GetStandardIntLevel().FATAL then
        Msg(arg)
    end
end

--- Terminate the Logger.
function Logger:Terminate()
    SetState(PRIVATE, STOPPING)
    PRIVATE[self] = nil
    SetState(PRIVATE, STOPPED)
end

function Log4g.Core.Logger.Create(context, name)
    context:GetLoggers().name = Logger:New(name)
end