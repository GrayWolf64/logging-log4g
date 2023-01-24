--- SaveRestore system for the Logging environment.
-- @script LogSaveRestore.lua
-- @license Apache License 2.0
-- @copyright GrayWolf64
local RegisterLoggerContext = Log4g.Core.LoggerContext.RegisterLoggerContext
local RegisterLoggerConfig = Log4g.Core.Config.LoggerConfig.RegisterLoggerConfig
local LoggerContextSaveFile = "log4g/server/saverestore_loggercontext.json"
local BufferedLoggerConfigSaveFile = "log4g/server/saverestore_loggerconfig_buffered.json"
local BuiltLoggerConfigSaveFile = "log4g/server/saverestore_loggerconfig_built.json"

--- Save all the LoggerContexts' names into a JSON file.
-- @lfunction SaveLoggerContext
local function SaveLoggerContext()
    if table.IsEmpty(Log4g.LogManager) then return end
    local result = {}

    for k, _ in pairs(Log4g.LogManager) do
        table.insert(result, k)
    end

    file.Write(LoggerContextSaveFile, util.TableToJSON(result, true))
end

--- Save all the Buffered LoggerConfigs' names and associated LoggerContexts' names into a JSON file.
-- @lfunction SaveBufferedLoggerConfig
local function SaveBufferedLoggerConfig()
    if table.IsEmpty(Log4g.Core.Config.LoggerConfig.Buffer) then return end
    local result = {}

    for k, v in pairs(Log4g.Core.Config.LoggerConfig.Buffer) do
        table.insert(result, {
            name = k,
            loggercontext = v.loggercontext
        })
    end

    file.Write(BufferedLoggerConfigSaveFile, util.TableToJSON(result, true))
end

--- Save all the built LoggerConfigs' names and associated LoggerContexts' names into a JSON file.
-- @lfunction SaveBuiltLoggerConfig
local function SaveBuiltLoggerConfig()
    if table.IsEmpty(Log4g.LogManager) then return end
    local result = {}

    for k, v in pairs(Log4g.LogManager) do
        if table.IsEmpty(v.logger) then return end

        for i, _ in pairs(v.logger) do
            table.insert(result, {
                name = i,
                loggercontext = k
            })
        end
    end

    file.Write(BuiltLoggerConfigSaveFile, util.TableToJSON(result, true))
end

local function Save()
    SaveLoggerContext()
    SaveBufferedLoggerConfig()
    SaveBuiltLoggerConfig()
end

hook.Add("ShutDown", "Log4g_SaveLogEnvironment", Save)

--- Restore all the LoggerContexts using previously stored names.
-- Their timestarted will be the time when they were restored.
-- @lfunction RestoreLoggerContext
local function RestoreLoggerContext()
    if not file.Exists(LoggerContextSaveFile, "DATA") then return end
    local tbl = util.JSONToTable(file.Read(LoggerContextSaveFile, "DATA"))

    for _, v in pairs(tbl) do
        RegisterLoggerContext(v)
    end

    file.Delete(LoggerContextSaveFile)
end

--- Re-register all the previously buffered LoggerConfigs.
-- @lfunction RestoreBufferedLoggerConfig
local function RestoreBufferedLoggerConfig()
    if not file.Exists(BufferedLoggerConfigSaveFile, "DATA") then return end
    local tbl = util.JSONToTable(file.Read(BufferedLoggerConfigSaveFile, "DATA"))

    for _, v in pairs(tbl) do
        RegisterLoggerConfig(util.JSONToTable(file.Read("log4g/server/loggercontext/" .. v.loggercontext .. "/loggerconfig/" .. v.name .. ".json", "DATA")))
    end

    file.Delete(BufferedLoggerConfigSaveFile)
end

--- Rebuild all the LoggerConfigs that were previously built.
-- First re-register them according to the JSON file then perform BuildDefault method.
-- @lfunction RebuildLoggerConfig
local function RebuildLoggerConfig()
    if not file.Exists(BuiltLoggerConfigSaveFile, "DATA") then return end
    local tbl = util.JSONToTable(file.Read(BuiltLoggerConfigSaveFile, "DATA"))

    for _, v in pairs(tbl) do
        RegisterLoggerConfig(util.JSONToTable(file.Read("log4g/server/loggercontext/" .. v.loggercontext .. "/loggerconfig/" .. v.name .. ".json", "DATA")))
        Log4g.Core.Config.LoggerConfig.Buffer[v.name]:BuildDefault()
    end

    file.Delete(BuiltLoggerConfigSaveFile)
end

local function Restore()
    RestoreLoggerContext()
    RestoreBufferedLoggerConfig()
    RebuildLoggerConfig()
end

hook.Add("PostGamemodeLoaded", "Log4g_RestoreLogEnvironment", Restore)