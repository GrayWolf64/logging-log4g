--- Server-side processing of the Client GUI requests.
-- @script ClientGUIConfigurator.lua
-- @license Apache License 2.0
-- @copyright GrayWolf64
local AddNetworkStrsViaTbl = Log4g.Util.AddNetworkStrsViaTbl
local SendTableAfterRcvNetMsg = Log4g.Util.SendTableAfterRcvNetMsg
local RegisterLoggerContext = Log4g.Core.LoggerContext.RegisterLoggerContext
local RegisterLoggerConfig = Log4g.Core.Config.LoggerConfig.RegisterLoggerConfig
local RegisterCustomLevel = Log4g.Level.RegisterCustomLevel
local AddLoggerContextLookup = Log4g.Core.LoggerContext.Lookup.Add
local LoggerContextLookupFile = "log4g/server/loggercontext/loggercontext_lookup.json"

local function IdentChk(ply)
    if not IsValid(ply) then return end
    if ply:IsAdmin() then return true end

    return false
end

AddNetworkStrsViaTbl({
    ["Log4g_CLUpload_LoggerConfig"] = true,
    ["Log4g_CLReq_Hooks"] = true,
    ["Log4g_CLRcv_Hooks"] = true,
    ["Log4g_CLReq_LoggerConfigs"] = true,
    ["Log4g_CLRcv_LoggerConfigs"] = true,
    ["Log4g_CLReq_LoggerConfig_Remove"] = true,
    ["Log4g_CLReq_LoggerContext_Lookup"] = true,
    ["Log4g_CLRcv_LoggerContext_Lookup"] = true,
    ["Log4g_CLReq_LoggerContext_Remove"] = true,
    ["Log4g_CLReq_Levels"] = true,
    ["Log4g_CLRcv_Levels"] = true,
    ["Log4g_CLReq_Appenders"] = true,
    ["Log4g_CLRcv_Appenders"] = true,
    ["Log4g_CLReq_Layouts"] = true,
    ["Log4g_CLRcv_Layouts"] = true,
    ["Log4g_CLReq_LoggerConfig_Keys"] = true,
    ["Log4g_CLRcv_LoggerConfig_Keys"] = true,
    ["Log4g_CL_ChkConnected"] = true,
    ["Log4g_CL_IsConnected"] = true,
    ["Log4g_CLUpload_NewLevel"] = true,
    ["Log4g_CL_PendingTransmission_DPropLoggerConfigMessages"] = true,
    ["Log4g_CLReq_LoggerConfig_BuildDefault"] = true
})

net.Receive("Log4g_CL_ChkConnected", function(len, ply)
    net.Start("Log4g_CL_IsConnected")
    net.WriteBool(IsValid(ply) == ply:IsConnected() == true)
    net.Send(ply)
end)

net.Receive("Log4g_CLReq_LoggerConfig_Keys", function(len, ply)
    net.Start("Log4g_CLRcv_LoggerConfig_Keys")

    net.WriteTable({"name", "eventname", "uid", "loggercontext", "level", "appender", "layout", "func"})

    net.Send(ply)
end)

net.Receive("Log4g_CL_PendingTransmission_DPropLoggerConfigMessages", function()
    SendTableAfterRcvNetMsg("Log4g_CLReq_Levels", "Log4g_CLRcv_Levels", table.Add(table.GetKeys(Log4g.Level.Standard), table.GetKeys(Log4g.Level.Custom)))
    SendTableAfterRcvNetMsg("Log4g_CLReq_Appenders", "Log4g_CLRcv_Appenders", table.GetKeys(Log4g.Core.Appender.Buffer))
    SendTableAfterRcvNetMsg("Log4g_CLReq_Layouts", "Log4g_CLRcv_Layouts", table.GetKeys(Log4g.Core.Layout.Buffer))
end)

net.Receive("Log4g_CLReq_Hooks", function(len, ply)
    net.Start("Log4g_CLRcv_Hooks")
    local Data = util.Compress(util.TableToJSON(hook.GetTable()))
    local Len = #Data
    net.WriteUInt(Len, 16)
    net.WriteData(Data, Len)
    net.Send(ply)
end)

net.Receive("Log4g_CLUpload_LoggerConfig", function(len, ply)
    if not IdentChk(ply) then return end
    local LoggerConfigContent = net.ReadTable()
    local LoggerContextName, LoggerConfigName = LoggerConfigContent.loggercontext, LoggerConfigContent.name
    RegisterLoggerContext(LoggerContextName)
    RegisterLoggerConfig(LoggerConfigContent)
    AddLoggerContextLookup(LoggerContextName, LoggerConfigName)
end)

