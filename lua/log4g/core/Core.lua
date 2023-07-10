--- Initialization of Log4g Core, server only.
-- @script Core
-- @license Apache License 2.0
-- @copyright GrayWolf64
Log4g.Core = Log4g.Core or {}
Log4g.Core.Config = Log4g.Core.Config or {}

CreateConVar("log4g_rootLoggerName", "root", 4194304)

include"log4g/core/impl/Object.lua"
include"log4g/core/Repository.lua"
include"log4g/core/LifeCycle.lua"
include"log4g/core/Level.lua"
include"log4g/core/Layout.lua"
include"log4g/core/Appender.lua"
include"log4g/core/config/Configuration.lua"
include"log4g/core/config/DefaultConfiguration.lua"
include"log4g/core/LoggerContext.lua"
include"log4g/core/config/LoggerConfig.lua"
include"log4g/core/LogEvent.lua"
include"log4g/core/Logger.lua"