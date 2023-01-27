--- SaveRestore system for the Logging environment.
-- @script EnvSaveRestore.lua
-- @license Apache License 2.0
-- @copyright GrayWolf64
local RegisterLoggerContext = Log4g.Core.LoggerContext.RegisterLoggerContext
local RegisterLoggerConfig = Log4g.Core.Config.LoggerConfig.RegisterLoggerConfig
local GetAllLoggerConfigs = Log4g.Core.Config.LoggerConfig.GetAll
local IsStarted = Log4g.Core.LifeCycle.IsStarted
local GetCustomLevel = Log4g.Level.GetCustomLevel
local RegisterCustomLevel = Log4g.Level.RegisterCustomLevel
local LoggerContextSaveFile = "log4g/server/saverestore_loggercontext.json"
local UnstartedLoggerConfigSaveFile = "log4g/server/saverestore_loggerconfig_unstarted.json"
local StartedLoggerConfigSaveFile = "log4g/server/saverestore_loggerconfig_started.json"
local CustomLevelSaveFile = "log4g/server/saverestore_customlevel.json"

--- Save all the LoggerContexts' names into a JSON file.
-- @lfunction SaveLoggerContext
local function SaveLoggerContext()
    local manager = Log4g.LogManager
    if table.IsEmpty(manager) then return end
    local result = {}

    for k, _ in pairs(manager) do
        table.insert(result, k)
    end

    file.Write(LoggerContextSaveFile, util.TableToJSON(result, true))
end

--- Save all the Unstarted LoggerConfigs' names and associated LoggerContexts' names into a JSON file.
-- @lfunction SaveUnstartedLoggerConfig
local function SaveUnstartedLoggerConfig()
    local configs = GetAllLoggerConfigs()
    if table.IsEmpty(configs) then return end
    local result = {}

    for k, v in pairs(configs) do
        if not IsStarted(v) then
            table.insert(result, {
                name = k,
                loggercontext = v.loggercontext
            })
        end
    end

    file.Write(UnstartedLoggerConfigSaveFile, util.TableToJSON(result, true))
end

--- Save all the built LoggerConfigs' names and associated LoggerContexts' names into a JSON file.
-- @lfunction SaveBuiltLoggerConfig
local function SaveBuiltLoggerConfig()
    local manager = Log4g.LogManager
    if table.IsEmpty(manager) then return end
    local result = {}

    for k, v in pairs(manager) do
        if table.IsEmpty(v.logger) then return end

        for i, _ in pairs(v.logger) do
            table.insert(result, {
                name = i,
                loggercontext = k
            })
        end
    end

    file.Write(StartedLoggerConfigSaveFile, util.TableToJSON(result, true))
end

--- Save all the previously registered Custom Levels.
-- @lfunction SaveCustomLevel
local function SaveCustomLevel()
    local customlevel = GetCustomLevel()
    if table.IsEmpty(customlevel) then return end
    local result = {}

    for k, v in pairs(customlevel) do
        table.insert(result, {
            name = k,
            int = v.int
        })
    end

    file.Write(CustomLevelSaveFile, util.TableToJSON(result, true))
end

local function Save()
    SaveLoggerContext()
    SaveUnstartedLoggerConfig()
    SaveBuiltLoggerConfig()
    SaveCustomLevel()
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

--- Re-register all the previously unstarted LoggerConfigs.
-- @lfunction RestoreUnstartedLoggerConfig
local function RestoreUnstartedLoggerConfig()
    if not file.Exists(UnstartedLoggerConfigSaveFile, "DATA") then return end
    local tbl = util.JSONToTable(file.Read(UnstartedLoggerConfigSaveFile, "DATA"))

    for _, v in pairs(tbl) do
        local save = "log4g/server/loggercontext/" .. v.loggercontext .. "/loggerconfig/" .. v.name .. ".json"
        if not file.Exists(save, "DATA") then return end
        RegisterLoggerConfig(util.JSONToTable(file.Read(save, "DATA")))
    end

    file.Delete(UnstartedLoggerConfigSaveFile)
end

--- Rebuild all the LoggerConfigs that were previously built.
-- First re-register them according to the JSON file then perform BuildDefault method.
-- @lfunction RebuildLoggerConfig
local function RebuildLoggerConfig()
    if not file.Exists(StartedLoggerConfigSaveFile, "DATA") then return end
    local tbl = util.JSONToTable(file.Read(StartedLoggerConfigSaveFile, "DATA"))

    for _, v in pairs(tbl) do
        local save = "log4g/server/loggercontext/" .. v.loggercontext .. "/loggerconfig/" .. v.name .. ".json"
        if not file.Exists(save, "DATA") then return end
        RegisterLoggerConfig(util.JSONToTable(file.Read(save, "DATA")))
        GetAllLoggerConfigs()[v.name]:BuildDefault()
    end

    file.Delete(StartedLoggerConfigSaveFile)
end

--- Restore all the previously saved Custom Levels.
-- @lfunction RestoreCustomLevel
local function RestoreCustomLevel()
    if not file.Exists(CustomLevelSaveFile, "DATA") then return end
    local tbl = util.JSONToTable(file.Read(CustomLevelSaveFile, "DATA"))

    for _, v in pairs(tbl) do
        RegisterCustomLevel(v.name, v.int)
    end

    file.Delete(CustomLevelSaveFile)
end

local function Restore()
    RestoreLoggerContext()
    RestoreUnstartedLoggerConfig()
    RebuildLoggerConfig()
    RestoreCustomLevel()
end

hook.Add("PostGamemodeLoaded", "Log4g_RestoreLogEnvironment", Restore)