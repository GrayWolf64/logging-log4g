--- The LoggerConfig.
-- @classmod LoggerConfig
Log4g.Core.Config = Log4g.Core.Config or {}
Log4g.Core.Config.Builder = Log4g.Core.Config.Builder or {}
Log4g.Core.Config.LoggerConfig = Log4g.Core.Config.LoggerConfig or {}
Log4g.Core.Config.LoggerConfig.Buffer = Log4g.Core.Config.LoggerConfig.Buffer or {}
local HasKey = Log4g.Util.HasKey
local Class = include("log4g/core/impl/MiddleClass.lua")
local Stateful = include("log4g/core/impl/Stateful.lua")
local LoggerConfig = Class("LoggerConfig")
LoggerConfig:include(Stateful)

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

local INITIALIZED = LoggerConfig:addState("INITIALIZED")
local STARTED = LoggerConfig:addState("STARTED")

--- Remove the LoggerConfig.
function INITIALIZED:Remove()
    MsgN("Starting the removal of LoggerConfig: " .. self.name .. "...")
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

    MsgN("Removal completed.")
end

function INITIALIZED:BuildDefault()
    Log4g.Logger.RegisterLogger(self)
    Log4g.Hierarchy[self.loggercontext].logger[self.name].loggerconfig:gotoState("STARTED")
    hook.Add(self.eventname, self.uid, CompileString(self.func))
    self:gotoState("INITIALIZED")
    self:Remove()
end

function STARTED:Remove()
    ErrorNoHalt("LoggerConfig deletion failed: The LoggerConfig is already started.\n")
end

function STARTED:BuildDefault()
    ErrorNoHalt("LoggerConfig default build failed: The LoggerConfig is already started and built.\n")
end

--- Register a LoggerConfig.
-- If the LoggerConfig with the same name already exists, an error will be thrown without halt.
-- @param tbl The table containing data that a LoggerConfig needs
-- @return object loggerconfig
function Log4g.Core.Config.LoggerConfig.RegisterLoggerConfig(tbl)
    MsgN("Starting the registration of LoggerConfig: " .. tbl.name .. "...")

    if not HasKey(Log4g.Core.Config.LoggerConfig.Buffer, tbl.name) then
        local loggerconfig = LoggerConfig:New(tbl)
        Log4g.Core.Config.LoggerConfig.Buffer[tbl.name] = loggerconfig
        file.Write(loggerconfig.file, util.TableToJSON(tbl, true))
        Log4g.Core.Config.LoggerConfig.Buffer[tbl.name]:gotoState("INITIALIZED")
        MsgN("LoggerConfig registration: Successfully created file and Buffer item.")

        return Log4g.Core.Config.LoggerConfig.Buffer[tbl.name]
    else
        ErrorNoHalt("LoggerConfig registration failed: A LoggerConfig with the same name already exists.\n")

        return Log4g.Core.Config.LoggerConfig.Buffer[tbl.name]
    end
end

--- Get all the files of the LoggerConfigs in Buffer in the form of a string table.
-- If the Hierarchy or LoggerConfig Buffer table is empty, an error will be thrown.
-- @return tbl stringfiles
function Log4g.Core.Config.LoggerConfig.GetFiles()
    if not table.IsEmpty(Log4g.Hierarchy) then
        if not table.IsEmpty(Log4g.Core.Config.LoggerConfig.Buffer) then
            local tbl = {}

            for k, _ in pairs(Log4g.Hierarchy) do
                for i, _ in pairs(Log4g.Core.Config.LoggerConfig.Buffer) do
                    table.insert(tbl, "log4g/server/loggercontext/" .. k .. "/loggerconfig/" .. i .. ".json")
                end
            end

            return tbl
        else
            ErrorNoHalt("Get LoggerConfig files failed: No LoggerConfig available in Buffer.\n")
        end
    else
        ErrorNoHalt("Get LoggerConfig files failed: No LoggerContext available in Hierarchy.\n")
    end
end