local RegisterLoggerContext = Log4g.Core.LoggerContext.RegisterLoggerContext
local LoggerContextSaveFile = "log4g/server/saverestore_loggercontext.json"

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