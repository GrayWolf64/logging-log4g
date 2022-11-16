if SERVER then
    local ConfigurationBuffer = {}
    util.AddNetworkString("log4g_configuration_clientsent")
    util.AddNetworkString("log4g_configuration_serversent")
    util.AddNetworkString("log4g_configuration_clientupload")
    util.AddNetworkString("log4g_configuration_clientrequestdownload")
    util.AddNetworkString("log4g_configuration_clientdownload")

    net.Receive("log4g_configuration_clientsent", function()
        local Message = net.ReadTable()
        net.Start("log4g_configuration_serversent")
        net.WriteTable(Message)
        net.Broadcast()
    end)

    local ServerFile = "log4g/server/log4g_configuration_server.json"

    net.Receive("log4g_configuration_clientupload", function()
        local Message = net.ReadTable()

        table.Add(ConfigurationBuffer, {Message})

        local ToFile = util.TableToJSON(ConfigurationBuffer, true)
        file.Write(ServerFile, ToFile)
    end)

    net.Receive("log4g_configuration_clientrequestdownload", function(len, ply)
        if file.Exists(ServerFile, "DATA") then
            net.Start("log4g_configuration_clientdownload")
            net.WriteBool(true)
            net.WriteTable(util.JSONToTable(file.Read(ServerFile, "DATA")))
            net.Send(ply)
        else
            net.Start("log4g_configuration_clientdownload")
            net.WriteBool(false)
            net.Send(ply)
        end
    end)

    concommand.Add("log4g_clear_configuration_table_server", function()
        if not table.IsEmpty(ConfigurationBuffer) then
            table.Empty(ConfigurationBuffer)
        end

        MsgC("[log4g] Table cleared.\n")
    end)
    --[[concommand.Add("log4g_server_buildlogger", function()
        if file.Exists(ServerFile, "DATA") then
            local Table = util.JSONToTable(file.Read(ServerFile))

            for k, v in ipairs(Table) do
                if v[3] == "Engine Console" and v[4] == "Rich Text" then
                    hook.Add(v[1], v[2], function()
                        MsgC("Event happened\n")
                    end)
                end
            end
        else
            MsgC("[log4g] Server has no loggerconfig file.")
        end
    end)--]]
end