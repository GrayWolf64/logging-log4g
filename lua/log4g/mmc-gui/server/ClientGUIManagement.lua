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
	local ContextName, LoggerName = net.ReadString(), net.ReadString()
	GetAllLoggerContexts()[ContextName].logger[LoggerName]:Terminate()
	RemoveLoggerLookupLogger(ContextName, LoggerName)
end)
