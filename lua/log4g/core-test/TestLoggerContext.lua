local Get = Log4g.Core.LoggerContext.Get
local GetContext = Log4g.API.LoggerContextFactory.GetContext

concommand.Add("Log4g_CoreTest_CreateLoggerContext", function()
    GetContext("Foo")
    GetContext("Bar", false)
    print("is 'Foo' Configuration created: ", Get("Foo"):GetConfiguration() ~= nil)
    print("is 'Bar' Configuration created: ", Get("Bar"):GetConfiguration() ~= nil)
end)

concommand.Add("Log4g_CoreTest_RemoveLoggerContext", function()
    Get("Foo"):Terminate()
    Get("Bar"):Terminate()
end)

concommand.Add("Log4g_CoreTest_ShowAllLoggerContext", function()
    PrintTable(Log4g.Core.LoggerContext.GetAll())
end)