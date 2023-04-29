--- Initialization of Log4g Core, server only.
-- @script Core
-- @license Apache License 2.0
-- @copyright GrayWolf64
Log4g.RegisterPackage("log4g-core", "0.0.6-beta")
Log4g.Core = Log4g.Core or {}
Log4g.Core.Config = Log4g.Core.Config or {}
--- A dictionary for storing LoggerContext objects.
-- Only one ContextDictionary exists in the logging system.
-- @local
-- @table ContextDict
local ContextDict = ContextDict or {}

function Log4g.Core.getContextDict()
    return ContextDict
end

include"log4g/core/Version.lua"
include"log4g/core/impl/Object.lua"
include"log4g/core/LifeCycle.lua"
include"log4g/core/util/TypeUtil.lua"
include"log4g/core/Level.lua"
include"log4g/core/Layout.lua"
include"log4g/core/layout/PatternLayout.lua"
include"log4g/core/Appender.lua"
include"log4g/core/appender/ConsoleAppender.lua"
include"log4g/core/config/Configuration.lua"
include"log4g/core/config/DefaultConfiguration.lua"
include"log4g/core/LoggerContext.lua"
include"log4g/core/config/LoggerConfig.lua"
include"log4g/core/LogEvent.lua"
include"log4g/core/Logger.lua"