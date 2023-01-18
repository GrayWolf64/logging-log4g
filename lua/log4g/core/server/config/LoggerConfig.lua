--- The LoggerConfig.
-- @classmod LoggerConfig
Log4g.Core.Config = Log4g.Core.Config or {}
Log4g.Core.Config.Builder = Log4g.Core.Config.Builder or {}
Log4g.Core.Config.LoggerConfig = Log4g.Core.Config.LoggerConfig or {}
Log4g.Core.Config.LoggerConfig.Buffer = Log4g.Core.Config.LoggerConfig.Buffer or {}
local Class = include("log4g/core/impl/MiddleClass.lua")
local LoggerConfig = Class("LoggerConfig")
local HasKey = Log4g.Util.HasKey

function LoggerConfig:Initialize(name, eventname, uid, loggercontext, level, appender, layout, file, func)
    self.name = name
    self.eventname = eventname
    self.uid = uid
    self.loggercontext = loggercontext
    self.level = level
    self.appender = appender
    self.layout = layout
    self.file = file
    self.func = func
end

--- Delete the LoggerConfig.
function LoggerConfig:Delete()
    Log4g.Core.Config.LoggerConfig.Buffer[self.name] = nil
end

function Log4g.Core.Config.LoggerConfig.RegisterLoggerConfig(name, eventname, uid, loggercontext, level, appender, layout, file, func)
    if not HasKey(Log4g.Core.Config.LoggerConfig.Buffer, name) then
        local loggerconfig = LoggerConfig:New(name, eventname, uid, loggercontext, level, appender, layout, file, func)
        Log4g.Core.Config.LoggerConfig.Buffer[name] = loggerconfig

        return loggerconfig
    else
        Log4g.Core.Config.LoggerConfig.Buffer[name].eventname = eventname
        Log4g.Core.Config.LoggerConfig.Buffer[name].uid = uid
        Log4g.Core.Config.LoggerConfig.Buffer[name].loggercontext = loggercontext
        Log4g.Core.Config.LoggerConfig.Buffer[name].level = level
        Log4g.Core.Config.LoggerConfig.Buffer[name].appender = appender
        Log4g.Core.Config.LoggerConfig.Buffer[name].layout = layout
        Log4g.Core.Config.LoggerConfig.Buffer[name].file = file
        Log4g.Core.Config.LoggerConfig.Buffer[name].func = func

        return Log4g.Core.Config.LoggerConfig.Buffer[name]
    end
end