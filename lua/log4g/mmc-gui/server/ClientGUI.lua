--- Server-side processing of the Client GUI requests.
-- @script ClientGUI
-- @license Apache License 2.0
-- @copyright GrayWolf64
local NetUtil = include("log4g/core/util/NetUtil.lua")
local AddNetworkStrsViaTbl, WriteDataSimple = NetUtil.AddNetworkStrsViaTbl, NetUtil.WriteDataSimple
local GetAllCtx = Log4g.Core.LoggerContext.GetAll
local pairs = pairs
local tableCount = table.Count
local tableToJson = util.TableToJSON
local fileRead = file.Read
local getConstraintTable = constraint.GetTable
local netReceive, netStart = net.Receive, net.Start
local netSend = net.Send
local netWriteUInt, netWriteBool = net.WriteUInt, net.WriteBool
local netWriteDouble, netWriteFloat = net.WriteDouble, net.WriteFloat
local netWriteString = net.WriteString

AddNetworkStrsViaTbl({
    [1] = "Log4g_CLReq_ChkConnected",
    [2] = "Log4g_CLRcv_ChkConnected",
    [3] = "Log4g_CLReq_SVSummaryData",
    [4] = "Log4g_CLRcv_SVSummaryData",
    [5] = "Log4g_CLReq_SVConfigurationFiles",
    [6] = "Log4g_CLRcv_SVConfigurationFiles"
})

netReceive("Log4g_CLReq_ChkConnected", function(_, ply)
    netStart("Log4g_CLRcv_ChkConnected", true)
    netWriteBool(IsValid(ply) == ply:IsConnected() == true)
    netSend(ply)
end)

netReceive("Log4g_CLReq_SVSummaryData", function(_, ply)
    netStart("Log4g_CLRcv_SVSummaryData", true)
    netWriteFloat(collectgarbage("count"))
    netWriteUInt(ents.GetCount(), 14)
    netWriteUInt(ents.GetEdictCount(), 13)
    netWriteUInt(tableCount(net.Receivers), 12)
    netWriteUInt(tableCount(debug.getregistry()), 32)
    local constraintcount = 0

    for _, v in pairs(ents.GetAll()) do
        constraintcount = constraintcount + tableCount(getConstraintTable(v))
    end

    netWriteUInt(constraintcount / 2, 16)
    netWriteDouble(SysTime())
    netWriteUInt(tableCount(_G), 32)
    netWriteString(Log4g.getCurrentLoggingImpl())
    netWriteUInt(tableCount(GetAllCtx()), 16)
    netSend(ply)
end)

netReceive("Log4g_CLReq_SVConfigurationFiles", function(_, ply)
    netStart("Log4g_CLRcv_SVConfigurationFiles", true)
    local map = {}

    for _, v in pairs(GetAllCtx()) do
        local src = v:GetConfigurationSource()

        if src then
            local path = v:GetConfigurationSource().source:sub(2)

            if not map[path] then
                map[path] = fileRead(path, "GAME")
            end
        end
    end

    WriteDataSimple(tableToJson(map), 32)
    netSend(ply)
end)