if SERVER then
    local NetworkStrings = {
        [1] = "Log4g_CLUpld_LoggerConfig",
        [2] = "log4g_config_clientrequest_buildlogger",
        [3] = "Log4g_CLReq_Hooks_SV",
        [4] = "Log4g_CLRcv_Hooks_SV",
        [5] = "Log4g_CLReq_LogLevels_SV",
        [6] = "Log4g_CLRcv_LogLevels_SV",
        [7] = "Log4g_CLReq_Appenders_SV",
        [8] = "Log4g_CLRcv_Appenders_SV",
        [9] = "Log4g_CLReq_Layouts_SV",
        [10] = "Log4g_CLRcv_Layouts_SV",
        [11] = "Log4g_CLReq_LContextFolders",
        [12] = "Log4g_CLRcv_LContextFolders",
        [13] = "Log4g_CLReq_LConfigs",
        [14] = "Log4g_CLRcv_LConfigs",
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

    SendTableAfterRcvViaNet("Log4g_CLReq_LogLevels_SV", "Log4g_CLRcv_LogLevels_SV", LogLevels)
    SendTableAfterRcvViaNet("Log4g_CLReq_Appenders_SV", "Log4g_CLRcv_Appenders_SV", Appenders)
    SendTableAfterRcvViaNet("Log4g_CLReq_Layouts_SV", "Log4g_CLRcv_Layouts_SV", Layouts)

    net.Receive("Log4g_CLUpld_LoggerConfig", function()
        local Tbl = net.ReadTable()
        local LCContent = util.TableToJSON(Tbl, true)
        local LConfigName, LContextName = Tbl[7], Tbl[3]
        file.CreateDir("log4g/server/loggercontext/" .. LContextName)
        file.Write("log4g/server/loggercontext/" .. LContextName .. "/" .. LConfigName .. ".json", LCContent)
    end)

    net.Receive("Log4g_CLReq_LContextFolders", function(len, ply)
        net.Start("Log4g_CLRcv_LContextFolders")
        local _, Folders = file.Find("log4g/server/loggercontext/*", "DATA")

        if not table.IsEmpty(Folders) then
            net.WriteBool(true)
            net.WriteTable(Folders)
        else
            net.WriteBool(false)
        end

        net.Send(ply)
    end)

    net.Receive("Log4g_CLReq_LConfigs", function(len, ply)
        local _, Folders = file.Find("log4g/server/loggercontext/*", "DATA")
        local Tbl = {}

        for k, v in ipairs(Folders) do
            local Files, _ = file.Find("log4g/server/loggercontext/" .. v .. "/*.json", "DATA")

            if #Files ~= 0 then
                for i, j in ipairs(Files) do
                    j = "log4g/server/loggercontext/" .. v .. "/" .. j

                    table.Add(Tbl, {j})
                end
            end
        end

        net.Start("Log4g_CLRcv_LConfigs")
        local Data = {}

        for k, v in ipairs(Tbl) do
            table.Add(Data, {util.JSONToTable(file.Read(v, "DATA"))})
        end

        local CStr = util.Compress(util.TableToJSON(Data, true))
        net.WriteUInt(#CStr, 16)
        net.WriteData(CStr, #CStr)
        net.Send(ply)
        table.Empty(Tbl)
        table.Empty(Data)
    end)
    --[[local function BuildLogger()
        if file.Exists(File, "DATA") then
            MsgC("[log4g] Logger Built.\n")
        else
            ErrorNoHalt("[log4g] Server has no config file.\n")
        end
    end

    net.Receive("log4g_config_clientrequest_buildlogger", function()
        BuildLogger()
    end)

    concommand.Add("log4g_buildlogger_sv", function()
        BuildLogger()
    end)--]]
end