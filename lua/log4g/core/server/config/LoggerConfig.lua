Log4g.LoggerConfigs = {}
local Object = include("log4g/core/server/Class.lua")
local LoggerConfig = Object:Extend()

function LoggerConfig:New(name, file)
    self.name = name or ""
    self.file = file or ""
end

function LoggerConfig:Delete()
    self.name = nil
    self.file = nil
end

function Log4g.NewLoggerConfig(name, file)
    return LoggerConfig(name, file)
end