local AddNetworkStrsViaTbl = Log4g.Util.AddNetworkStrsViaTbl

AddNetworkStrsViaTbl({
    [1] = "Log4g_CLReq_Levels",
    [2] = "Log4g_CLRcv_Levels"
})

local MetaLevel = {
    __index = {
        int = 0,
        standard = true
    },
    __call = function() return __index.int, __index.standard end
}

Log4g.Level = {
    ["ALL"] = {
        int = math.huge,
    },
    ["TRACE"] = {
        int = 600,
    },
    ["DEBUG"] = {
        int = 500,
    },
    ["INFO"] = {
        int = 400,
    },
    ["WARN"] = {
        int = 300,
    },
    ["ERROR"] = {
        int = 200,
    },
    ["FATAL"] = {
        int = 100,
    },
    ["OFF"] = {
        int = 0,
    },
    IntLevel = function(name) return Log4g.Level[name].int end,
    AddCustomLevel = function(name, int)
        Log4g.Level[name] = {
            int = int,
            standard = false
        }
    end
}

setmetatable(Log4g.Level["ALL"], MetaLevel)

local function GetStringLevels()
    local levels = {}

    for k, v in pairs(Log4g.Level) do
        if istable(v) then
            table.insert(levels, k)
        end
    end

    return levels
end

Log4g.Util.SendTableAfterRcvNetMsg("Log4g_CLReq_Levels", "Log4g_CLRcv_Levels", GetStringLevels())