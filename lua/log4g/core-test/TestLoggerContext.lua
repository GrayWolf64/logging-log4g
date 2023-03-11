local Get = Log4g.Core.LoggerContext.Get
local GetContext = Log4g.API.LoggerContextFactory.GetContext

concommand.Add("Log4g_CoreTest_CreateLoggerContext", function()
    GetContext("Foo")
    GetContext("Bar")
    PrintTable(Get("Foo"):GetConfiguration())
end)

concommand.Add("Log4g_CoreTest_RemoveLoggerContext", function()
    Get("Foo"):Terminate()
    Get("Bar"):Terminate()
end)

concommand.Add("Log4g_CoreTest_ShowAllLoggerContext", function()
    PrintTable(Log4g.Core.LoggerContext.GetAll())
end)