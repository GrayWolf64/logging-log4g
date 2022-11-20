if SERVER then
    local ConfigBuffer = {}
    local Hooks = hook.GetTable()

    local NetworkStrings = {
        [1] = "log4g_config_clientupload",
        [2] = "log4g_config_clientrequest_download",
        [3] = "log4g_config_clientdownload",
        [4] = "log4g_config_clientrequest_clrconfig",
        [5] = "log4g_config_clientrequest_buildlogger",
        [6] = "log4g_hooks_clientrequest",
        [7] = "log4g_hooks_clientdownload"
    }

    for k, v in ipairs(NetworkStrings) do
        util.AddNetworkString(v)
    end

    local File = "log4g/server/log4g_config_sv.json"

    net.Receive("log4g_hooks_clientrequest", function(len, ply)
        net.Start("log4g_hooks_clientdownload")
        local Data = util.Compress(util.TableToJSON(Hooks))
        net.WriteUInt(#Data, 16)
        net.WriteData(Data, #Data)
        net.Send(ply)
    end)

    net.Receive("log4g_config_clientupload", function()
        table.Add(ConfigBuffer, net.ReadTable())
        print("[log4g] Server Received Configuration:")
        PrintTable(ConfigBuffer)
        Result = util.TableToJSON(ConfigBuffer, true)
        file.Write(File, Result)
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

    local function BuildLogger()
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
    end)
end