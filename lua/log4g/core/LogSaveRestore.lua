local LoggerContextSaveFile = "log4g/server/saverestore_loggercontext.json"

local function SaveLoggerContext()
    if table.IsEmpty(Log4g.Hierarchy) then return end
    local tbl = {}

    for k, _ in pairs(Log4g.Hierarchy) do
        table.insert(tbl, k)
    end

    file.Write(LoggerContextSaveFile, util.TableToJSON(tbl, true))
end

local function SaveAll()
    SaveLoggerContext()
end

hook.Add("ShutDown", "Log4g_SaveLogEnvironment", SaveAll)

local function RestoreLoggerContext()
end

local function RestoreAll()
    RestoreLoggerContext()
end

hook.Add("PostGamemodeLoaded", "Log4g_RestoreLogEnvironment", RestoreAll)