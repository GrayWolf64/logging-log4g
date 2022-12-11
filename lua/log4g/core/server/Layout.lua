Log4g.Layouts = {}
local AddNetworkStrsViaTbl = Log4g.Util.AddNetworkStrsViaTbl

AddNetworkStrsViaTbl({
    [1] = "Log4g_CLReq_Layouts",
    [2] = "Log4g_CLRcv_Layouts"
})

local Layouts = {
    [1] = "Basic Text"
}

Log4g.Util.SendTableAfterRcvNetMsg("Log4g_CLReq_Layouts", "Log4g_CLRcv_Layouts", Layouts)