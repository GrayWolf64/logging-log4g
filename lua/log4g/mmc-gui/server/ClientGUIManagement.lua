local AddNetworkStrsViaTbl = Log4g.Util.AddNetworkStrsViaTbl
local WriteDataSimple = Log4g.Util.WriteDataSimple
local RemoveLoggerLookupLogger = Log4g.Core.Logger.Lookup.RemoveLogger
local GetAllLoggerContexts = Log4g.API.LoggerContextFactory.GetContextAll
local LoggerLookupFile = "log4g/server/loggercontext/lookup_logger.json"

AddNetworkStrsViaTbl({
    [1] = "Log4g_CLReq_Logger_Lookup",
    [2] = "Log4g_CLRcv_Logger_Lookup",
    [3] = "Log4g_CLReq_Logger_Remove",
})

net.Receive("Log4g_CLReq_Logger_Lookup", function(_, ply)
    net.Start("Log4g_CLRcv_Logger_Lookup")

    if sql.QueryRow("SELECT * FROM Log4g_Lookup WHERE Name = 'Logger';") then
        net.WriteBool(true)
        WriteDataSimple(sql.QueryValue("SELECT Content FROM Log4g_Lookup WHERE Name = 'Logger';"), 16)
    else
        net.WriteBool(false)
    end

    net.Send(ply)
end)

net.Receive("Log4g_CLReq_Logger_Remove", function(_, ply)
    local ContextName, LoggerName = net.ReadString(), net.ReadString()
    GetAllLoggerContexts()[ContextName].logger[LoggerName]:Terminate()
    RemoveLoggerLookupLogger(ContextName, LoggerName)
end)