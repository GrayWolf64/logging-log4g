if CLIENT then return end

Log4g.Util.AddNetworkStrsViaTbl({
    [1] = "Log4g_CLReq_Appenders",
    [2] = "Log4g_CLRcv_Appenders"
})

local Appenders = {
    [1] = "Engine Console"
}

Log4g.Util.SendTableAfterRcvNetMsg("Log4g_CLReq_Appenders", "Log4g_CLRcv_Appenders", Appenders)