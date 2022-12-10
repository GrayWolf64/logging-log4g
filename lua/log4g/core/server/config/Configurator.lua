local AddNetworkStrsViaTbl = Log4g.Util.AddNetworkStrsViaTbl
local FindFilesInSubFolders = Log4g.Util.FindFilesInSubFolders

AddNetworkStrsViaTbl({
    [1] = "Log4g_CLUpload_LoggerConfig",
    [2] = "Log4g_CLReq_Hooks",
    [3] = "Log4g_CLRcv_Hooks",
    [4] = "Log4g_CLReq_LoggerConfigs",
    [5] = "Log4g_CLRcv_LoggerConfigs",
    [6] = "Log4g_CLReq_DelLoggerConfig",
    [7] = "Log4g_CLReq_BuildLogger",
    [8] = "Log4g_CLReq_LoggerContextStructure",
    [9] = "Log4g_CLRcv_LoggerContextStructure",
    [10] = "Log4g_CLReq_RemoveLoggerContext"
})

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
    local Tbl = net.ReadTable()
    local Str = util.TableToJSON(Tbl, true)
    local LoggerContextName, LoggerConfigName = Tbl[3], Tbl[7]
    local Dir = "log4g/server/loggercontext/"
    file.CreateDir(Dir .. LoggerContextName)
    file.Write(Dir .. LoggerContextName .. "/" .. "lconfig_" .. LoggerConfigName .. ".json", Str)
    local File = "log4g/server/loggercontext/lcontext_info.json"

    if file.Exists(File, "DATA") then
        local PrevTbl = util.JSONToTable(file.Read(File, "DATA"))
        local Bool, Key = Log4g.Util.HasKey(PrevTbl, LoggerContextName)

        if Bool then
            table.insert(PrevTbl[Key], LoggerConfigName)
        else
            PrevTbl[LoggerContextName] = {LoggerConfigName}
        end

        file.Write(File, util.TableToJSON(PrevTbl, true))
    else
        file.Write(File, util.TableToJSON({
            [LoggerContextName] = {LoggerConfigName}
        }))
    end
end)

net.Receive("Log4g_CLReq_LoggerConfigs", function(len, ply)
    if not ply:IsAdmin() then return end
    local Tbl = {}

    for _, v in ipairs(FindFilesInSubFolders("log4g/server/loggercontext/", "lconfig_*.json", "DATA")) do
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

net.Receive("Log4g_CLReq_DelLoggerConfig", function(len, ply)
    if not ply:IsAdmin() then return end
    local LoggerContextName = net.ReadString()
    local LoggerConfigName = net.ReadString()
    local FileName = "lconfig_" .. LoggerConfigName .. ".json"

    for _, v in ipairs(FindFilesInSubFolders("log4g/server/loggercontext/", "lconfig_*.json", "DATA")) do
        if v == "log4g/server/loggercontext/" .. LoggerContextName .. "/" .. FileName then
            file.Delete(v)
        end
    end

    local File = "log4g/server/loggercontext/lcontext_info.json"
    local Tbl = util.JSONToTable(file.Read(File, "DATA"))

    for k, v in pairs(Tbl) do
        if k == LoggerContextName then
            for i, j in ipairs(v) do
                if j == LoggerConfigName then
                    table.remove(v, i)
                end
            end
        end
    end

    file.Write(File, util.TableToJSON(Tbl))
end)

net.Receive("Log4g_CLReq_LoggerContextStructure", function(len, ply)
    if not ply:IsAdmin() then return end
    net.Start("Log4g_CLRcv_LoggerContextStructure")

    if file.Exists("log4g/server/loggercontext/lcontext_info.json", "DATA") then
        net.WriteBool(true)
        local Str = util.Compress(file.Read("log4g/server/loggercontext/lcontext_info.json", "DATA"))
        local Len = #Str
        net.WriteUInt(Len, 16)
        net.WriteData(Str, Len)
    else
        net.WriteBool(false)
    end

    net.Send(ply)
end)

net.Receive("Log4g_CLReq_RemoveLoggerContext", function(len, ply)
    if not ply:IsAdmin() then return end
    local _, Folders = file.Find("log4g/server/loggercontext/*", "DATA")
    local LoggerContextName = net.ReadString()

    for _, v in ipairs(Folders) do
        local Files, _ = file.Find("log4g/server/loggercontext/" .. v .. "/lconfig_*.json", "DATA")

        if v == LoggerContextName then
            for _, j in ipairs(Files) do
                file.Delete("log4g/server/loggercontext/" .. v .. "/" .. j)
            end

            file.Delete("log4g/server/loggercontext/" .. v)
        end
    end

    local File = "log4g/server/loggercontext/lcontext_info.json"
    local Tbl = util.JSONToTable(file.Read(File, "DATA"))

    for k, _ in pairs(Tbl) do
        if k == LoggerContextName then
            Tbl[k] = nil
        end
    end

    file.Write(File, util.TableToJSON(Tbl))
end)

net.Receive("Log4g_CLReq_BuildLogger", function(len, ply)
    if not ply:IsAdmin() then return end
end)