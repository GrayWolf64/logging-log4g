--- The LoggerConfig.
-- @classmod LoggerConfig
Log4g.Core.Config = Log4g.Core.Config or {}
Log4g.Core.Config.Builder = Log4g.Core.Config.Builder or {}
Log4g.Core.Config.LoggerConfig = Log4g.Core.Config.LoggerConfig or {}
local HasKey = Log4g.Util.HasKey
local Class = include("log4g/core/impl/MiddleClass.lua")
local LoggerConfig = Class("LoggerConfig")
local SetState = Log4g.Core.LifeCycle.SetState
local IsStarted = Log4g.Core.LifeCycle.IsStarted
local INITIALIZING, INITIALIZED = Log4g.Core.LifeCycle.State.INITIALIZING, Log4g.Core.LifeCycle.State.INITIALIZED
local STARTING, STARTED = Log4g.Core.LifeCycle.State.STARTING, Log4g.Core.LifeCycle.State.STARTED
local STOPPING, STOPPED = Log4g.Core.LifeCycle.State.STOPPING, Log4g.Core.LifeCycle.State.STOPPED
local AddLoggerLookupItem = Log4g.Core.Logger.Lookup.AddItem
local GetLogger = Log4g.Core.Logger.Register
local GetLevel = Log4g.Level.GetLevel
local GetLayout = Log4g.Core.Layout.GetLayout
local GetAppender = Log4g.Core.Appender.GetAppender

function LoggerConfig:Initialize(tbl)
    SetState(self, INITIALIZING)
    self.name = tbl.name
    self.eventname = tbl.eventname
    self.uid = tbl.uid
    self.loggercontext = tbl.loggercontext
    self.level = tbl.level
    self.appender = tbl.appender
    self.layout = tbl.layout
    self.file = "log4g/server/loggercontext/" .. tbl.loggercontext .. "/loggerconfig/" .. tbl.name .. ".json"
    self.logmsg = tbl.logmsg
    self.callback = tbl.callback
    SetState(self, INITIALIZED)
end

--- Remove the LoggerConfig.
function LoggerConfig:Remove()
    SetState(self, STOPPING)
    SetState(self, STOPPED)
    self = nil
end

--- Remove the LoggerConfig JSON from local storge.
-- `Log4g_PreLoggerConfigFileDeletion` will be called first.
-- This will check if the file exists. When not, `Log4g_OnLoggerConfigFileDeletionFailure` will be called.
-- If file is successfully deleted and the LoggerConfig's file is set to nil, `Log4g_PostLoggerConfigFileDeletion` will be called.
-- @return object self
function LoggerConfig:RemoveFile()
    hook.Run("Log4g_PreLoggerConfigFileDeletion", self.name)

    if file.Exists(self.file, "DATA") then
        file.Delete(self.file)
        self.file = nil
        hook.Run("Log4g_PostLoggerConfigFileDeletion")
    else
        hook.Run("Log4g_OnLoggerConfigFileDeletionFailure")
    end

    return self
end

--- All the LoggerConfigs will be stored here.
-- @local
-- @table INSTANCES
local INSTANCES = INSTANCES or {}

--- Get all the LoggerConfigs in the LoggerConfigs table.
-- @return table instances
function Log4g.Core.Config.LoggerConfig.GetAll()
    return INSTANCES
end

--- Start the default building procedure for the LoggerConfig.
-- It will first set the LoggerConfig's LifeCycle to STARTING.
-- Then a Logger based on the LoggerConfig will be registered.
-- At last the registered Logger's LoggerConfig's state will be set to STARTED, and the procedure has completed.
-- If the LoggerConfig is already started, it will simply return end.
-- `Log4g_PreLoggerConfigBuild` will be called first after the check.
-- `Log4g_PostLoggerConfigBuild` will be called after the build.
function LoggerConfig:BuildDefault()
    if IsStarted(self) then return end
    hook.Run("Log4g_PreLoggerConfigBuild", self.name)
    SetState(self, STARTING)
    local logger = GetLogger(self)
    AddLoggerLookupItem(self.name, self.loggercontext, self.file)

    function logger.loggerconfig:BuildDefault()
        return
    end

    self:Remove()
    SetState(logger.loggerconfig, STARTED)
    hook.Run("Log4g_PostLoggerConfigBuild")
end

--- Register a LoggerConfig.
-- `Log4g_PreLoggerConfigRegistration` will be called before registering.
-- `Log4g_PostLoggerConfigRegistration` will be called afer registration succeeds.
-- `Log4g_OnLoggerConfigRegistrationFailure` will be called when registration fails(the LoggerConfig with the same name already exists).
-- @param tbl The table containing data that a LoggerConfig needs
-- @return object loggerconfig
function Log4g.Core.Config.LoggerConfig.RegisterLoggerConfig(tbl)
    hook.Run("Log4g_PreLoggerConfigRegistration", tbl.name)

    if not HasKey(INSTANCES, tbl.name) then
        local strlevel = tbl.level
        local strlayout = tbl.layout
        local strappender = tbl.appender
        tbl.level = GetLevel(strlevel)
        tbl.layout = GetLayout(strlayout)
        tbl.appender = GetAppender(strappender)
        local loggerconfig = LoggerConfig:New(tbl)
        INSTANCES[tbl.name] = loggerconfig
        tbl.level = strlevel
        tbl.layout = strlayout
        tbl.appender = strappender
        file.Write(loggerconfig.file, util.TableToJSON(tbl, true))
        hook.Run("Log4g_PostLoggerConfigRegistration")

        return INSTANCES[tbl.name]
    else
        hook.Run("Log4g_OnLoggerConfigRegistrationFailure")

        return INSTANCES[tbl.name]
    end
end

--- Get all the file paths of the all the LoggerConfigs in the form of a string table.
-- If the LoggerConfig table is empty, nil will be the return value.
-- @return tbl filepaths
function Log4g.Core.Config.LoggerConfig.GetFiles()
    if not table.IsEmpty(INSTANCES) then
        local tbl = {}

        for _, v in pairs(INSTANCES) do
            if not IsStarted(v) then
                table.insert(tbl, v.file)
            end
        end

        return tbl
    else
        return nil
    end
end