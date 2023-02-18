concommand.Add("Log4g_CoreTest_CreateLogger", function()
    local function CreateLogger()
        local ctx = Log4g.API.LoggerContextFactory.GetContext(CreateLogger)
        PrintTable(ctx:GetConfiguration())
        Log4g.Core.Logger.Create("TestLogger", ctx, Log4g.Level.GetLevel("ALL"))
        PrintTable(ctx:GetLoggers())
    end

    CreateLogger()
end)