if SERVER then
    local log4g_LoggerConfig = {}
    util.AddNetworkString("log4g_loggerconfig_basicinfo_clientsent")
    util.AddNetworkString("log4g_loggerconfig_basicinfo_serversent")
    util.AddNetworkString("log4g_loggerconfig_basicinfo_clientupload")
    util.AddNetworkString("log4g_loggerconfig_basicinfo_clientrequestdownload")
    util.AddNetworkString("log4g_loggerconfig_basicinfo_clientdownload")

    net.Receive("log4g_loggerconfig_basicinfo_clientsent", function()
        local Message = net.ReadTable()
        net.Start("log4g_loggerconfig_basicinfo_serversent")
        net.WriteTable(Message)
        net.Broadcast()
    end)

    local ServerFile = "log4g/server/log4g_loggerconfig_server.json"

    net.Receive("log4g_loggerconfig_basicinfo_clientupload", function()
        local Message = net.ReadTable()

        table.Add(log4g_LoggerConfig, {Message})

        local ToFile = util.TableToJSON(log4g_LoggerConfig, true)
        file.Write(ServerFile, ToFile)
    end)

    net.Receive("log4g_loggerconfig_basicinfo_clientrequestdownload", function(len, ply)
        if file.Exists(ServerFile, "DATA") then
            net.Start("log4g_loggerconfig_basicinfo_clientdownload")
            net.WriteBool(true)
            net.WriteTable(util.JSONToTable(file.Read(ServerFile, "DATA")))
            net.Send(ply)
        else
            net.Start("log4g_loggerconfig_basicinfo_clientdownload")
            net.WriteBool(false)
            net.Send(ply)
        end
    end)

    concommand.Add("log4g_clear_loggerconfig_table_server", function()
        if not table.IsEmpty(log4g_LoggerConfig) then
            table.Empty(log4g_LoggerConfig)
        end

        MsgC("[log4g] Table cleared.\n")
    end)
end