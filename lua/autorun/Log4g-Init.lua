file.CreateDir("log4g")

if SERVER then
    Log4g = Log4g or {}
    file.CreateDir("log4g/server")
    file.CreateDir("log4g/server/loggercontext")
    include("log4g/core/server/Util.lua")
    include("log4g/core/server/LoggerContext.lua")
    include("log4g/core/server/config/LoggerConfig.lua")
    include("log4g/core/server/Level.lua")
    include("log4g/core/server/Logger.lua")
    include("log4g/core/server/Appender.lua")
    include("log4g/core/server/Layout.lua")
    include("log4g/core/server/config/ClientGUIConfigurator.lua")
    include("log4g/core/server/config/builder/DefaultLoggerConfigBuilder.lua")
    include("log4g/core/Version.lua")
    AddCSLuaFile("log4g/core/client/ClientGui.lua")
    AddCSLuaFile("log4g/core/Version.lua")
elseif CLIENT then
    file.CreateDir("log4g/client")
    include("log4g/core/client/ClientGui.lua")
    include("log4g/core/Version.lua")
end