if CLIENT then return end

Log4g.Util.AddNetworkStrsViaTbl({
    [1] = "Log4g_CLReq_LoggerContextStructure",
    [2] = "Log4g_CLRcv_LoggerContextStructure",
    [3] = "Log4g_CLReq_RemoveLoggerContext"
})

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