net.Receive("Log4g_CLReq_LoggerConfigs", function(len, ply)
    local Tbl = {}
    local _, Folders = file.Find("log4g/server/loggercontext/*", "DATA")

    for _, v in pairs(Folders) do
        local Files, _ = file.Find("log4g/server/loggercontext/" .. v .. "/loggerconfig/*.json", "DATA")

        for _, j in pairs(Files) do
            table.insert(Tbl, "log4g/server/loggercontext/" .. v .. "/loggerconfig/" .. j)
        end
    end

    local Data = {}

    for _, v in ipairs(Tbl) do
        table.Add(Data, {util.JSONToTable(file.Read(v, "DATA"))})
    end

    net.Start("Log4g_CLRcv_LoggerConfigs")
    local Str = util.Compress(util.TableToJSON(Data, true))
    local Len = #Str
    net.WriteUInt(Len, 16)
    net.WriteData(Str, Len)
    net.Send(ply)
end)

net.Receive("Log4g_CLReq_LoggerConfig_Remove", function(len, ply)
    if not IdentChk(ply) then return end
    local LoggerContextName = net.ReadString()
    local LoggerConfigName = net.ReadString()

    for k, _ in pairs(Log4g.Core.Config.LoggerConfig.Buffer) do
        if k == LoggerConfigName then
            Log4g.Core.Config.LoggerConfig.Buffer[k]:Remove()
        end
    end

    local Tbl = util.JSONToTable(file.Read(LoggerContextLookupFile, "DATA"))

    for k, v in pairs(Tbl) do
        if k == LoggerContextName then
            for i, j in ipairs(v) do
                if j == LoggerConfigName then
                    table.remove(v, i)
                end
            end
        end
    end

    file.Write(LoggerContextLookupFile, util.TableToJSON(Tbl))
end)

net.Receive("Log4g_CLReq_LoggerContext_Lookup", function(len, ply)
    net.Start("Log4g_CLRcv_LoggerContext_Lookup")

    if file.Exists(LoggerContextLookupFile, "DATA") then
        net.WriteBool(true)
        local Str = util.Compress(file.Read(LoggerContextLookupFile, "DATA"))
        local Len = #Str
        net.WriteUInt(Len, 16)
        net.WriteData(Str, Len)
    else
        net.WriteBool(false)
    end

    net.Send(ply)
end)

net.Receive("Log4g_CLReq_LoggerContext_Remove", function(len, ply)
    if not IdentChk(ply) then return end
    local LoggerContextName = net.ReadString()

    for k, _ in pairs(Log4g.Hierarchy) do
        if k == LoggerContextName then
            Log4g.Hierarchy[k]:Terminate()
        end
    end

    local Tbl = util.JSONToTable(file.Read(LoggerContextLookupFile, "DATA"))

    for k, _ in pairs(Tbl) do
        if k == LoggerContextName then
            Tbl[k] = nil
        end
    end

    file.Write(LoggerContextLookupFile, util.TableToJSON(Tbl))
end)

net.Receive("Log4g_CLUpload_NewLevel", function(len, ply)
    if not IdentChk(ply) then return end
    RegisterCustomLevel(net.ReadString(), net.ReadUInt(16))
end)

net.Receive("Log4g_CLReq_LoggerConfig_BuildDefault", function(len, ply)
    local LoggerContextName = net.ReadString()
    local LoggerConfigName = net.ReadString()
    Log4g.Core.Config.LoggerConfig.Buffer[LoggerConfigName]:GoToState("STARTED")
    Log4g.Core.Config.Builder.DefaultLoggerConfigBuilder(Log4g.Core.Config.LoggerConfig.Buffer[LoggerConfigName])
    Log4g.Core.Config.LoggerConfig.Buffer[LoggerConfigName]:Remove()
    local Tbl = util.JSONToTable(file.Read(LoggerContextLookupFile, "DATA"))

    for k, v in pairs(Tbl) do
        if k == LoggerContextName then
            for i, j in ipairs(v) do
                if j == LoggerConfigName then
                    table.remove(v, i)
                end
            end
        end
    end

    file.Write(LoggerContextLookupFile, util.TableToJSON(Tbl))
end)