--- The LoggerConfig.
-- @classmod LoggerConfig
local HasKey                    = Log4g.Util.HasKey
local Class                     = include("log4g/core/impl/MiddleClass.lua")
local LoggerConfig              = Class("LoggerConfig")
local RemoveContextLookupConfig = Log4g.Core.LoggerContext.Lookup.RemoveConfig
local AddConfigLookupConfig     = Log4g.Core.Config.LoggerConfig.Lookup.AddConfig
local RemoveConfigLookupConfig  = Log4g.Core.Config.LoggerConfig.Lookup.RemoveConfig
local SetState                  = Log4g.Core.LifeCycle.SetState
local IsStarted                 = Log4g.Core.LifeCycle.IsStarted
local INITIALIZING,              INITIALIZED = Log4g.Core.LifeCycle.State.INITIALIZING, Log4g.Core.LifeCycle.State.INITIALIZED
local STOPPING,                  STOPPED     = Log4g.Core.LifeCycle.State.STOPPING,     Log4g.Core.LifeCycle.State.STOPPED

function LoggerConfig:Initialize(tbl)
    SetState(self, INITIALIZING)
    self.name          = tbl.name
    self.eventname     = tbl.eventname
    self.uid           = tbl.uid
    self.loggercontext = tbl.loggercontext
    self.level         = tbl.level
    self.appender      = tbl.appender
    self.layout        = tbl.layout
    self.file          = "log4g/server/loggercontext/" .. tbl.loggercontext .. "/loggerconfig/" .. tbl.name .. ".json"
    self.logmsg        = tbl.logmsg
    SetState(self, INITIALIZED)
end

function LoggerConfig:GetName()
    return self.name
end

function LoggerConfig:GetContext()
    return self.loggercontext
end

--- All the LoggerConfigs will be stored here.
-- @local
-- @table INSTANCES
local INSTANCES = INSTANCES or {}

--- Remove the LoggerConfig.
function LoggerConfig:Remove()
    SetState(self, STOPPING)
    RemoveContextLookupConfig(self:GetContext(), self:GetName())
    RemoveConfigLookupConfig(self:GetName())

    if file.Exists(self.file, "DATA") then
        file.Delete(self.file)
        self.file = nil
        hook.Run("Log4g_PostLoggerConfigFileDeletion")
    else
        hook.Run("Log4g_OnLoggerConfigFileDeletionFailure")
    end

    SetState(self, STOPPED)
    INSTANCES[self:GetName()] = nil
end

--- Get all the LoggerConfigs in the LoggerConfigs table.
-- @return table instances
function Log4g.Core.Config.LoggerConfig.GetAll()
    return INSTANCES
end

function Log4g.Core.Config.LoggerConfig.RemoveByContext(name)
    if table.IsEmpty(INSTANCES) then return end

    for k, v in pairs(INSTANCES) do
        if v:GetContext() == name then
            INSTANCES[k]:Remove()
        end
    end
end

--- Get the LoggerConfig with the right name.
-- @return object loggerconfig
function Log4g.Core.Config.LoggerConfig.Get(name)
    if not HasKey(INSTANCES, name) then return end

    return INSTANCES[name]
end

--- Register a LoggerConfig.
-- `Log4g_PreLoggerConfigRegistration` will be called before registering.
-- `Log4g_PostLoggerConfigRegistration` will be called afer registration succeeds.
-- `Log4g_OnLoggerConfigRegistrationFailure` will be called when registration fails(the LoggerConfig with the same name already exists).
-- @param tbl The table containing data that a LoggerConfig needs
-- @return object loggerconfig
function Log4g.Core.Config.LoggerConfig.RegisterLoggerConfig(tbl)
    if not HasKey(INSTANCES, tbl.name) then
        local loggerconfig = LoggerConfig:New(tbl)
        INSTANCES[tbl.name] = loggerconfig
        AddConfigLookupConfig(tbl.name)
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