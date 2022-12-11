local AddNetworkStrsViaTbl = Log4g.Util.AddNetworkStrsViaTbl
local FindFilesInSubFolders = Log4g.Util.FindFilesInSubFolders
local SendTableAfterRcvNetMsg = Log4g.Util.SendTableAfterRcvNetMsg
local HasKey = Log4g.Util.HasKey
local LoggerContextLookupFile = "log4g/server/loggercontext/loggercontext_lookup.json"

AddNetworkStrsViaTbl({
    [1] = "Log4g_CLUpload_LoggerConfig",
    [2] = "Log4g_CLReq_Hooks",
    [3] = "Log4g_CLRcv_Hooks",
    [4] = "Log4g_CLReq_LoggerConfigs",
    [5] = "Log4g_CLRcv_LoggerConfigs",
    [6] = "Log4g_CLReq_LoggerConfig_Remove",
    [7] = "Log4g_CLReq_LoggerContext_Lookup",
    [8] = "Log4g_CLRcv_LoggerContext_Lookup",
    [9] = "Log4g_CLReq_LoggerContext_Remove",
    [10] = "Log4g_CLReq_Levels",
    [11] = "Log4g_CLRcv_Levels",
    [12] = "Log4g_CLReq_Appenders",
    [13] = "Log4g_CLRcv_Appenders",
    [14] = "Log4g_CLReq_Layouts",
    [15] = "Log4g_CLRcv_Layouts",
    [16] = "Log4g_CLReq_LoggerConfig_Keys",
    [17] = "Log4g_CLRcv_LoggerConfig_Keys"
})

net.Receive("Log4g_CLReq_LoggerConfig_Keys", function(len, ply)
    if not ply:IsAdmin() then return end
    net.Start("Log4g_CLRcv_LoggerConfig_Keys")

    net.WriteTable({"name", "eventname", "uid", "loggercontext", "level", "appender", "layout"})

    net.Send(ply)
end)

local Levels = {}
local Appenders = {}
local Layouts = {}

for k, _ in pairs(Log4g.Levels) do
    table.insert(Levels, k)
end

for k, _ in pairs(Log4g.Appenders) do
    table.insert(Appenders, k)
end

for k, _ in pairs(Log4g.Layouts) do
    table.insert(Layouts, k)
end

SendTableAfterRcvNetMsg("Log4g_CLReq_Levels", "Log4g_CLRcv_Levels", Levels)
SendTableAfterRcvNetMsg("Log4g_CLReq_Appenders", "Log4g_CLRcv_Appenders", Appenders)
SendTableAfterRcvNetMsg("Log4g_CLReq_Layouts", "Log4g_CLRcv_Layouts", Layouts)

net.Receive("Log4g_CLReq_Hooks", function(len, ply)
    if not ply:IsAdmin() then return end
    net.Start("Log4g_CLRcv_Hooks")
    local Data = util.Compress(util.TableToJSON(hook.GetTable()))
    local Len = #Data
    net.WriteUInt(Len, 16)
    net.WriteData(Data, Len)
    net.Send(ply)
end)

net.Receive("Log4g_CLUpload_LoggerConfig", function(len, ply)
    if not ply:IsAdmin() then return end
    local LoggerConfigContent = net.ReadTable()
    local LoggerConfigName = LoggerConfigContent.name
    local LoggerContextName = LoggerConfigContent.loggercontext
    local Str = util.TableToJSON(LoggerConfigContent, true)
    local Dir = "log4g/server/loggercontext/"
    file.CreateDir(Dir .. LoggerContextName)
    local File = Dir .. LoggerContextName .. "/" .. "loggerconfig_" .. LoggerConfigName .. ".json"
    file.Write(File, Str)
    Log4g.NewLoggerConfig(LoggerConfigName, LoggerConfigContent.eventname, LoggerConfigContent.uid, LoggerContextName, LoggerConfigContent.level, LoggerConfigContent.appender, LoggerConfigContent.layout, File)

    if file.Exists(LoggerContextLookupFile, "DATA") then
        local Tbl = util.JSONToTable(file.Read(LoggerContextLookupFile, "DATA"))
        local Bool, Key = HasKey(Tbl, LoggerContextName)

        if Bool then
            table.insert(Tbl[Key], LoggerConfigName)
        else
            Tbl[LoggerContextName] = {LoggerConfigName}
        end

        file.Write(LoggerContextLookupFile, util.TableToJSON(Tbl, true))
    else
        file.Write(LoggerContextLookupFile, util.TableToJSON({
            [LoggerContextName] = {LoggerConfigName}
        }, true))
    end
end)

