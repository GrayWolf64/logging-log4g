--- The LoggerConfig.
-- @classmod LoggerConfig
Log4g.Core.Config = Log4g.Core.Config or {}
Log4g.Core.Config.Builder = Log4g.Core.Config.Builder or {}
Log4g.Core.Config.LoggerConfig = Log4g.Core.Config.LoggerConfig or {}
Log4g.Core.Config.LoggerConfig.Buffer = Log4g.Core.Config.LoggerConfig.Buffer or {}
local Class = include("log4g/core/impl/MiddleClass.lua")
local LoggerConfig = Class("LoggerConfig")
local HasKey = Log4g.Util.HasKey

function LoggerConfig:Initialize(tbl)
    self.name = tbl.name
    self.eventname = tbl.eventname
    self.uid = tbl.uid
    self.loggercontext = tbl.loggercontext
    self.level = tbl.level
    self.appender = tbl.appender
    self.layout = tbl.layout
    self.file = "log4g/server/loggercontext/" .. tbl.loggercontext .. "/loggerconfig/" .. tbl.name .. ".json"
    self.func = tbl.func
end

--- Delete the LoggerConfig.
function LoggerConfig:Delete()
    Log4g.Core.Config.LoggerConfig.Buffer[self.name] = nil
end

function Log4g.Core.Config.LoggerConfig.RegisterLoggerConfig(tbl)
    if not HasKey(Log4g.Core.Config.LoggerConfig.Buffer, tbl.name) then
        local loggerconfig = LoggerConfig:New(tbl)
        Log4g.Core.Config.LoggerConfig.Buffer[tbl.name] = loggerconfig
        file.Write(loggerconfig.file, util.TableToJSON(tbl, true))

        return loggerconfig
    else
        return Log4g.Core.Config.LoggerConfig.Buffer[tbl.name]
    end
end