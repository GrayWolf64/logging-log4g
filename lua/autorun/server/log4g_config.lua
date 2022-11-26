if SERVER then
    local ConfigBuffer = {}

    local NetworkStrings = {
        [1] = "Log4g_CLUpld_LoggerConfig",
        [2] = "log4g_config_clientrequest_download",
        [3] = "log4g_config_clientdownload",
        [4] = "log4g_config_clientrequest_clrconfig",
        [5] = "log4g_config_clientrequest_buildlogger",
        [6] = "Log4g_CLReq_Hooks_SV",
        [7] = "Log4g_CLRcv_Hooks_SV",
        [8] = "Log4g_CLReq_LogLevels_SV",
        [9] = "Log4g_CLRcv_LogLevels_SV",
        [10] = "Log4g_CLReq_Appenders_SV",
        [11] = "Log4g_CLRcv_Appenders_SV",
        [12] = "Log4g_CLReq_Layouts_SV",
        [13] = "Log4g_CLRcv_Layouts_SV"
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

    local File = "log4g/server/log4g_config_sv.json"

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
        local LConfigName, LContextName = Tbl["LoggerConfig Name"], Tbl["LoggerContext"]
        file.CreateDir("log4g/server/loggercontext/" .. LContextName)
        file.Write("log4g/server/loggercontext/" .. LContextName .. "/" .. LConfigName .. ".json", LCContent)
    end)

    net.Receive("log4g_config_clientrequest_download", function(len, ply)
        net.Start("log4g_config_clientdownload")

        if file.Exists(File, "DATA") then
            net.WriteBool(true)
            net.WriteTable(util.JSONToTable(file.Read(File, "DATA")))
        else
            net.WriteBool(false)
        end

        net.Send(ply)
    end)

    local function ClearConfig()
        if not table.IsEmpty(ConfigBuffer) then
            table.Empty(ConfigBuffer)
        end

        if file.Exists(File, "DATA") then
            file.Delete(File)
        end

        MsgC("[log4g] Config cleared.\n")
    end

    net.Receive("log4g_config_clientrequest_clrconfig", function()
        ClearConfig()
    end)

    concommand.Add("log4g_clrconfig_sv", function()
        ClearConfig()
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