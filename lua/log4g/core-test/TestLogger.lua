concommand.Add("Log4g_CoreTest_LoggerConfigHierarchy", function()
    local ctx = Log4g.API.LoggerContextFactory.GetContext("TestLoggerHierarchyCtx")
    PrintTable(ctx:GetConfigurationSource())
    Log4g.Core.Logger.Create("foo", ctx, Log4g.Level.GetLevel("ALL"), true)
    Log4g.Core.Logger.Create("foo.bar", ctx, Log4g.Level.GetLevel("ALL"), true)
    Log4g.Core.Logger.Create("foo.bar.quiz", ctx, Log4g.Level.GetLevel("ALL"), true)
    Log4g.Core.Logger.Create("foo.bar.quiz.void", ctx, Log4g.Level.GetLevel("INFO"), true)
    local F = ctx:GetLogger("foo")
    local FB = ctx:GetLogger("foo.bar")
    local FBQ = ctx:GetLogger("foo.bar.quiz")
    local FBQV = ctx:GetLogger("foo.bar.quiz.void")
    print("foo's parent: " .. F:GetLoggerConfig():GetParent())
    print("foo.bar's parent: " .. FB:GetLoggerConfig():GetParent())
    print("foo.bar.quiz's parent: " .. FBQ:GetLoggerConfig():GetParent())
    print("foo.bar.quiz.void's parent: " .. FBQV:GetLoggerConfig():GetParent())
    print("appender 'uni' added: " .. tostring(FBQ:GetLoggerConfig():AddAppender(Log4g.Core.Appender.CreateConsoleAppender("uni"))))
    print("appender 'hcl' added: " .. tostring(FBQ:GetLoggerConfig():AddAppender(Log4g.Core.Appender.CreateConsoleAppender("hcl"))))
    print("foo.bar.quiz.void's level: " .. FBQV:GetLoggerConfig():GetLevel().name)
end)