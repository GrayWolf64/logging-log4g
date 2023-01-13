local AddNetworkStrsViaTbl = Log4g.Util.AddNetworkStrsViaTbl

AddNetworkStrsViaTbl({
    ["Log4g_CLReq_SVSummaryData"] = true,
    ["Log4g_CLRcv_SVSummaryData"] = true
})

util.AddNetworkString("Log4g_CLReq_SVSummaryData")

net.Receive("Log4g_CLReq_SVSummaryData", function(len, ply)
    net.Start("Log4g_CLRcv_SVSummaryData")
    net.Send(ply)
end)