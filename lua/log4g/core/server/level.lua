if CLIENT then return end

local LEVELS = {
    [1] = "ALL",
    [2] = "TRACE",
    [3] = "DEBUG",
    [4] = "INFO",
    [5] = "WARN",
    [6] = "ERROR",
    [7] = "FATAL",
    [8] = "OFF"
}

Log4g.Util.SendTableAfterRcvNetMsg("Log4g_CLReq_LogLevels_SV", "Log4g_CLRcv_LogLevels_SV", LEVELS)

Log4g.Level = {
    ObtainLevel = function(name)
        for k, v in pairs(LEVELS) do
            if v == name then return k, name end
        end
    end
}