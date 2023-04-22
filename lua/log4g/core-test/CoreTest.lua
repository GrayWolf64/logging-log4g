--- The optional CoreTest package.
-- @script CoreTest
-- @license Apache License 2.0
-- @copyright GrayWolf64
Log4g.RegisterPackage("log4g-coretest", "0.0.5-beta")

concommand.Add("log4g_load_coretest", function()
    include("log4g/core-test/TestLoggerContext.lua")
    include("log4g/core-test/TestLogger.lua")
end)