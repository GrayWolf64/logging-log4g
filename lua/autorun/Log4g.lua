if not SERVER then return end
local Log4g = include("log4g/Core.lua")
PrintTable(Log4g)

concommand.Add("log4g_coretest_propertiesPlugin", function()
    local function randomString(len)
        local res = ""

        for i = 1, len do
            res = res .. string.char(math.random(97, 122))
        end

        return res
    end

    local sharedPropertyName, sharedPropertyValue = randomString(10), randomString(10)
    print("creating shared:", sharedPropertyName)
    Log4g.registerProperty(sharedPropertyName, sharedPropertyValue, true)
    PrintTable(Log4g.getAllProperties())
    print("deleting shared:", sharedPropertyName)
    Log4g.removeProperty(sharedPropertyName, true)
    PrintTable(Log4g.getAllProperties())
    print("\n")
    local contextName = randomString(10)
    local privatePropertyName, privatePropertyValue = randomString(10), randomString(10)
    Log4g.registerContext(contextName)
    local context = Log4g.getContext(contextName)
    print("creating private:", privatePropertyName)
    Log4g.registerProperty(privatePropertyName, privatePropertyValue, false, context)
    PrintTable(Log4g.getAllProperties())
    print("deleting private:", privatePropertyName)
    Log4g.removeProperty(privatePropertyName, false, context)
    PrintTable(Log4g.getAllProperties())
    Log4g.getContextDict()[contextName]:Terminate()
end)

local function PrintLoggerInfo(...)
    print("Logger", "Assigned LC", "LC Parent", "Level")

    for _, v in pairs({...}) do
        print(v:GetName(), v:GetLoggerConfig():GetName(), tostring(v:GetLoggerConfig():GetParent()), v:GetLevel():GetName())
    end
end

concommand.Add("log4g_coretest_LoggerConfig_Inheritance", function()
    local getContext = Log4g.LogManager.getContext
    local ctx = getContext("TestLCInheritance", true)
    local createLogger = Log4g.createLogger
    local createLoggerConfig = Log4g.createLoggerConfig
    local getLevel = Log4g.getLevel

    local function renew()
        ctx:Terminate()
        ctx = getContext("TestLCInheritance", true)
    end

    PrintLoggerInfo(createLogger("X", ctx), createLogger("X.Y", ctx), createLogger("X.Y.Z", ctx))
    renew()
    PrintLoggerInfo(createLogger("X", ctx, createLoggerConfig("X", ctx:GetConfiguration(), getLevel("ERROR"))), createLogger("X.Y", ctx, createLoggerConfig("X.Y", ctx:GetConfiguration(), getLevel("INFO"))), createLogger("X.Y.Z", ctx, createLoggerConfig("X.Y.Z", ctx:GetConfiguration(), getLevel("WARN"))))
    renew()
    PrintLoggerInfo(createLogger("X", ctx, createLoggerConfig("X", ctx:GetConfiguration(), getLevel("ERROR"))), createLogger("X.Y", ctx), createLogger("X.Y.Z", ctx, createLoggerConfig("X.Y.Z", ctx:GetConfiguration(), getLevel("WARN"))))
    renew()
    PrintLoggerInfo(createLogger("X", ctx, createLoggerConfig("X", ctx:GetConfiguration(), getLevel("ERROR"))), createLogger("X.Y", ctx), createLogger("X.Y.Z", ctx))
    renew()
    PrintLoggerInfo(createLogger("X", ctx, createLoggerConfig("X", ctx:GetConfiguration(), getLevel("ERROR"))), createLogger("X.Y", ctx, createLoggerConfig("X.Y", ctx:GetConfiguration(), getLevel("INFO"))), createLogger("X.YZ", ctx))
    renew()
    PrintLoggerInfo(createLogger("X", ctx, createLoggerConfig("X", ctx:GetConfiguration(), getLevel("ERROR"))), createLogger("X.Y", ctx, createLoggerConfig("X.Y", ctx:GetConfiguration())), createLogger("X.Y.Z", ctx))
    ctx:Terminate()
end)

concommand.Add("log4g_coretest_loggerLog", function()
    local ctx = GetContext("TestLoggerLogContext", true)
    local lc = createLoggerConfig("LogTester", ctx:GetConfiguration(), getLevel("TRACE"))
    lc:AddAppender(CreateConsoleAppender("TestAppender", CreatePatternLayout("TestLayout")))
    local logger = createLogger("LogTester", ctx, lc)

    print("output finished in", Log4g.timeit(function()
        logger:Trace("Test TRACE message 0123456789.")
    end), "seconds")

    print(logger:IsAdditive())
    ctx:Terminate()
end)