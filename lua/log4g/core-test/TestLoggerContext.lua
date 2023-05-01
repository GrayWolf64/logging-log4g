local LoggerContext = Log4g.GetPkgClsFuncs("log4g-core", "LoggerContext")
local Get = LoggerContext.getContext
local GetContext = Log4g.API.LoggerContextFactory.GetContext
local randomString = Log4g.CoreTest.randomString
local print = print
local names = {}

concommand.Add("log4g_coretest_createLoggerContext", function()
    print("starting LoggerContext create unittest:")

    print("ended in:", Log4g.timeit(function()
        for i = 1, 10 do
            local name = randomString(10)
            names[i] = name
            GetContext(name)
            print("i = ", i, "created", name)
            Get(name):Terminate()
            print("terminated", name)
        end
    end), "seconds")
end)

concommand.Add("log4g_coretest_showAllLoggerContext", function()
    PrintTable(LoggerContext.getAllContexts())
end)