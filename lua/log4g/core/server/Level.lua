if CLIENT then return end

Log4g.Util.AddNetworkStrsViaTbl({
    [1] = "Log4g_CLReq_LogLevels_SV",
    [2] = "Log4g_CLRcv_LogLevels_SV"
})

Log4g.Level = {
    ["ALL"] = {
        int = math.huge,
        standard = true
    },
    ["TRACE"] = {
        int = 600,
        standard = true
    },
    ["DEBUG"] = {
        int = 500,
        standard = true
    },
    ["INFO"] = {
        int = 400,
        standard = true
    },
    ["WARN"] = {
        int = 300,
        standard = true
    },
    ["ERROR"] = {
        int = 200,
        standard = true
    },
    ["FATAL"] = {
        int = 100,
        standard = true
    },
    ["OFF"] = {
        int = 0,
        standard = true
    },
    IntLevel = function(name) return Log4g.Level[name].int end,
    AddCustomLevel = function(name, int)
        Log4g.Level[name] = {
            int = int,
            standard = false
        }
    end
}

local Levels = {}

for k, _ in pairs(Log4g.Level) do
    table.insert(Levels, k)
end

Log4g.Util.SendTableAfterRcvNetMsg("Log4g_CLReq_LogLevels_SV", "Log4g_CLRcv_LogLevels_SV", Levels)