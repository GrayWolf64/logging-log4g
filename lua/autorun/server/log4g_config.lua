if CLIENT then return end

local NetworkStrings = {
    [1] = "Log4g_CLUpld_LoggerConfig",
    [2] = "Log4g_CLReq_Hooks_SV",
    [3] = "Log4g_CLRcv_Hooks_SV",
    [4] = "Log4g_CLReq_LogLevels_SV",
    [5] = "Log4g_CLRcv_LogLevels_SV",
    [6] = "Log4g_CLReq_Appenders_SV",
    [7] = "Log4g_CLRcv_Appenders_SV",
    [8] = "Log4g_CLReq_Layouts_SV",
    [9] = "Log4g_CLRcv_Layouts_SV",
    [10] = "Log4g_CLReq_LConfigs",
    [11] = "Log4g_CLRcv_LConfigs",
    [12] = "Log4g_CLReq_DelLConfig",
    [13] = "Log4g_CLReq_LContextStructure",
    [14] = "Log4g_CLRcv_LContextStructure",
    [15] = "Log4g_CLReq_DelLContext"
}

for k, v in ipairs(NetworkStrings) do
    util.AddNetworkString(v)
end

local LogLevels = {
    [1] = "ALL",
    [2] = "TRACE",
    [3] = "DEBUG",
    [4] = "INFO",
    [5] = "WARN",
    [6] = "ERROR",
    [7] = "FATAL"
}

local Appenders = {
    [1] = "Engine Console"
}

local Layouts = {
    [1] = "Basic Text"
}

net.Receive("Log4g_CLReq_Hooks_SV", function(len, ply)
    net.Start("Log4g_CLRcv_Hooks_SV")
    local Data = util.Compress(util.TableToJSON(hook.GetTable()))
    net.WriteUInt(#Data, 16)
    net.WriteData(Data, #Data)
    net.Send(ply)
end)

local function SendTableAfterRcvViaNet(receive, start, tbl)
    net.Receive(receive, function(len, ply)
        net.Start(start)
        net.WriteTable(tbl)
        net.Send(ply)
    end)
end

local function HasExactKey(tbl, key)
    if #tbl == 0 or tbl == nil then return false end

    for k, _ in pairs(tbl) do
        if k == key then return true, k end
    end

    return false
end

SendTableAfterRcvViaNet("Log4g_CLReq_LogLevels_SV", "Log4g_CLRcv_LogLevels_SV", LogLevels)
SendTableAfterRcvViaNet("Log4g_CLReq_Appenders_SV", "Log4g_CLRcv_Appenders_SV", Appenders)
SendTableAfterRcvViaNet("Log4g_CLReq_Layouts_SV", "Log4g_CLRcv_Layouts_SV", Layouts)

net.Receive("Log4g_CLUpld_LoggerConfig", function()
    local Tbl = net.ReadTable()
    local LCContent = util.TableToJSON(Tbl, true)
    local LContextName, LConfigName = Tbl[3], Tbl[7]
    local Dir = "log4g/server/loggercontext/"
    file.CreateDir(Dir .. LContextName)
    file.Write(Dir .. LContextName .. "/" .. "lconfig_" .. LConfigName .. ".json", LCContent)
    local File = "log4g/server/loggercontext/lcontext_info.json"

    if file.Exists(File, "DATA") then
        local PrevTbl = util.JSONToTable(file.Read(File, "DATA"))
        local Bool, Key = HasExactKey(PrevTbl, LContextName)

        if Bool then
            table.insert(PrevTbl[Key], LConfigName)
        else
            PrevTbl[LContextName] = {LConfigName}
        end

        file.Write(File, util.TableToJSON(PrevTbl, true))
    else
        file.Write(File, util.TableToJSON({
            [LContextName] = {LConfigName}
        }))
    end
end)

net.Receive("Log4g_CLReq_LConfigs", function(len, ply)
    local _, Folders = file.Find("log4g/server/loggercontext/*", "DATA")
    local Tbl = {}

    for _, v in ipairs(Folders) do
        local Files, _ = file.Find("log4g/server/loggercontext/" .. v .. "/lconfig_*.json", "DATA")

        if #Files ~= 0 then
            for _, j in ipairs(Files) do
                j = "log4g/server/loggercontext/" .. v .. "/" .. j
                table.insert(Tbl, j)
            end
        end
    end

    net.Start("Log4g_CLRcv_LConfigs")
    local Data = {}

    for _, v in ipairs(Tbl) do
        table.Add(Data, {util.JSONToTable(file.Read(v, "DATA"))})
    end

    local CStr = util.Compress(util.TableToJSON(Data, true))
    net.WriteUInt(#CStr, 16)
    net.WriteData(CStr, #CStr)
    net.Send(ply)
    table.Empty(Tbl)
    table.Empty(Data)
end)

net.Receive("Log4g_CLReq_LContextStructure", function(len, ply)
    net.Start("Log4g_CLRcv_LContextStructure")

    if file.Exists("log4g/server/loggercontext/lcontext_info.json", "DATA") then
        net.WriteBool(true)
        local CStr = util.Compress(file.Read("log4g/server/loggercontext/lcontext_info.json", "DATA"))
        net.WriteUInt(#CStr, 16)
        net.WriteData(CStr, #CStr)
    else
        net.WriteBool(false)
    end

    net.Send(ply)
end)

net.Receive("Log4g_CLReq_DelLConfig", function()
    local Context = net.ReadString()
    local LConfig = net.ReadString()
    local FName = "lconfig_" .. LConfig .. ".json"
    local _, Folders = file.Find("log4g/server/loggercontext/*", "DATA")

    for _, v in ipairs(Folders) do
        local Files, _ = file.Find("log4g/server/loggercontext/" .. v .. "/lconfig_*.json", "DATA")

        for _, j in ipairs(Files) do
            if j == FName then
                file.Delete("log4g/server/loggercontext/" .. v .. "/" .. j)
            end
        end
    end

    local File = "log4g/server/loggercontext/lcontext_info.json"
    local Tbl = util.JSONToTable(file.Read(File, "DATA"))

    for k, v in pairs(Tbl) do
        if k == Context then
            for i, j in ipairs(v) do
                if j == LConfig then
                    table.remove(v, i)
                end
            end
        end
    end

    file.Write(File, util.TableToJSON(Tbl))
end)

net.Receive("Log4g_CLReq_DelLContext", function()
    local _, Folders = file.Find("log4g/server/loggercontext/*", "DATA")
    local Context = net.ReadString()

    for _, v in ipairs(Folders) do
        local Files, _ = file.Find("log4g/server/loggercontext/" .. v .. "/lconfig_*.json", "DATA")

        for _, j in ipairs(Files) do
            file.Delete("log4g/server/loggercontext/" .. v .. "/" .. j)
        end
    end

    for _, m in ipairs(Folders) do
        if m == Context then
            file.Delete("log4g/server/loggercontext/" .. m)
        end
    end

    local File = "log4g/server/loggercontext/lcontext_info.json"
    local Tbl = util.JSONToTable(file.Read(File, "DATA"))

    for k, _ in pairs(Tbl) do
        if k == Context then
            Tbl[k] = false
            table.RemoveByValue(Tbl, false)
        end
    end

    file.Write(File, util.TableToJSON(Tbl))
end)