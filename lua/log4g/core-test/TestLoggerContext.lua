concommand.Add("Log4g_CoreTest_CreateLoggerContext", function()
    local GetContext = Log4g.API.LoggerContextFactory.GetContext

    for i = 1, 10 do
        GetContext(tostring(i))
    end
end)

concommand.Add("Log4g_CoreTest_RemoveLoggerContext", function()
    local Get = Log4g.Core.LoggerContext.Get

    for i = 1, 10 do
        Get(tostring(i)):Terminate()
    end
end)

concommand.Add("Log4g_CoreTest_ShowAllLoggerContext", function()
    PrintTable(Log4g.Core.LoggerContext.GetAll())
end)