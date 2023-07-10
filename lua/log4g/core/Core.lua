--- Initialization of Log4g Core, server only.
-- @script Core
-- @license Apache License 2.0
-- @copyright GrayWolf64
Log4g.Core = Log4g.Core or {}
Log4g.Core.Config = Log4g.Core.Config or {}

CreateConVar("log4g_rootLoggerName", "root", 4194304)

include"impl/Object.lua"
include"Repository.lua"
include"LifeCycle.lua"
include"Level.lua"
include"Layout.lua"
include"Appender.lua"
include"config/Configuration.lua"
include"config/DefaultConfiguration.lua"
include"LoggerContext.lua"
include"config/LoggerConfig.lua"
include"LogEvent.lua"
include"Logger.lua"