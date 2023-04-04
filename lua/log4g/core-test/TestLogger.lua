local CreateLogger = Log4g.Core.Logger.Create
local GetContext = Log4g.API.LoggerContextFactory.GetContext
local GetLevel = Log4g.Level.GetLevel
local CreateLoggerConfig = Log4g.Core.Config.LoggerConfig.Create
local print = print

local function PrintLoggerInfo(...)
    print("Logger", "Assigned LC", "LC Parent", "Level")

    for _, v in pairs({...}) do
        print(v:GetName(), v:GetLoggerConfig():GetName(), tostring(v:GetLoggerConfig():GetParent()), v:GetLevel():GetName())
    end
end

concommand.Add("Log4g_CoreTest_LoggerConfig_Inheritance", function(_, _, _, arg)
    local ctx

    if arg == "1" then
        ctx = GetContext("TestLoggerConfigInheritanceExample1Context", true)
        PrintLoggerInfo(CreateLogger("X", ctx), CreateLogger("X.Y", ctx), CreateLogger("X.Y.Z", ctx))
    elseif arg == "2" then
        ctx = GetContext("TestLoggerConfigInheritanceExample2Context", true)
        PrintLoggerInfo(CreateLogger("X", ctx, CreateLoggerConfig("X", ctx:GetConfiguration(), GetLevel("ERROR"))), CreateLogger("X.Y", ctx, CreateLoggerConfig("X.Y", ctx:GetConfiguration(), GetLevel("INFO"))), CreateLogger("X.Y.Z", ctx, CreateLoggerConfig("X.Y.Z", ctx:GetConfiguration(), GetLevel("WARN"))))
    elseif arg == "3" then
        ctx = GetContext("TestLoggerConfigInheritanceExample3Context", true)
        PrintLoggerInfo(CreateLogger("X", ctx, CreateLoggerConfig("X", ctx:GetConfiguration(), GetLevel("ERROR"))), CreateLogger("X.Y", ctx), CreateLogger("X.Y.Z", ctx, CreateLoggerConfig("X.Y.Z", ctx:GetConfiguration(), GetLevel("WARN"))))
    elseif arg == "4" then
        ctx = GetContext("TestLoggerConfigInheritanceExample4Context", true)
        PrintLoggerInfo(CreateLogger("X", ctx, CreateLoggerConfig("X", ctx:GetConfiguration(), GetLevel("ERROR"))), CreateLogger("X.Y", ctx), CreateLogger("X.Y.Z", ctx))
    elseif arg == "5" then
        ctx = GetContext("TestLoggerConfigInheritanceExample5Context", true)
        PrintLoggerInfo(CreateLogger("X", ctx, CreateLoggerConfig("X", ctx:GetConfiguration(), GetLevel("ERROR"))), CreateLogger("X.Y", ctx, CreateLoggerConfig("X.Y", ctx:GetConfiguration(), GetLevel("INFO"))), CreateLogger("X.YZ", ctx))
    elseif arg == "6" then
        ctx = GetContext("TestLoggerConfigInheritanceExample6Context", true)
        PrintLoggerInfo(CreateLogger("X", ctx, CreateLoggerConfig("X", ctx:GetConfiguration(), GetLevel("ERROR"))), CreateLogger("X.Y", ctx, CreateLoggerConfig("X.Y", ctx:GetConfiguration())), CreateLogger("X.Y.Z", ctx))
    end

    ctx:Terminate()
end)

concommand.Add("Log4g_CoreTest_LoggerLog", function()
    local ctx = GetContext("TestLoggerLogContext", true)
    local lc = CreateLoggerConfig("LogTester", ctx:GetConfiguration(), GetLevel("INFO"))
    lc:AddAppender(Log4g.Core.Appender.CreateConsoleAppender("TestAp", Log4g.Core.Layout.PatternLayout.CreateDefaultLayout("TestLayout")))
    local logger = CreateLogger("LogTester", ctx, lc)
    logger:Trace("A message from a actual Logger!")
    ctx:Terminate()
end)