--- Server-side processing of the Client GUI requests.
-- @script ClientGUI
-- @license Apache License 2.0
-- @copyright GrayWolf64
local AddNetworkStrsViaTbl = Log4g.Util.AddNetworkStrsViaTbl
local GetAllCtx = Log4g.Core.LoggerContext.GetAll
local TBLHSV = table.HasValue
local pairs = pairs

AddNetworkStrsViaTbl({
    [1] = "Log4g_CLReq_ChkConnected",
    [2] = "Log4g_CLRcv_ChkConnected",
    [3] = "Log4g_CLReq_SVSummaryData",
    [4] = "Log4g_CLRcv_SVSummaryData",
    [5] = "Log4g_CLReq_SVConfigurationFiles",
    [6] = "Log4g_CLRcv_SVConfigurationFiles"
})

net.Receive("Log4g_CLReq_ChkConnected", function(_, ply)
    net.Start("Log4g_CLRcv_ChkConnected")
    net.WriteBool(IsValid(ply) == ply:IsConnected() == true)
    net.Send(ply)
end)

net.Receive("Log4g_CLReq_SVSummaryData", function(_, ply)
    net.Start("Log4g_CLRcv_SVSummaryData")
    net.WriteFloat(collectgarbage("count"))
    net.WriteUInt(ents.GetCount(), 14)
    net.WriteUInt(ents.GetEdictCount(), 13)
    net.WriteUInt(table.Count(net.Receivers), 12)
    net.WriteUInt(table.Count(debug.getregistry()), 32)
    local ConstraintCount = 0

    for _, v in pairs(ents.GetAll()) do
        ConstraintCount = ConstraintCount + table.Count(constraint.GetTable(v))
    end

    net.WriteUInt(ConstraintCount / 2, 16)
    net.WriteDouble(SysTime())
    net.Send(ply)
end)

net.Receive("Log4g_CLReq_SVConfigurationFiles", function(_, ply)
    net.Start("Log4g_CLRcv_SVConfigurationFiles")
    local map = {}

    for _, v in pairs(GetAllCtx()) do
        local path = string.sub(v:GetConfigurationSource().source, 2)

        if not TBLHSV(map, path) then
            map[path] = file.Read(path, "GAME")
        end
    end

    net.WriteTable(map)
    net.Send(ply)
end)