--- Server-side processing of the Client GUI Configurator requests.
-- @script ClientGUIConfigurator.lua
-- @license Apache License 2.0
-- @copyright GrayWolf64
local AddNetworkStrsViaTbl = Log4g.Util.AddNetworkStrsViaTbl
local SendTableAfterRcvNetMsg = Log4g.Util.SendTableAfterRcvNetMsg
local RegisterLoggerContext = Log4g.Core.LoggerContext.RegisterLoggerContext
local RegisterLoggerConfig = Log4g.Core.Config.LoggerConfig.RegisterLoggerConfig
local RegisterCustomLevel = Log4g.Level.RegisterCustomLevel
local AddLoggerContextLookupItem = Log4g.Core.LoggerContext.Lookup.AddItem
local RemoveLoggerContextLookup = Log4g.Core.LoggerContext.Lookup.RemoveLoggerContext
local RemoveLoggerContextLookupLoggerConfig = Log4g.Core.LoggerContext.Lookup.RemoveLoggerConfig
local WriteDataSimple = Log4g.Util.WriteDataSimple
local GetLoggerConfigFiles = Log4g.Core.Config.LoggerConfig.GetFiles
local LoggerContextLookupFile = "log4g/server/loggercontext/lookup_loggercontext.json"

local function IdentChk(ply)
    if not IsValid(ply) then return end
    if ply:IsAdmin() then return true end

    return false
end

AddNetworkStrsViaTbl({
    [1] = "Log4g_CLUpload_LoggerConfig",
    [2] = "Log4g_CLUpload_LoggerConfig_JSON",
    [3] = "Log4g_CLUpload_NewLevel",
    [4] = "Log4g_CLReq_Hooks",
    [5] = "Log4g_CLRcv_Hooks",
    [6] = "Log4g_CLReq_LoggerConfigs",
    [7] = "Log4g_CLRcv_LoggerConfigs",
    [8] = "Log4g_CLReq_LoggerConfig_Remove",
    [9] = "Log4g_CLReq_LoggerContext_Lookup",
    [10] = "Log4g_CLRcv_LoggerContext_Lookup",
    [11] = "Log4g_CLReq_LoggerContext_Remove",
    [12] = "Log4g_CLReq_Level_Names",
    [13] = "Log4g_CLRcv_Level_Names",
    [14] = "Log4g_CLReq_Appender_Names",
    [15] = "Log4g_CLRcv_Appender_Names",
    [16] = "Log4g_CLReq_Layout_Names",
    [17] = "Log4g_CLRcv_Layout_Names",
    [18] = "Log4g_CLReq_CFG_LoggerConfig_ColumnText",
    [19] = "Log4g_CLRcv_CFG_LoggerConfig_ColumnText",
    [20] = "Log4g_CLReq_ChkConnected",
    [21] = "Log4g_CLRcv_ChkConnected",
    [22] = "Log4g_CLReq_LoggerConfig_BuildDefault"
})

net.Receive("Log4g_CLReq_ChkConnected", function(len, ply)
    net.Start("Log4g_CLRcv_ChkConnected")
    net.WriteBool(IsValid(ply) == ply:IsConnected() == true)
    net.Send(ply)
end)

net.Receive("Log4g_CLReq_CFG_LoggerConfig_ColumnText", function(len, ply)
    net.Start("Log4g_CLRcv_CFG_LoggerConfig_ColumnText")

    net.WriteTable({"name", "eventname", "uid", "loggercontext", "level", "appender", "layout", "func"})

    net.Send(ply)
end)

SendTableAfterRcvNetMsg("Log4g_CLReq_Level_Names", "Log4g_CLRcv_Level_Names", table.Add(table.GetKeys(Log4g.Level.Standard), table.GetKeys(Log4g.Level.Custom)))
SendTableAfterRcvNetMsg("Log4g_CLReq_Appender_Names", "Log4g_CLRcv_Appender_Names", table.GetKeys(Log4g.Core.Appender))
SendTableAfterRcvNetMsg("Log4g_CLReq_Layout_Names", "Log4g_CLRcv_Layout_Names", table.GetKeys(Log4g.Core.Layout))

net.Receive("Log4g_CLReq_Hooks", function(len, ply)
    net.Start("Log4g_CLRcv_Hooks")
    WriteDataSimple(util.TableToJSON(hook.GetTable()), 16)
    net.Send(ply)
end)

net.Receive("Log4g_CLUpload_LoggerConfig", function(len, ply)
    if not IdentChk(ply) then return end
    local LoggerConfigContent = net.ReadTable()
    local LoggerContextName, LoggerConfigName = LoggerConfigContent.loggercontext, LoggerConfigContent.name
    RegisterLoggerContext(LoggerContextName)
    RegisterLoggerConfig(LoggerConfigContent)
    AddLoggerContextLookupItem(LoggerContextName, LoggerConfigName)
end)

net.Receive("Log4g_CLUpload_LoggerConfig_JSON", function(len, ply)
    if not IdentChk(ply) then return end
    local tbl = util.JSONToTable(util.Decompress(net.ReadData(net.ReadUInt(16))))
    local LoggerContextName, LoggerConfigName = tbl.loggercontext, tbl.name
    RegisterLoggerContext(LoggerContextName)
    RegisterLoggerConfig(tbl)
    AddLoggerContextLookupItem(LoggerContextName, LoggerConfigName)
end)

net.Receive("Log4g_CLReq_LoggerConfigs", function(len, ply)
    local tbl = GetLoggerConfigFiles()
    net.Start("Log4g_CLRcv_LoggerConfigs")

    if istable(tbl) and not table.IsEmpty(tbl) then
        net.WriteBool(true)
        local data = {}

        for _, v in ipairs(tbl) do
            local str = file.Read(v, "DATA")
            if not isstring(str) or #str == 0 then return end

            table.Add(data, {util.JSONToTable(str)})
        end

        WriteDataSimple(util.TableToJSON(data, true), 16)
    else
        net.WriteBool(false)
    end

    net.Send(ply)
end)

net.Receive("Log4g_CLReq_LoggerConfig_Remove", function(len, ply)
    if not IdentChk(ply) then return end
    local LoggerContextName, LoggerConfigName = net.ReadString(), net.ReadString()
    Log4g.Core.Config.LoggerConfig.Buffer[LoggerConfigName]:RemoveFile():RemoveBuffer()
    RemoveLoggerContextLookupLoggerConfig(LoggerContextName, LoggerConfigName)
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
    local LoggerContextName = net.ReadString()
    Log4g.LogManager[LoggerContextName]:Terminate()
    RemoveLoggerContextLookup(LoggerContextName)
end)

net.Receive("Log4g_CLUpload_NewLevel", function(len, ply)
    if not IdentChk(ply) then return end
    RegisterCustomLevel(net.ReadString(), net.ReadUInt(16))
end)

net.Receive("Log4g_CLReq_LoggerConfig_BuildDefault", function(len, ply)
    if not IdentChk(ply) then return end
    local LoggerContextName, LoggerConfigName = net.ReadString(), net.ReadString()
    Log4g.Core.Config.LoggerConfig.Buffer[LoggerConfigName]:BuildDefault()
    RemoveLoggerContextLookupLoggerConfig(LoggerContextName, LoggerConfigName)
end)