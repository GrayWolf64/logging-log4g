--- The LoggerConfig.
-- @classmod LoggerConfig
Log4g.Core.Config = Log4g.Core.Config or {}
Log4g.Core.Config.Builder = Log4g.Core.Config.Builder or {}
Log4g.Core.Config.LoggerConfig = Log4g.Core.Config.LoggerConfig or {}
Log4g.Core.Config.LoggerConfig.Buffer = Log4g.Core.Config.LoggerConfig.Buffer or {}
local HasKey = Log4g.Util.HasKey
local Class = include("log4g/core/impl/MiddleClass.lua")
local LoggerConfig = Class("LoggerConfig")

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

function LoggerConfig:BuildDefault()
end

--- Register a LoggerConfig.
-- If the LoggerConfig with the same name already exists, an error will be thrown without halt.
-- @param tbl The table containing data that a LoggerConfig needs
-- @return object loggerconfig
function Log4g.Core.Config.LoggerConfig.RegisterLoggerConfig(tbl)
    if not istable(tbl) or table.IsEmpty(tbl) then
        error("LoggerConfig registration failed: arg must be a not empty table.\n")
    end

    MsgN("Starting the registration of LoggerConfig: " .. tbl.name .. "...")

    if not HasKey(Log4g.Core.Config.LoggerConfig.Buffer, tbl.name) then
        local loggerconfig = LoggerConfig:New(tbl)
        Log4g.Core.Config.LoggerConfig.Buffer[tbl.name] = loggerconfig
        file.Write(loggerconfig.file, util.TableToJSON(tbl, true))
        MsgN("LoggerConfig registration: Successfully created file and Buffer item.")

        return Log4g.Core.Config.LoggerConfig.Buffer[tbl.name]
    else
        ErrorNoHalt("LoggerConfig registration failed: A LoggerConfig with the same name already exists.\n")

        return Log4g.Core.Config.LoggerConfig.Buffer[tbl.name]
    end
end

--- Get all the file paths of the LoggerConfigs in Buffer in the form of a string table.
-- If the LoggerConfig Buffer table is empty, an error will be thrown.
-- @return tbl filepaths
function Log4g.Core.Config.LoggerConfig.GetFiles()
    if not table.IsEmpty(Log4g.Core.Config.LoggerConfig.Buffer) then
        local tbl = {}

        for _, v in pairs(Log4g.Core.Config.LoggerConfig.Buffer) do
            table.insert(tbl, v.file)
        end

        return tbl
    else
        ErrorNoHalt("Get LoggerConfig files failed: No LoggerConfig available in Buffer.\n")
    end
end

--- Get all the file paths of all the not started LoggerConfig JSONs stored locally on server.
-- If no LoggerContext or no LoggerConfig can be found, an error will be thrown.
-- @return tbl filepaths
function Log4g.Core.Config.LoggerConfig.GetLocalFiles()
    local tbl = {}
    local _, folders = file.Find("log4g/server/loggercontext/*", "DATA")

    if not table.IsEmpty(folders) then
        for _, v in pairs(folders) do
            local files, _ = file.Find("log4g/server/loggercontext/" .. v .. "/loggerconfig/*.json", "DATA")
            if table.IsEmpty(files) then return end

            for _, j in pairs(files) do
                table.insert(tbl, "log4g/server/loggercontext/" .. v .. "/loggerconfig/" .. j)
            end
        end

        if not table.IsEmpty(tbl) then
            return tbl
        else
            MsgN("Get LoggerConfig local files failed: No LoggerConfig file available in data/log4g/server/loggercontext/.../loggerconfig/")

            return nil
        end
    else
        MsgN("Get LoggerConfig local files failed: No LoggerContext folder available in data/log4g/server/loggercontext/.")
    end
end