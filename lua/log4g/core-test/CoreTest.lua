--- The optional CoreTest package.
-- @script CoreTest
-- @license Apache License 2.0
-- @copyright GrayWolf64

concommand.Add("log4g_load_coretest", function()
    Log4g.CoreTest = Log4g.CoreTest or {}

    include"log4g/core-test/ExtendedLevels.lua"
    include"log4g/core-test/CoreLoggerContexts.lua"
    include"log4g/core-test/TestLogger.lua"
end)