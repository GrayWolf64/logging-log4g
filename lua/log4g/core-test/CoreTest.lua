--- The optional CoreTest package.
-- @script CoreTest
-- @license Apache License 2.0
-- @copyright GrayWolf64
Log4g.RegisterPackage("log4g-coretest", "0.0.5-beta")

concommand.Add("log4g_load_coretest", function()
    Log4g.CoreTest = Log4g.CoreTest or {}
    local stringChar = string.char
    local mathRandom = math.random

    function Log4g.CoreTest.randomString(len)
        local res = ""

        for i = 1, len do
            res = res .. stringChar(mathRandom(97, 122))
        end

        return res
    end

    include("log4g/core-test/TestLoggerContext.lua")
    include("log4g/core-test/TestLogger.lua")
end)