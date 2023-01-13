--- Initialization of Log4g on server and client.
-- @script Log4g-Init.lua
file.CreateDir("log4g")

if SERVER then
    Log4g = Log4g or {}
    Log4g.Core = Log4g.Core or {}
    Log4g.Inst = Log4g.Inst or {}
    Log4g.Level = Log4g.Level or {}
    file.CreateDir("log4g/server")
    file.CreateDir("log4g/server/loggercontext")
    include("log4g/core/server/Util.lua")
    include("log4g/core/server/LifeCycle.lua")
    include("log4g/core/server/LoggerContext.lua")
    include("log4g/core/server/config/LoggerConfig.lua")
    include("log4g/core/server/Level.lua")
    include("log4g/core/server/Logger.lua")
    include("log4g/core/server/Appender.lua")
    include("log4g/core/server/Layout.lua")
    include("log4g/core/server/config/ClientGUIConfigurator.lua")
    include("log4g/core/server/ClientGUISummaryData.lua")
    include("log4g/core/server/config/builder/DefaultLoggerConfigBuilder.lua")
    include("log4g/core/Version.lua")
    AddCSLuaFile("log4g/core/client/ClientGUI.lua")
    AddCSLuaFile("log4g/core/Version.lua")
elseif CLIENT then
    file.CreateDir("log4g/client")
    include("log4g/core/client/ClientGUI.lua")
    include("log4g/core/Version.lua")
end