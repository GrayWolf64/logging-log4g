local CreateLogger = Log4g.Core.Logger.Create
local GetContext = Log4g.API.LoggerContextFactory.GetContext
local GetLevel = Log4g.Level.GetLevel
local CreateLoggerConfig = Log4g.Core.Config.LoggerConfig.Create
local print = print

local function PrintLoggerInfo(...)
    print("Logger", "Assigned LC", "LC Parent", "Level")

    for _, v in pairs({...}) do
        print(v.name, v:GetLoggerConfig().name, tostring(v:GetLoggerConfig():GetParent()), v:GetLoggerConfig():GetLevel().name)
    end
end

concommand.Add("Log4g_CoreTest_LoggerConfig_Inheritance_Example1", function()
    local ctx = GetContext("TestLoggerConfigInheritanceExample1Context", true)
    CreateLogger("X", ctx)
    CreateLogger("X.Y", ctx)
    CreateLogger("X.Y.Z", ctx)
    PrintLoggerInfo(ctx:GetLogger("X"), ctx:GetLogger("X.Y"), ctx:GetLogger("X.Y.Z"))
end)

concommand.Add("Log4g_CoreTest_LoggerConfig_Inheritance_Example2", function()
    local ctx = GetContext("TestLoggerConfigInheritanceExample2Context", true)
    CreateLogger("X", ctx, CreateLoggerConfig("X", ctx:GetConfiguration(), GetLevel("ERROR")))
    CreateLogger("X.Y", ctx, CreateLoggerConfig("X.Y", ctx:GetConfiguration(), GetLevel("INFO")))
    CreateLogger("X.Y.Z", ctx, CreateLoggerConfig("X.Y.Z", ctx:GetConfiguration(), GetLevel("WARN")))
    PrintLoggerInfo(ctx:GetLogger("X"), ctx:GetLogger("X.Y"), ctx:GetLogger("X.Y.Z"))
end)

concommand.Add("Log4g_CoreTest_LoggerConfig_Inheritance_Example3", function()
    local ctx = GetContext("TestLoggerConfigInheritanceExample3Context", true)
    CreateLogger("X", ctx, CreateLoggerConfig("X", ctx:GetConfiguration(), GetLevel("ERROR")))
    CreateLogger("X.Y", ctx)
    CreateLogger("X.Y.Z", ctx, CreateLoggerConfig("X.Y.Z", ctx:GetConfiguration(), GetLevel("WARN")))
    PrintLoggerInfo(ctx:GetLogger("X"), ctx:GetLogger("X.Y"), ctx:GetLogger("X.Y.Z"))
end)

concommand.Add("Log4g_CoreTest_LoggerConfig_Inheritance_Example4", function()
    local ctx = GetContext("TestLoggerConfigInheritanceExample4Context", true)
    CreateLogger("X", ctx, CreateLoggerConfig("X", ctx:GetConfiguration(), GetLevel("ERROR")))
    CreateLogger("X.Y", ctx)
    CreateLogger("X.Y.Z", ctx)
    PrintLoggerInfo(ctx:GetLogger("X"), ctx:GetLogger("X.Y"), ctx:GetLogger("X.Y.Z"))
end)

concommand.Add("Log4g_CoreTest_LoggerConfig_Inheritance_Example5", function()
    local ctx = GetContext("TestLoggerConfigInheritanceExample5Context", true)
    CreateLogger("X", ctx, CreateLoggerConfig("X", ctx:GetConfiguration(), GetLevel("ERROR")))
    CreateLogger("X.Y", ctx, CreateLoggerConfig("X.Y", ctx:GetConfiguration(), GetLevel("INFO")))
    CreateLogger("X.YZ", ctx)
    PrintLoggerInfo(ctx:GetLogger("X"), ctx:GetLogger("X.Y"), ctx:GetLogger("X.YZ"))
end)

concommand.Add("Log4g_CoreTest_LoggerConfig_Inheritance_Example6", function()
    local ctx = GetContext("TestLoggerConfigInheritanceExample6Context", true)
    CreateLogger("X", ctx, CreateLoggerConfig("X", ctx:GetConfiguration(), GetLevel("ERROR")))
    CreateLogger("X.Y", ctx, CreateLoggerConfig("X.Y", ctx:GetConfiguration()))
    CreateLogger("X.Y.Z", ctx)
    PrintLoggerInfo(ctx:GetLogger("X"), ctx:GetLogger("X.Y"), ctx:GetLogger("X.Y.Z"))
end)