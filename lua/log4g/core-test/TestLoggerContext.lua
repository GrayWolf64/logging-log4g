local Get = include("log4g/core/LoggerContext.lua").Get
local GetContext = Log4g.API.LoggerContextFactory.GetContext

concommand.Add("log4g_coretest_createLoggerContext", function()
    GetContext("X", false)
    GetContext("Y", false)
end)

concommand.Add("log4g_coretest_removeLoggerContext", function()
    Get("X"):Terminate()
    Get("Y"):Terminate()
end)

concommand.Add("log4g_coretest_showAllLoggerContext", function()
    PrintTable(include("log4g/core/LoggerContext.lua").GetAll())
end)