concommand.Add("Log4g_CoreTest_CreateLogger", function()
    local ctx = Log4g.API.LoggerContextFactory.GetContext("TestLoggerHierarchyCtx")
    Log4g.Core.Logger.Create("A", ctx, Log4g.Level.GetLevel("ALL"))
    Log4g.Core.Logger.Create("A.B", ctx, Log4g.Level.GetLevel("ALL"))
    Log4g.Core.Logger.Create("A.B.C", ctx, Log4g.Level.GetLevel("ALL"))
    Log4g.Core.Logger.Create("A.B.C.D", ctx, Log4g.Level.GetLevel("ALL"))
    local AB = ctx:GetLogger("A.B")
    local ABC = ctx:GetLogger("A.B.C")
    local ABCD = ctx:GetLogger("A.B.C.D")
    print("A.B's parent: " .. AB:GetLoggerConfig():GetParent())
    print("A.B.C's parent: " .. ABC:GetLoggerConfig():GetParent())
    print("A.B.C.D's parent: " .. ABCD:GetLoggerConfig():GetParent())

    print(ABC:GetLoggerConfig():AddAppender({
        name = "simulatedappender"
    }))

    PrintTable(Log4g.Core.LoggerContext.Get("TestLoggerHierarchyCtx"):GetConfiguration():GetAppenders())
end)