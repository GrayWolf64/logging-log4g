--- Initialization of Log4g API.
-- @script API
-- @license Apache License 2.0
-- @copyright GrayWolf64
Log4g.RegisterPackage("log4g-api", "0.0.5-beta")
Log4g.API = Log4g.API or {}
Log4g.API.Simple = Log4g.API.Simple or {}
include"log4g/api/spi/LoggerContextFactory.lua"
include"log4g/api/simple/SimpleLoggerContext.lua"
include"log4g/api/simple/SimpleLoggerContextFactory.lua"
include"log4g/api/LogManager.lua"
include"log4g/api/simple/SimpleLogger.lua"
include"log4g/api/status/StatusLogger.lua"