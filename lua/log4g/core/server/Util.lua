if CLIENT then return end

Log4g.Util = {
    HasKey = function(tbl, key)
        if tbl == nil then return false end

        for k, _ in pairs(tbl) do
            if k == key then return true, k end
        end

        return false
    end,
    SendTableAfterRcvNetMsg = function(receive, start, tbl)
        net.Receive(receive, function(len, ply)
            net.Start(start)
            net.WriteTable(tbl)
            net.Send(ply)
        end)
    end,
    AddNetworkStrsViaTbl = function(tbl)
        for _, v in pairs(tbl) do
            util.AddNetworkString(v)
        end
    end
}