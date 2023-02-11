concommand.Add("Log4g_CoreTest_CreateLoggerContext", function()
    Log4g.Core.LoggerContext.Register("TestContextA")
    Log4g.Core.LoggerContext.Register("TestContextB")
end)

concommand.Add("Log4g_CoreTest_RemoveLoggerContext", function()
    Log4g.Core.LoggerContext.Get("TestContextA"):Terminate()
    Log4g.Core.LoggerContext.Get("TestContextB"):Terminate()
end)

concommand.Add("Log4g_CoreTest_ShowAllLoggerContext", function()
    PrintTable(Log4g.Core.LoggerContext.GetAll())
end)