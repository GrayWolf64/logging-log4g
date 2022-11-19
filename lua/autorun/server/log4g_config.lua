if SERVER then
    local ConfigBuffer = {}

    local NetworkStrings = {
        [1] = "log4g_config_clientupload",
        [2] = "log4g_config_clientrequestdownload",
        [3] = "log4g_config_clientdownload"
    }

    for k, v in ipairs(NetworkStrings) do
        util.AddNetworkString(v)
    end

    local File = "log4g/server/log4g_config_sv.json"

    net.Receive("log4g_config_clientupload", function()
        table.Add(ConfigBuffer, net.ReadTable())
        print("[log4g] Server Received Configuration:")
        PrintTable(ConfigBuffer)
        Result = util.TableToJSON(ConfigBuffer, true)
        file.Write(File, Result)
    end)

    net.Receive("log4g_config_clientrequestdownload", function(len, ply)
        net.Start("log4g_config_clientdownload")

        if file.Exists(File, "DATA") then
            net.WriteBool(true)
            net.WriteTable(util.JSONToTable(file.Read(File, "DATA")))
        else
            net.WriteBool(false)
        end

        net.Send(ply)
    end)

    concommand.Add("log4g_clear_config_buffer_sv", function()
        if not table.IsEmpty(ConfigBuffer) then
            table.Empty(ConfigBuffer)
        end

        MsgC("[log4g] Buffer cleared.\n")
    end)

    concommand.Add("log4g_clear_config_file_sv", function()
        if file.Exists(File, "DATA") then
            file.Delete(File)
        end

        MsgC("[log4g] File cleared.\n")
    end)
    --[[concommand.Add("log4g_buildlogger_sv", function()
        if file.Exists(File, "DATA") then
            local Tbl = util.JSONToTable(file.Read(ServerFile))

            for k, v in ipairs(Tbl) do
                if v[3] == "Engine Console" then
                    hook.Add(v[1], v[2], function()
                        MsgC("Event happened\n")
                    end)
                end
            end
        else
            MsgC("[log4g] Server has no config file.")
        end
    end)--]]
end