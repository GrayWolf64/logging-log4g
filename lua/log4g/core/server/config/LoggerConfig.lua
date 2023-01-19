--- The LoggerConfig.
-- @classmod LoggerConfig
Log4g.Core.Config = Log4g.Core.Config or {}
Log4g.Core.Config.Builder = Log4g.Core.Config.Builder or {}
Log4g.Core.Config.LoggerConfig = Log4g.Core.Config.LoggerConfig or {}
Log4g.Core.Config.LoggerConfig.Buffer = Log4g.Core.Config.LoggerConfig.Buffer or {}
local Class = include("log4g/core/impl/MiddleClass.lua")
local Stateful = include("log4g/core/impl/Stateful.lua")
local LoggerConfig = Class("LoggerConfig")
LoggerConfig:include(Stateful)
local HasKey = Log4g.Util.HasKey

function LoggerConfig:Initialize(tbl)
    self.name = tbl.name
    self.eventname = tbl.eventname
    self.uid = tbl.uid
    self.loggercontext = tbl.loggercontext
    self.level = tbl.level
    self.appender = tbl.appender
    self.layout = tbl.layout
    self.file = "log4g/server/loggercontext/" .. tbl.loggercontext .. "/loggerconfig/" .. tbl.name .. ".json"
    self.func = tbl.func
end

--- Remove the LoggerConfig.
function LoggerConfig:Remove()
    local File = "log4g/server/loggercontext/" .. self.loggercontext .. "/loggerconfig/" .. self.name .. ".json"

    if file.Exists(File, "DATA") then
        file.Delete(File)
        MsgN("LoggerConfig deletion: Successfully deleted LoggerConfig file.")
    else
        ErrorNoHalt("LoggerConfig deletion failed: Can't find the LoggerConfig file.\n")
    end

    if HasKey(Log4g.Core.Config.LoggerConfig.Buffer, self.name) then
        Log4g.Core.Config.LoggerConfig.Buffer[self.name] = nil
        MsgN("LoggerConfig deletion: Successfully removed LoggerConfig from Buffer.")
    else
        ErrorNoHalt("LoggerConfig deletion failed: Can't find the LoggerConfig in Buffer, may be removed already.\n")
    end
end

local STARTED = LoggerConfig:AddState("STARTED")

function STARTED:Remove()
    ErrorNoHalt("LoggerConfig deletion failed: The LoggerConfig is already started and applied to a Logger.\n")
end

function Log4g.Core.Config.LoggerConfig.RegisterLoggerConfig(tbl)
    if not HasKey(Log4g.Core.Config.LoggerConfig.Buffer, tbl.name) then
        local loggerconfig = LoggerConfig:New(tbl)
        Log4g.Core.Config.LoggerConfig.Buffer[tbl.name] = loggerconfig
        file.Write(loggerconfig.file, util.TableToJSON(tbl, true))
        MsgN("LoggerConfig registration: Successfully created file and Buffer item.")

        return loggerconfig
    else
        ErrorNoHalt("LoggerConfig registration failed: A LoggerConfig with the same name already exists.\n")

        return Log4g.Core.Config.LoggerConfig.Buffer[tbl.name]
    end
end