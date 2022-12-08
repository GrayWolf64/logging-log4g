if CLIENT then return end

Log4g.Util.AddNetworkStrsViaTbl({
    [1] = "Log4g_CLReq_Layouts",
    [2] = "Log4g_CLRcv_Layouts"
})

local Layouts = {
    [1] = "Basic Text"
}

Log4g.Util.SendTableAfterRcvNetMsg("Log4g_CLReq_Layouts", "Log4g_CLRcv_Layouts", Layouts)