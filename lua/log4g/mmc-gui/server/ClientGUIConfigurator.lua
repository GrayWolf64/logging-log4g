--- Server-side processing of the Client GUI Configurator requests.
-- @script ClientGUIConfigurator
-- @license Apache License 2.0
-- @copyright GrayWolf64
local AddNetworkStrsViaTbl = Log4g.Util.AddNetworkStrsViaTbl

AddNetworkStrsViaTbl({
    [1] = "Log4g_CLReq_ChkConnected",
    [2] = "Log4g_CLRcv_ChkConnected",
})

net.Receive("Log4g_CLReq_ChkConnected", function(_, ply)
    net.Start("Log4g_CLRcv_ChkConnected")
    net.WriteBool(IsValid(ply) == ply:IsConnected() == true)
    net.Send(ply)
end)