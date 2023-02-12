concommand.Add("Log4g_CoreTest_CreateLogger", function()
    local function CreateLogger()
        Log4g.API.LoggerContextFactory.GetContext(CreateLogger)
        Log4g.API.LogManager.GetLogger("TestLoggerA")
        Log4g.Core.Logger.Get("TestLoggerA"):SetLevel(Log4g.Level.GetStdLevel().INFO)
        Log4g.Core.Logger.Get("TestLoggerA"):INFO("Test message from 'TestLoggerA'.\n")
    end

    CreateLogger()
end)

concommand.Add("Log4g_CoreTest_ShowAllLogger", function()
    PrintTable(Log4g.Core.Logger.GetAll())
end)

concommand.Add("Log4g_CoreTest_ShowAllLoggerConfig", function()
    PrintTable(Log4g.Core.Config.LoggerConfig.GetAll())
end)