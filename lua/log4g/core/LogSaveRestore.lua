--- SaveRestore system for the Logging environment.
-- @script LogSaveRestore.lua
-- @license Apache License 2.0
-- @copyright GrayWolf64
local RegisterLoggerContext = Log4g.Core.LoggerContext.RegisterLoggerContext
local LoggerContextSaveFile = "log4g/server/saverestore_loggercontext.json"

--- Save all the LoggerContexts' names into a JSON file before server shutting down.
-- @lfunction SaveLoggerContext
local function SaveLoggerContext()
    if table.IsEmpty(Log4g.Hierarchy) then return end
    local tbl = {}

    for k, _ in pairs(Log4g.Hierarchy) do
        table.insert(tbl, k)
    end

    file.Write(LoggerContextSaveFile, util.TableToJSON(tbl, true))
end

local function Save()
    SaveLoggerContext()
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