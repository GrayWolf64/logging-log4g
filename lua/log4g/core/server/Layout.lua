if CLIENT then return end

Log4g.Util.AddNetworkStrsViaTbl({
    [1] = "Log4g_CLReq_Layouts_SV",
    [2] = "Log4g_CLRcv_Layouts_SV"
})

local LAYOUTS = {
    [1] = "Basic Text"
}

Log4g.Util.SendTableAfterRcvNetMsg("Log4g_CLReq_Layouts_SV", "Log4g_CLRcv_Layouts_SV", LAYOUTS)