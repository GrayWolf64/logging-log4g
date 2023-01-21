--- The Logger.
-- @classmod Logger
Log4g.Logger = Log4g.Logger or {}
local Class = include("log4g/core/impl/MiddleClass.lua")
local Logger = Class("Logger")
local HasKey = Log4g.Util.HasKey
local SetState = Log4g.Core.LifeCycle.SetState
local INITIALIZING = Log4g.Core.LifeCycle.State.INITIALIZING
local INITIALIZED = Log4g.Core.LifeCycle.State.INITIALIZED
local STARTING = Log4g.Core.LifeCycle.State.STARTING
local STARTED = Log4g.Core.LifeCycle.State.STARTED
local STOPPING = Log4g.Core.LifeCycle.State.STOPPING
local STOPPED = Log4g.Core.LifeCycle.State.STOPPED

function Logger:Initialize(tbl)
    SetState(self, INITIALIZING)
    self.name = tbl.name
    self.loggerconfig = tbl
    self.file = "log4g/server/loggercontext/" .. tbl.loggercontext .. "/logger/" .. tbl.name .. ".json"
    SetState(self, INITIALIZED)
end

function Logger:Start()
    SetState(self, STARTING)
    SetState(self, STARTED)
end

--- Delete the Logger.
function Logger:Delete()
    SetState(self, STOPPING)
    SetState(self, STOPPED)
    Log4g.Hierarchy[self.loggerconfig.loggercontext].logger[self.name] = nil
end

--- Get the Logger name.
-- @return string name
function Logger:GetName()
    return self.name
end

--- Get the Level associated with the Logger.
-- @return object level
function Logger:GetLevel()
    return self.loggerconfig.level
end

local function HasLogger(name)
    if not isstring(name) then
        error("HasLogger search failed: name must be a string.\n")
    end

    for _, v in pairs(Log4g.Hierarchy) do
        if HasKey(v.logger, name) then return true end
    end

    return false
end

--- Register a Logger.
-- If the Logger with the same name already exists, its loggerconfig will be overrode.
-- @param loggerconfig The Loggerconfig
-- @return object logger
function Log4g.Logger.RegisterLogger(loggerconfig)
    if not istable(loggerconfig) or table.IsEmpty(loggerconfig) then
        error("Logger registration failed: LoggerConfig object invalid.\n")
    end

    MsgN("Starting the registration of Logger: " .. loggerconfig.name .. "...")

    if not HasLogger(loggerconfig.name) then
        local logger = Logger:New(loggerconfig)
        Log4g.Hierarchy[loggerconfig.loggercontext].logger[loggerconfig.name] = logger
        Log4g.Hierarchy[loggerconfig.loggercontext].logger[loggerconfig.name]:Start()
        hook.Add(loggerconfig.eventname, loggerconfig.uid, CompileString(loggerconfig.func))
        MsgN("Logger registration: Successfully created Hierarchy LoggerContext child item.")

        return Log4g.Hierarchy[loggerconfig.loggercontext].logger[loggerconfig.name]
    else
        ErrorNoHalt("Logger registration failed: Logger already exists.\n")

        return Log4g.Hierarchy[loggerconfig.loggercontext].logger[loggerconfig.name]
    end
end