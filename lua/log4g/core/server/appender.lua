if CLIENT then return end

local APPENDERS = {
    [1] = "Engine Console"
}

Log4g.Util.SendTableAfterRcvNetMsg("Log4g_CLReq_Appenders_SV", "Log4g_CLRcv_Appenders_SV", APPENDERS)