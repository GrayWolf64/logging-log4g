--- Server-side processing of the Client GUI Configurator requests.
-- @script ClientGUIConfigurator
-- @license Apache License 2.0
-- @copyright GrayWolf64
local AddNetworkStrsViaTbl                  = Log4g.Util.AddNetworkStrsViaTbl
local CreateLoggerContext                   = Log4g.API.LoggerContextFactory.GetContext
local RegisterLoggerConfig                  = Log4g.Core.Config.LoggerConfig.RegisterLoggerConfig
local RegisterCustomLevel                   = Log4g.Level.RegisterCustomLevel
local AddLoggerContextLookupItem            = Log4g.Core.LoggerContext.Lookup.AddItem
local RemoveLoggerContextLookup             = Log4g.Core.LoggerContext.Lookup.RemoveLoggerContext
local RemoveLoggerContextLookupLoggerConfig = Log4g.Core.LoggerContext.Lookup.RemoveLoggerConfig
local WriteDataSimple                       = Log4g.Util.WriteDataSimple
local GetLoggerConfigFiles                  = Log4g.Core.Config.LoggerConfig.GetFiles
local GetAllLoggerConfigs                   = Log4g.Core.Config.LoggerConfig.GetAll
local GetAllLoggerContexts                  = Log4g.Core.LoggerContext.GetAll
local LoggerContextLookupFile               = "log4g/server/loggercontext/lookup_loggercontext.json"

local function IdentChk(ply)
    if not IsValid(ply) then return end
    if ply:IsAdmin() then return true end

    return false
end

AddNetworkStrsViaTbl({
    [1]  = "Log4g_CLUpload_LoggerConfig_JSON",
    [2]  = "Log4g_CLUpload_NewLevel",
    [3]  = "Log4g_CLReq_LoggerConfigs",
    [4]  = "Log4g_CLRcv_LoggerConfigs",
    [5]  = "Log4g_CLReq_LoggerConfig_Remove",
    [6]  = "Log4g_CLReq_LoggerContext_Lookup",
    [7]  = "Log4g_CLRcv_LoggerContext_Lookup",
    [8]  = "Log4g_CLReq_LoggerContext_Remove",
    [9]  = "Log4g_CLReq_CFG_LoggerConfig_ColumnText",
    [10] = "Log4g_CLRcv_CFG_LoggerConfig_ColumnText",
    [11] = "Log4g_CLReq_ChkConnected",
    [12] = "Log4g_CLRcv_ChkConnected",
    [13] = "Log4g_CLReq_LoggerConfig_BuildDefault"
})

net.Receive("Log4g_CLReq_ChkConnected", function(len, ply)
    net.Start("Log4g_CLRcv_ChkConnected")
    net.WriteBool(IsValid(ply) == ply:IsConnected() == true)
    net.Send(ply)
end)

net.Receive("Log4g_CLReq_CFG_LoggerConfig_ColumnText", function(len, ply)
    net.Start("Log4g_CLRcv_CFG_LoggerConfig_ColumnText")

    net.WriteTable({"name", "eventname", "uid", "loggercontext", "level", "appender", "layout", "logmsg"})

    net.Send(ply)
end)

net.Receive("Log4g_CLUpload_LoggerConfig_JSON", function(len, ply)
    if not IdentChk(ply) then return end
    local tbl = util.JSONToTable(util.Decompress(net.ReadData(net.ReadUInt(16))))
    local contextname, configname = tbl.loggercontext, tbl.name
    CreateLoggerContext(contextname)
    RegisterLoggerConfig(tbl)
    AddLoggerContextLookupItem(contextname, configname)
end)

net.Receive("Log4g_CLReq_LoggerConfigs", function(len, ply)
    local tbl = GetLoggerConfigFiles()
    net.Start("Log4g_CLRcv_LoggerConfigs")

    if istable(tbl) and not table.IsEmpty(tbl) then
        net.WriteBool(true)
        local data = {}

        for _, v in ipairs(tbl) do
            table.Add(data, {util.JSONToTable(file.Read(v, "DATA"))})
        end

        WriteDataSimple(util.TableToJSON(data, true), 16)
    else
        net.WriteBool(false)
    end

    net.Send(ply)
end)

net.Receive("Log4g_CLReq_LoggerConfig_Remove", function(len, ply)
    if not IdentChk(ply) then return end
    local contextname, configname = net.ReadString(), net.ReadString()
    GetAllLoggerConfigs()[configname]:RemoveFile():Remove()
    RemoveLoggerContextLookupLoggerConfig(contextname, configname)
end)

net.Receive("Log4g_CLReq_LoggerContext_Lookup", function(len, ply)
    net.Start("Log4g_CLRcv_LoggerContext_Lookup")

    if file.Exists(LoggerContextLookupFile, "DATA") then
        net.WriteBool(true)
        WriteDataSimple(file.Read(LoggerContextLookupFile, "DATA"), 16)
    else
        net.WriteBool(false)
    end

    net.Send(ply)
end)

net.Receive("Log4g_CLReq_LoggerContext_Remove", function(len, ply)
    if not IdentChk(ply) then return end
    local contextname = net.ReadString()
    GetAllLoggerContexts()[contextname]:Terminate()
    local LoggerConfigs = GetAllLoggerConfigs()

    for k, v in pairs(LoggerConfigs) do
        if v.loggercontext == contextname then
            LoggerConfigs[k] = nil
        end
    end

    RemoveLoggerContextLookup(contextname)
end)

net.Receive("Log4g_CLUpload_NewLevel", function(len, ply)
    if not IdentChk(ply) then return end
    RegisterCustomLevel(net.ReadString(), net.ReadUInt(16))
end)

net.Receive("Log4g_CLReq_LoggerConfig_BuildDefault", function(len, ply)
    if not IdentChk(ply) then return end
    local contextname, configname = net.ReadString(), net.ReadString()
    GetAllLoggerConfigs()[configname]:BuildDefault()
    RemoveLoggerContextLookupLoggerConfig(contextname, configname)
end)