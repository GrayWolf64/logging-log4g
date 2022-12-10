Log4g.Levels = {}
local AddNetworkStrsViaTbl = Log4g.Util.AddNetworkStrsViaTbl

AddNetworkStrsViaTbl({
    [1] = "Log4g_CLReq_Levels",
    [2] = "Log4g_CLRcv_Levels"
})

local Object = include("log4g/core/server/Class.lua")
local Level = Object:Extend()

function Level:New(name, int)
    self.name = name or ""
    self.int = int or 0
end

function Level:Delete()
    self.name = nil
    self.int = nil
end

function Level:Name()
    return self.name
end

function Level:IntLevel()
    return self.int
end

function Log4g.NewLevel(name, int)
    return Level(name, int)
end

Log4g.Levels["ALL"] = Level("ALL", math.huge)
Log4g.Levels["TRACE"] = Level("TRACE", 600)
Log4g.Levels["DEBUG"] = Level("DEBUG", 500)
Log4g.Levels["INFO"] = Level("INFO", 400)
Log4g.Levels["WARN"] = Level("WARN", 300)
Log4g.Levels["ERROR"] = Level("ERROR", 200)
Log4g.Levels["FATAL"] = Level("FATAL", 100)
Log4g.Levels["OFF"] = Level("OFF", 0)
local Levels = {}

for k, _ in pairs(Log4g.Levels) do
    table.insert(Levels, k)
end

Log4g.Util.SendTableAfterRcvNetMsg("Log4g_CLReq_Levels", "Log4g_CLRcv_Levels", Levels)