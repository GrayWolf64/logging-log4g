local AddNetworkStrsViaTbl = Log4g.Util.AddNetworkStrsViaTbl
local WriteDataSimple = Log4g.Util.WriteDataSimple
local LoggerLookupFile = "log4g/server/loggercontext/lookup_logger.json"

AddNetworkStrsViaTbl({
    ["Log4g_CLReq_Logger_Lookup"] = true,
    ["Log4g_CLRcv_Logger_Lookup"] = true,
    ["Log4g_CLReq_Logger_ColumnText"] = true,
    ["Log4g_CLRcv_Logger_ColumnText"] = true,
    ["Log4g_CLReq_Logger_Remove"] = true
})

net.Receive("Log4g_CLReq_Logger_ColumnText", function(len, ply)
    net.Start("Log4g_CLRcv_Logger_ColumnText")

    net.WriteTable({"name", "loggercontext", "configfile"})

    net.Send(ply)
end)

net.Receive("Log4g_CLReq_Logger_Lookup", function(len, ply)
    net.Start("Log4g_CLRcv_Logger_Lookup")

    if file.Exists(LoggerLookupFile, "DATA") then
        net.WriteBool(true)
        WriteDataSimple(file.Read(LoggerLookupFile, "DATA"), 16)
    else
        net.WriteBool(false)
    end

    net.Send(ply)
end)

net.Receive("Log4g_CLReq_Logger_Remove", function(len, ply)
    local LoggerContextName, LoggerName = net.ReadString(), net.ReadString()
    Log4g.Hierarchy[LoggerContextName].logger[LoggerName]:Terminate()
end)