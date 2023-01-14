--- The LoggerConfig.
-- @classmod LoggerConfig
Log4g.Core.Config = Log4g.Core.Config or {}
Log4g.Core.Config.LoggerConfig = Log4g.Core.Config.LoggerConfig or {}
Log4g.Core.Config.Builder = Log4g.Core.Config.Builder or {}
Log4g.Inst._LoggerConfigs = Log4g.Inst._LoggerConfigs or {}
local LoggerConfig = include("log4g/core/impl/Class.lua"):Extend()
local HasKey = Log4g.Util.HasKey

function LoggerConfig:New(name, eventname, uid, loggercontext, level, appender, layout, file, func)
    self.name = name or ""
    self.eventname = eventname or ""
    self.uid = uid or ""
    self.loggercontext = loggercontext or ""
    self.level = level or {}
    self.appender = appender or ""
    self.layout = layout or ""
    self.file = file or ""
    self.func = func or function() end
end

--- Delete the LoggerConfig.
function LoggerConfig:Delete()
    Log4g.Inst._LoggerConfigs[self.name] = nil
end

function Log4g.Core.Config.LoggerConfig.RegisterLoggerConfig(name, eventname, uid, loggercontext, level, appender, layout, file, func)
    if not HasKey(Log4g.Inst._LoggerConfigs, name) then
        local loggerconfig = LoggerConfig(name, eventname, uid, loggercontext, level, appender, layout, file)
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