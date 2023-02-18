Log4g.API = Log4g.API or {}
Log4g.API.Simple = Log4g.API.Simple or {}
Log4g.API.Simple.SimpleLoggerContext = Log4g.API.Simple.SimpleLoggerContext or {}
Log4g.API.Simple.SimpleLogger = Log4g.API.Simple.SimpleLogger or {}
include("log4g/api/status/StatusLogger.lua")
include("log4g/api/spi/LoggerContextFactory.lua")
include("log4g/api/LogManager.lua")
include("log4g/api/AutoReconfiguration.lua")
include("log4g/api/simple/SimpleLoggerContext.lua")
include("log4g/api/simple/SimpleLogger.lua")