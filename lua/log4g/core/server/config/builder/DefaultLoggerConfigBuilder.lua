function Log4g.Core.Config.Builder.DefaultLoggerConfigBuilder(tbl)
    Log4g.Logger.RegisterLogger(tostring(os.time()), tbl)
end