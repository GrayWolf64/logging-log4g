--- Server-side processing of the Client GUI Configurator requests.
-- @script ClientGUIConfigurator
-- @license Apache License 2.0
-- @copyright GrayWolf64
local AddNetworkStrsViaTbl = Log4g.Util.AddNetworkStrsViaTbl
local CreateLoggerContext = Log4g.API.LoggerContextFactory.GetContext
local RegisterLoggerConfig = Log4g.Core.Config.LoggerConfig.RegisterLoggerConfig
local RegisterCustomLevel = Log4g.Level.RegisterCustomLevel
local WriteDataSimple = Log4g.Util.WriteDataSimple
local GetLoggerConfig = Log4g.Core.Config.LoggerConfig.Get
local GetLoggerContext = Log4g.Core.LoggerContext.Get
local SQLQueryRow = Log4g.Util.SQLQueryRow
local SQLQueryValue = Log4g.Util.SQLQueryValue

local function IdentChk(ply)
    if not IsValid(ply) then return end
    if ply:IsAdmin() then return true end

    return false
end

AddNetworkStrsViaTbl({
    [1] = "Log4g_CLUpload_NewLevel",
    [2] = "Log4g_CLReq_LoggerConfigs",
    [3] = "Log4g_CLRcv_LoggerConfigs",
    [4] = "Log4g_CLReq_LoggerConfig_Lookup",
    [5] = "Log4g_CLRcv_LoggerConfig_Lookup",
    [6] = "Log4g_CLReq_LoggerContext_Terminate",
    [7] = "Log4g_CLReq_ChkConnected",
    [8] = "Log4g_CLRcv_ChkConnected",
    [9] = "Log4g_CLReq_LoggerContext_Lookup",
    [10] = "Log4g_CLRcv_LoggerContext_Lookup",
})

net.Receive("Log4g_CLReq_ChkConnected", function(_, ply)
    net.Start("Log4g_CLRcv_ChkConnected")
    net.WriteBool(IsValid(ply) == ply:IsConnected() == true)
    net.Send(ply)
end)

local ConfigData = {}

net.Receive("Log4g_CLReq_LoggerConfigs", function(_, ply)
    local tbl = sql.Query("SELECT * FROM Log4g_LoggerConfig")
    net.Start("Log4g_CLRcv_LoggerConfigs")

    if istable(tbl) and not table.IsEmpty(tbl) then
        if not table.IsEmpty(ConfigData) and ConfigData == tbl then
            net.WriteBool(false)
        else
            table.CopyFromTo(tbl, ConfigData)
            local data = {}

            for _, v in ipairs(tbl) do
                table.Add(data, {util.JSONToTable(v.Content)})
            end

            net.WriteBool(true)
            WriteDataSimple(util.TableToJSON(data, true), 16)
        end
    else
        net.WriteBool(false)
    end

    net.Send(ply)
end)

net.Receive("Log4g_CLReq_LoggerConfig_Lookup", function(_, ply)
    net.Start("Log4g_CLRcv_LoggerConfig_Lookup")

    if SQLQueryRow("Log4g_Lookup", "LoggerConfig") then
        net.WriteBool(true)
        WriteDataSimple(SQLQueryValue("Log4g_Lookup", "LoggerConfig"), 16)
    else
        net.WriteBool(false)
    end

    net.Send(ply)
end)

net.Receive("Log4g_CLReq_LoggerContext_Lookup", function(_, ply)
    net.Start("Log4g_CLRcv_LoggerContext_Lookup")

    if SQLQueryRow("Log4g_Lookup", "LoggerContext") then
        net.WriteBool(true)
        WriteDataSimple(SQLQueryValue("Log4g_Lookup", "LoggerContext"), 16)
    else
        net.WriteBool(false)
    end

    net.Send(ply)
end)

net.Receive("Log4g_CLReq_LoggerContext_Terminate", function(_, ply)
    if IdentChk(ply) then
        GetLoggerContext(net.ReadString()):Terminate()
    end
end)

net.Receive("Log4g_CLUpload_NewLevel", function(_, ply)
    if IdentChk(ply) then
        RegisterCustomLevel(net.ReadString(), net.ReadUInt(16))
    end
end)