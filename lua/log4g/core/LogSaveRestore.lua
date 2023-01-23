--- SaveRestore system for the Logging environment.
-- @script LogSaveRestore.lua
-- @license Apache License 2.0
-- @copyright GrayWolf64
local RegisterLoggerContext = Log4g.Core.LoggerContext.RegisterLoggerContext
local LoggerContextSaveFile = "log4g/server/saverestore_loggercontext.json"
local BufferedLoggerConfigSaveFile = "log4g/server/saverestore_loggerconfig_buffered.json"

local function SaveKey(tbl, file)
    if table.IsEmpty(tbl) then return end
    local result = {}

    for k, _ in pairs(tbl) do
        table.insert(result, k)
    end

    file.Write(file, util.TableToJSON(result, true))
end

--- Save all the LoggerContexts' names into a JSON file before server shutting down.
-- @lfunction SaveLoggerContext
local function SaveLoggerContext()
    SaveKey(Log4g.LogManager, LoggerContextSaveFile)
end

local function SaveBufferedLoggerConfig()
    SaveKey(Log4g.Core.Config.LoggerConfig.Buffer, BufferedLoggerConfigSaveFile)
end

local function Save()
    SaveLoggerContext()
    SaveBufferedLoggerConfig()
end

hook.Add("ShutDown", "Log4g_SaveLogEnvironment", Save)

--- Restore all the LoggerContexts using previously stored names.
-- @lfunction RestoreLoggerContext
local function RestoreLoggerContext()
    if not file.Exists(LoggerContextSaveFile, "DATA") then return end
    local tbl = util.JSONToTable(file.Read(LoggerContextSaveFile, "DATA"))

    for _, v in pairs(tbl) do
        RegisterLoggerContext(v)
    end

    file.Delete(LoggerContextSaveFile)
end

local function Restore()
    RestoreLoggerContext()
end

hook.Add("PostGamemodeLoaded", "Log4g_RestoreLogEnvironment", Restore)