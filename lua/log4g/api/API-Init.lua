Log4g.API = Log4g.API or {}
Log4g.API.Simple = Log4g.API.Simple or {}
include("log4g/api/spi/LoggerContextFactory.lua")
include("log4g/api/LogManager.lua")
include("log4g/api/AutoReconfiguration.lua")
include("log4g/api/simple/SimpleLoggerContext.lua")
include("log4g/api/simple/SimpleLogger.lua")
include("log4g/api/status/StatusLogger.lua")