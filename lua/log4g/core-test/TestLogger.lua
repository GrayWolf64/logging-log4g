concommand.Add("Log4g_CoreTest_CreateLogger", function()
    Log4g.API.LogManager.GetLogger("TestLoggerA")
end)

concommand.Add("Log4g_CoreTest_ShowAllLogger", function()
    PrintTable(Log4g.Core.Logger.GetAll())
end)