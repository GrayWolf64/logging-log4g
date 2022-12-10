local AddNetworkStrsViaTbl = Log4g.Util.AddNetworkStrsViaTbl

AddNetworkStrsViaTbl({
    [1] = "Log4g_CLReq_Appenders",
    [2] = "Log4g_CLRcv_Appenders"
})

local Appenders = {
    [1] = "Engine Console"
}

Log4g.Util.SendTableAfterRcvNetMsg("Log4g_CLReq_Appenders", "Log4g_CLRcv_Appenders", Appenders)