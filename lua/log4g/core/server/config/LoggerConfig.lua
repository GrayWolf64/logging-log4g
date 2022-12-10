local AddNetworkStrsViaTbl = Log4g.Util.AddNetworkStrsViaTbl

AddNetworkStrsViaTbl({
    [1] = "Log4g_CLReq_LoggerConfig_Keys",
    [2] = "Log4g_CLRcv_LoggerConfig_Keys"
})

net.Receive("Log4g_CLReq_LoggerConfig_Keys", function(len, ply)
    if not ply:IsAdmin() then return end
    net.Start("Log4g_CLRcv_LoggerConfig_Keys")

    net.WriteTable({"name", "eventname", "uid", "loggercontext", "level", "appender", "layout"})

    net.Send(ply)
end)

Log4g.LoggerConfigs = {}
local Object = include("log4g/core/server/Class.lua")
local LoggerConfig = Object:Extend()

function LoggerConfig:New(name, eventname, uid, loggercontext, level, appender, layout, file)
    self.name = name or ""
    self.eventname = eventname or ""
    self.uid = uid or ""
    self.loggercontext = loggercontext or ""
    self.level = level or ""
    self.appender = appender or ""
    self.layout = layout or ""
    self.file = file or ""
end

function LoggerConfig:Delete()
    self.name = nil
    self.eventname = nil
    self.uid = nil
    self.loggercontext = nil
    self.level = nil
    self.appender = nil
    self.layout = nil
    self.file = nil
end

function Log4g.NewLoggerConfig(name, eventname, uid, loggercontext, level, appender, layout, file)
    local loggerconfig = LoggerConfig(name, eventname, uid, loggercontext, level, appender, layout, file)
    table.insert(Log4g.LoggerConfigs, loggerconfig)

    return loggerconfig
end