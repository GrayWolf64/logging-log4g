function Log4g.Core.Config.Builder.DefaultLoggerConfigBuilder(loggerconfig)
    Log4g.Logger.RegisterLogger(loggerconfig.name, loggerconfig)
    hook.Add(loggerconfig.eventname, loggerconfig.uid, CompileString(loggerconfig.func))
end