--- The LoggerConfig.
-- @classmod LoggerConfig
Log4g.Core.Config = Log4g.Core.Config or {}
Log4g.Core.Config.LoggerConfig = Log4g.Core.Config.LoggerConfig or {}
Log4g.Core.Config.Builder = Log4g.Core.Config.Builder or {}
Log4g.Inst._LoggerConfigs = Log4g.Inst._LoggerConfigs or {}
local LoggerConfig = include("log4g/core/impl/Class.lua"):Extend()

function LoggerConfig:New(name, eventname, uid, loggercontext, level, appender, layout, file)
    self.name = name or ""
    self.eventname = eventname or ""
    self.uid = uid or ""
    self.loggercontext = loggercontext or ""
    self.level = level or ""
    self.appender = appender or ""
    self.layout = layout or ""
    self.file = file or ""
end

function Log4g.Core.Config.LoggerConfig.RegisterLoggerConfig(name, eventname, uid, loggercontext, level, appender, layout, file)
    local loggerconfig = LoggerConfig(name, eventname, uid, loggercontext, level, appender, layout, file)
    table.insert(Log4g.Inst._LoggerConfigs, loggerconfig)

    return loggerconfig
end