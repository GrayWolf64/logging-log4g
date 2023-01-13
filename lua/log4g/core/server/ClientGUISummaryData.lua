local AddNetworkStrsViaTbl = Log4g.Util.AddNetworkStrsViaTbl

AddNetworkStrsViaTbl({
    ["Log4g_CLReq_SVSummaryData"] = true,
    ["Log4g_CLRcv_SVSummaryData"] = true
})

net.Receive("Log4g_CLReq_SVSummaryData", function(len, ply)
    net.Start("Log4g_CLRcv_SVSummaryData")
    net.WriteFloat(collectgarbage("count"))
    net.WriteUInt(ents.GetCount(), 14)
    net.WriteUInt(ents.GetEdictCount(), 13)
    net.Send(ply)
end)