net.Receive("Log4g_CLReq_LoggerConfigs", function(len, ply)
    if not ply:IsAdmin() then return end
    local Tbl = {}

    for _, v in ipairs(FindFilesInSubFolders("log4g/server/loggercontext/", "loggerconfig_*.json", "DATA")) do
        table.insert(Tbl, v)
    end

    net.Start("Log4g_CLRcv_LoggerConfigs")
    local Data = {}

    for _, v in ipairs(Tbl) do
        table.Add(Data, {util.JSONToTable(file.Read(v, "DATA"))})
    end

    local Str = util.Compress(util.TableToJSON(Data, true))
    local Len = #Str
    net.WriteUInt(Len, 16)
    net.WriteData(Str, Len)
    net.Send(ply)
end)

net.Receive("Log4g_CLReq_LoggerConfig_Remove", function(len, ply)
    if not ply:IsAdmin() then return end
    local LoggerContextName = net.ReadString()
    local LoggerConfigName = net.ReadString()
    local FileName = "loggerconfig_" .. LoggerConfigName .. ".json"

    for k, v in pairs(Log4g.LoggerConfigs) do
        if v.name == LoggerConfigName then
            Log4g.LoggerConfigs[k] = nil
        end
    end

    for _, v in ipairs(FindFilesInSubFolders("log4g/server/loggercontext/", "loggerconfig_*.json", "DATA")) do
        if v == "log4g/server/loggercontext/" .. LoggerContextName .. "/" .. FileName then
            file.Delete(v)
        end
    end

    local Tbl = util.JSONToTable(file.Read(LoggerContextLookupFile, "DATA"))

    for k, v in pairs(Tbl) do
        if k == LoggerContextName then
            for i, j in ipairs(v) do
                if j == LoggerConfigName then
                    table.remove(v, i)
                end
            end
        end
    end

    file.Write(LoggerContextLookupFile, util.TableToJSON(Tbl))
end)

net.Receive("Log4g_CLReq_LoggerContext_Lookup", function(len, ply)
    if not ply:IsAdmin() then return end
    net.Start("Log4g_CLRcv_LoggerContext_Lookup")

    if file.Exists(LoggerContextLookupFile, "DATA") then
        net.WriteBool(true)
        local Str = util.Compress(file.Read(LoggerContextLookupFile, "DATA"))
        local Len = #Str
        net.WriteUInt(Len, 16)
        net.WriteData(Str, Len)
    else
        net.WriteBool(false)
    end

    net.Send(ply)
end)

net.Receive("Log4g_CLReq_LoggerContext_Remove", function(len, ply)
    if not ply:IsAdmin() then return end
    local _, Folders = file.Find("log4g/server/loggercontext/*", "DATA")
    local LoggerContextName = net.ReadString()

    for _, v in ipairs(Folders) do
        local Files, _ = file.Find("log4g/server/loggercontext/" .. v .. "/loggerconfig_*.json", "DATA")

        if v == LoggerContextName then
            for _, j in ipairs(Files) do
                file.Delete("log4g/server/loggercontext/" .. v .. "/" .. j)
            end

            file.Delete("log4g/server/loggercontext/" .. v)
        end
    end

    local Tbl = util.JSONToTable(file.Read(LoggerContextLookupFile, "DATA"))

    for k, _ in pairs(Tbl) do
        if k == LoggerContextName then
            Tbl[k] = nil
        end
    end

    file.Write(LoggerContextLookupFile, util.TableToJSON(Tbl))
end)