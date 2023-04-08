local Get = Log4g.Core.LoggerContext.Get
local GetContext = Log4g.API.LoggerContextFactory.GetContext

concommand.Add("log4g_coretest_createLoggerContext", function()
    GetContext("X")
    GetContext("Y", false)
end)

concommand.Add("log4g_coretest_removeLoggerContext", function()
    Get("X"):Terminate()
    Get("Y"):Terminate()
end)

concommand.Add("log4g_coretest_showAllLoggerContext", function()
    PrintTable(Log4g.Core.LoggerContext.GetAll())
end)