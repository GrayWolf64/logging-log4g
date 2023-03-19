local CreateLogger = Log4g.Core.Logger.Create
local GetContext = Log4g.API.LoggerContextFactory.GetContext
local GetLevel = Log4g.Level.GetLevel
local CreateLoggerConfig = Log4g.Core.Config.LoggerConfig.Create

concommand.Add("Log4g_CoreTest_LoggerConfig_Inheritance_Example1", function()
    local ctx = GetContext("TestLoggerConfigInheritanceExample1Context", true)
    CreateLogger("X", ctx)
    CreateLogger("X.Y", ctx)
    CreateLogger("X.Y.Z", ctx)
    local X = ctx:GetLogger("X")
    local XY = ctx:GetLogger("X.Y")
    local XYZ = ctx:GetLogger("X.Y.Z")
    print("Logger Name", "Assigned LoggerConfig", "LoggerConfig Parent", "Level")
    print("X", X:GetLoggerConfig().name, tostring(X:GetLoggerConfig():GetParent()), X:GetLoggerConfig():GetLevel().name)
    print("X.Y", XY:GetLoggerConfig().name, tostring(XY:GetLoggerConfig():GetParent()), XY:GetLoggerConfig():GetLevel().name)
    print("X.Y.Z", XYZ:GetLoggerConfig().name, tostring(XYZ:GetLoggerConfig():GetParent()), XYZ:GetLoggerConfig():GetLevel().name)
end)

concommand.Add("Log4g_CoreTest_LoggerConfig_Inheritance_Example2", function()
    local ctx = GetContext("TestLoggerConfigInheritanceExample2Context", true)
    CreateLogger("X", ctx, CreateLoggerConfig("X", ctx:GetConfiguration(), GetLevel("ERROR")))
    CreateLogger("X.Y", ctx, CreateLoggerConfig("X.Y", ctx:GetConfiguration(), GetLevel("INFO")))
    CreateLogger("X.Y.Z", ctx)
    local X = ctx:GetLogger("X")
    local XY = ctx:GetLogger("X.Y")
    local XYZ = ctx:GetLogger("X.Y.Z")
    print("Logger Name", "Assigned LoggerConfig", "LoggerConfig Parent", "Level")
    print("X", X:GetLoggerConfig().name, tostring(X:GetLoggerConfig():GetParent()), X:GetLoggerConfig():GetLevel().name)
    print("X.Y", XY:GetLoggerConfig().name, tostring(XY:GetLoggerConfig():GetParent()), XY:GetLoggerConfig():GetLevel().name)
    print("X.Y.Z", XYZ:GetLoggerConfig().name, tostring(XYZ:GetLoggerConfig():GetParent()), XYZ:GetLoggerConfig():GetLevel().name)
end)