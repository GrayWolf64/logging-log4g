if SERVER then
    local log4g_LoggerConfig = {}
    util.AddNetworkString("log4g_loggerconfig_eventname_clientsent")
    util.AddNetworkString("log4g_loggerconfig_uniqueidentifier_clientsent")
    util.AddNetworkString("log4g_loggerconfig_eventname_serversent")
    util.AddNetworkString("log4g_loggerconfig_uniqueidentifier_serversent")

    net.Receive("log4g_loggerconfig_eventname_clientsent", function(ply)
        local Message_a = net.ReadString()
        net.Start("log4g_loggerconfig_eventname_serversent")
        net.WriteString(Message_a)
        net.Broadcast()

        net.Receive("log4g_loggerconfig_uniqueidentifier_clientsent", function()
            local Message_b = net.ReadString()

            table.Add(log4g_LoggerConfig, {
                {Message_a, Message_b}
            })

            local ToFile = util.TableToJSON(log4g_LoggerConfig, true)
            file.Write("log4g/log4g_loggerconfig_server.json", ToFile)
            net.Start("log4g_loggerconfig_uniqueidentifier_serversent")
            net.WriteString(Message_b)
            net.Broadcast()
        end)
    end)

    concommand.Add("log4g_clear_loggerconfig_table_server", function()
        if table.IsEmpty(log4g_LoggerConfig) then
            MsgC("[log4g] Table already cleared.\n")
        else
            table.Empty(log4g_LoggerConfig)
            MsgC("[log4g] Table cleared.\n")
        end
    end)
end