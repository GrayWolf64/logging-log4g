function Log4g.Core.Config.Builder.DefaultLoggerConfigBuilder(loggerconfig)
    Log4g.Logger.RegisterLogger(util.SHA1(tostring(os.time())), loggerconfig)
    hook.Add(loggerconfig.eventname, loggerconfig.uid, CompileString(loggerconfig.func))
end