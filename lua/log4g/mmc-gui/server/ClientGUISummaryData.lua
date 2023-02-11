local AddNetworkStrsViaTbl = Log4g.Util.AddNetworkStrsViaTbl

AddNetworkStrsViaTbl({
    [1] = "Log4g_CLReq_SVSummaryData",
    [2] = "Log4g_CLRcv_SVSummaryData",
})

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
    net.Send(ply)
end)