local LoggerContext = Log4g.Core.LoggerContext
local Get = LoggerContext.get
local GetContext = Log4g.API.LoggerContextFactory.GetContext
local randomString = Log4g.CoreTest.randomString
local print = print
local names = {}

concommand.Add("log4g_coretest_createLoggerContext", function()
    print("starting LoggerContext create unittest:")
    for i = 1, 10 do
        local name = randomString(10)
        names[i] = name
        GetContext(name)
        print("i = ", i, "created", name)
        Get(name):Terminate()
        print("terminated", name)
    end
end)

concommand.Add("log4g_coretest_showAllLoggerContext", function()
    PrintTable(LoggerContext.getAll())
end)