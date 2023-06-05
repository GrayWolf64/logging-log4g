--- Initialization of Log4g API.
-- @script API
-- @license Apache License 2.0
-- @copyright GrayWolf64
Log4g.RegisterPackage("log4g-api", "0.0.5-beta")
Log4g.API = Log4g.API or {}
include"log4g/api/spi/LoggerContextFactory.lua"
include"log4g/api/LogManager.lua"