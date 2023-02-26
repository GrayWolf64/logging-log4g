concommand.Add("Log4g_CoreTest_CreateLoggerContext", function()
    local GetContext = Log4g.API.LoggerContextFactory.GetContext

    for i = 1, 10 do
        GetContext(tostring(i))
    end
end)

concommand.Add("Log4g_CoreTest_RemoveLoggerContext", function()
    Log4g.Core.LoggerContext.Get(Log4g.Util.GetCurrentFQSN(CreateContext)):Terminate()
end)

concommand.Add("Log4g_CoreTest_ShowAllLoggerContext", function()
    PrintTable(Log4g.Core.LoggerContext.GetAll())
end)