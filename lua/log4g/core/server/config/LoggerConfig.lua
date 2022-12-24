Log4g.LoggerConfigs = {}
local LoggerConfig = include("log4g/core/server/impl/Class.lua"):Extend()

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

function Log4g.Registrar.RegisterLoggerConfig(name, eventname, uid, loggercontext, level, appender, layout, file)
    local loggerconfig = LoggerConfig(name, eventname, uid, loggercontext, level, appender, layout, file)
    table.insert(Log4g.LoggerConfigs, loggerconfig)

    return loggerconfig
end