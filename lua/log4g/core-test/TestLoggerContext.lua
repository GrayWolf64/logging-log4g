local LoggerContext = Log4g.GetPackageClassFuncs("log4g-core", "LoggerContext")
local Get = LoggerContext.get
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
    PrintTable(LoggerContext.getAll())
end)