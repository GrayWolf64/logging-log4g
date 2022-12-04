if CLIENT then return end

Log4g.Util.AddNetworkStrsViaTbl({
    [1] = "Log4g_CLReq_Appenders_SV",
    [2] = "Log4g_CLRcv_Appenders_SV"
})

local APPENDERS = {
    [1] = "Engine Console"
}

Log4g.Util.SendTableAfterRcvNetMsg("Log4g_CLReq_Appenders_SV", "Log4g_CLRcv_Appenders_SV", APPENDERS)