--- Automatic reconfiguration (SaveRestore) system for the Logging environment.
-- @script AutoReconfiguration
-- @license Apache License 2.0
-- @copyright GrayWolf64
sql.Query("CREATE TABLE IF NOT EXISTS Log4g_AutoReconfig(Name TEXT NOT NULL UNIQUE, Content TEXT NOT NULL UNIQUE)")
local CreateLoggerContext = Log4g.API.LoggerContextFactory.GetContext
local GetAllLoggerContexts = Log4g.Core.LoggerContext.GetAll
local RegisterLoggerConfig = Log4g.Core.Config.LoggerConfig.RegisterLoggerConfig
local GetAllLoggerConfigs = Log4g.Core.Config.LoggerConfig.GetAll
local IsStarted = Log4g.Core.LifeCycle.IsStarted
local GetCustomLevel = Log4g.Level.GetCustomLevel
local RegisterCustomLevel = Log4g.Level.RegisterCustomLevel
local SQLInsert = Log4g.Util.SQLInsert
local SQLQueryRow = Log4g.Util.SQLQueryRow
local SQLQueryValue = Log4g.Util.SQLQueryValue
local SQLDeleteRow = Log4g.Util.SQLDeleteRow

--- Save all the LoggerContexts' names into JSON and store it in SQL.
-- @lfunction SaveLoggerContext
local function SaveLoggerContext()
    local LoggerContexts = GetAllLoggerContexts()
    if table.IsEmpty(LoggerContexts) then return end
    local result = {}

    for k, _ in pairs(LoggerContexts) do
        table.insert(result, k)
    end

    SQLInsert("Log4g_AutoReconfig", "LoggerContext", util.TableToJSON(result, true))
end

--- Save all the LoggerConfigs' names and associated LoggerContexts' names into a JSON file.
-- @lfunction SaveLoggerConfig
local function SaveLoggerConfig()
    local configs = GetAllLoggerConfigs()
    if table.IsEmpty(configs) then return end
    local result = {}

    for k, v in pairs(configs) do
        if not IsStarted(v) then
            table.insert(result, {
                name = k,
                loggercontext = v.loggercontext,
            })
        end
    end

    SQLInsert("Log4g_AutoReconfig", "LoggerConfig", util.TableToJSON(result, true))
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
            int = v.int,
        })
    end

    SQLInsert("Log4g_AutoReconfig", "CustomLevel", util.TableToJSON(result, true))
end

local function Save()
    SaveLoggerContext()
    SaveLoggerConfig()
    SaveCustomLevel()
end

hook.Add("ShutDown", "Log4g_SaveLogEnvironment", Save)

--- Restore all the LoggerContexts using previously stored names.
-- Their timestarted will be the time when they were restored.
-- @lfunction RestoreLoggerContext
local function RestoreLoggerContext()
    if not SQLQueryRow("Log4g_AutoReconfig", "LoggerContext") then return end
    local tbl = util.JSONToTable(SQLQueryValue("Log4g_AutoReconfig", "LoggerContext"))

    for _, v in pairs(tbl) do
        CreateLoggerContext(v)
    end

    SQLDeleteRow("Log4g_AutoReconfig", "LoggerContext")
end

--- Re-register all the LoggerConfigs.
-- @lfunction RestoreLoggerConfig
local function RestoreLoggerConfig()
    if not SQLQueryRow("Log4g_AutoReconfig", "LoggerConfig") then return end
    local tbl = util.JSONToTable(SQLQueryValue("Log4g_AutoReconfig", "LoggerConfig"))

    for _, v in pairs(tbl) do
        local config = SQLQueryValue("Log4g_LoggerConfig", v.name)
        if not config then return end
        RegisterLoggerConfig(util.JSONToTable(config))
    end

    SQLDeleteRow("Log4g_AutoReconfig", "LoggerConfig")
end

--- Restore all the previously saved Custom Levels.
-- @lfunction RestoreCustomLevel
local function RestoreCustomLevel()
    if not SQLQueryRow("Log4g_AutoReconfig", "CustomLevel") then return end
    local tbl = util.JSONToTable(SQLQueryValue("Log4g_AutoReconfig", "CustomLevel"))

    for _, v in pairs(tbl) do
        RegisterCustomLevel(v.name, v.int)
    end

    SQLDeleteRow("Log4g_AutoReconfig", "CustomLevel")
end

local function Restore()
    RestoreLoggerContext()
    RestoreLoggerConfig()
    RestoreCustomLevel()
end

hook.Add("PostGamemodeLoaded", "Log4g_RestoreLogEnvironment", Restore)