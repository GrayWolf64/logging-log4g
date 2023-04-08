local CreateLogger = Log4g.Core.Logger.Create
local GetContext = Log4g.API.LoggerContextFactory.GetContext
local GetLevel = Log4g.Level.GetLevel
local CreateLoggerConfig = Log4g.Core.Config.LoggerConfig.Create
local CreateConsoleAppender = Log4g.Core.Appender.CreateConsoleAppender
local CreatePatternLayout = Log4g.Core.Layout.PatternLayout.CreateDefaultLayout
local print = print

local function PrintLoggerInfo(...)
    print("Logger", "Assigned LC", "LC Parent", "Level")

    for _, v in pairs({...}) do
        print(v:GetName(), v:GetLoggerConfig():GetName(), tostring(v:GetLoggerConfig():GetParent()), v:GetLevel():GetName())
    end
end

concommand.Add("log4g_coretest_LoggerConfig_Inheritance", function(_, _, _, arg)
    local ctx = GetContext("TestLCInheritanceContext", true)

    if arg == "1" then
        PrintLoggerInfo(CreateLogger("X", ctx), CreateLogger("X.Y", ctx), CreateLogger("X.Y.Z", ctx))
    elseif arg == "2" then
        PrintLoggerInfo(CreateLogger("X", ctx, CreateLoggerConfig("X", ctx:GetConfiguration(), GetLevel("ERROR"))), CreateLogger("X.Y", ctx, CreateLoggerConfig("X.Y", ctx:GetConfiguration(), GetLevel("INFO"))), CreateLogger("X.Y.Z", ctx, CreateLoggerConfig("X.Y.Z", ctx:GetConfiguration(), GetLevel("WARN"))))
    elseif arg == "3" then
        PrintLoggerInfo(CreateLogger("X", ctx, CreateLoggerConfig("X", ctx:GetConfiguration(), GetLevel("ERROR"))), CreateLogger("X.Y", ctx), CreateLogger("X.Y.Z", ctx, CreateLoggerConfig("X.Y.Z", ctx:GetConfiguration(), GetLevel("WARN"))))
    elseif arg == "4" then
        PrintLoggerInfo(CreateLogger("X", ctx, CreateLoggerConfig("X", ctx:GetConfiguration(), GetLevel("ERROR"))), CreateLogger("X.Y", ctx), CreateLogger("X.Y.Z", ctx))
    elseif arg == "5" then
        PrintLoggerInfo(CreateLogger("X", ctx, CreateLoggerConfig("X", ctx:GetConfiguration(), GetLevel("ERROR"))), CreateLogger("X.Y", ctx, CreateLoggerConfig("X.Y", ctx:GetConfiguration(), GetLevel("INFO"))), CreateLogger("X.YZ", ctx))
    elseif arg == "6" then
        PrintLoggerInfo(CreateLogger("X", ctx, CreateLoggerConfig("X", ctx:GetConfiguration(), GetLevel("ERROR"))), CreateLogger("X.Y", ctx, CreateLoggerConfig("X.Y", ctx:GetConfiguration())), CreateLogger("X.Y.Z", ctx))
    end

    ctx:Terminate()
end)

concommand.Add("log4g_coretest_LoggerLog", function()
    local ctx = GetContext("TestLoggerLogContext", true)
    local lc = CreateLoggerConfig("LogTester", ctx:GetConfiguration(), GetLevel("TRACE"))
    lc:AddAppender(CreateConsoleAppender("TestAppender", CreatePatternLayout("TestLayout")))
    local logger = CreateLogger("LogTester", ctx, lc)
    logger:Trace("Test TRACE message.")
    ctx:Terminate()
end)