local function CreateContext()
    Log4g.API.LoggerContextFactory.GetContext(CreateContext)
end

concommand.Add("Log4g_CoreTest_CreateLoggerContext", function()
    CreateContext()
end)

concommand.Add("Log4g_CoreTest_RemoveLoggerContext", function()
    Log4g.Core.LoggerContext.Get(Log4g.Util.GetCurrentFQSN(CreateContext)):Terminate()
end)

concommand.Add("Log4g_CoreTest_ShowAllLoggerContext", function()
    PrintTable(Log4g.Core.LoggerContext.GetAll())
end)