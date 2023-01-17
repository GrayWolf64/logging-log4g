--- The LoggerConfig.
-- @classmod LoggerConfig
Log4g.Core.Config = Log4g.Core.Config or {}
Log4g.Core.Config.LoggerConfig = Log4g.Core.Config.LoggerConfig or {}
Log4g.Core.Config.Builder = Log4g.Core.Config.Builder or {}
Log4g.Inst._LoggerConfigs = Log4g.Inst._LoggerConfigs or {}
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
    Log4g.Inst._LoggerConfigs[self.name] = nil
end

function Log4g.Core.Config.LoggerConfig.RegisterLoggerConfig(name, eventname, uid, loggercontext, level, appender, layout, file, func)
    if not HasKey(Log4g.Inst._LoggerConfigs, name) then
        local loggerconfig = LoggerConfig:New(name, eventname, uid, loggercontext, level, appender, layout, file)
        Log4g.Inst._LoggerConfigs[name] = loggerconfig

        return loggerconfig
    else
        Log4g.Inst._LoggerConfigs[name].eventname = eventname
        Log4g.Inst._LoggerConfigs[name].uid = uid
        Log4g.Inst._LoggerConfigs[name].loggercontext = loggercontext
        Log4g.Inst._LoggerConfigs[name].level = level
        Log4g.Inst._LoggerConfigs[name].appender = appender
        Log4g.Inst._LoggerConfigs[name].layout = layout
        Log4g.Inst._LoggerConfigs[name].file = file
        Log4g.Inst._LoggerConfigs[name].func = func

        return Log4g.Inst._LoggerConfigs[name]
    end
end