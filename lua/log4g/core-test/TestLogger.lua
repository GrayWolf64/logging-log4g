concommand.Add("Log4g_CoreTest_CreateLogger", function()
    local function CreateLogger()
        local ctx = Log4g.API.LoggerContextFactory.GetContext(CreateLogger)
        PrintTable(ctx:GetConfiguration())
    end

    CreateLogger()
end)