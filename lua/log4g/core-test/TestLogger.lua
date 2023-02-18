concommand.Add("Log4g_CoreTest_CreateLogger", function()
    local function CreateLogger()
        local ctx = Log4g.API.LoggerContextFactory.GetContext(CreateLogger)
        PrintTable(ctx:GetConfiguration())
        Log4g.API.LogManager.GetLogger("TestLogger")
        Log4g.Core.Logger.Get("TestLogger"):SetLevel(Log4g.Level.GetStdLevel().INFO)
        Log4g.Core.Logger.Get("TestLogger"):INFO("Test message from 'TestLogger'.\n")
    end

    CreateLogger()
end)

concommand.Add("Log4g_CoreTest_ShowAllLogger", function()
    PrintTable(Log4g.Core.Logger.GetAll())
end)

concommand.Add("Log4g_CoreTest_ShowAllLoggerConfig", function()
    PrintTable(Log4g.Core.Config.LoggerConfig.GetAll())
end)