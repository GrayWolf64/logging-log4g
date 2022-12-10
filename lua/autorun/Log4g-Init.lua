Log4g = Log4g or {}
file.CreateDir("log4g")

if SERVER then
    file.CreateDir("log4g/server")
    file.CreateDir("log4g/server/loggercontext")
    include("log4g/core/server/Util.lua")
    include("log4g/core/server/config/LoggerConfig.lua")
    include("log4g/core/server/config/Configurator.lua")
    include("log4g/core/server/config/Make.lua")
    include("log4g/core/server/LoggerContext.lua")
    include("log4g/core/server/Level.lua")
    include("log4g/core/server/Logger.lua")
    include("log4g/core/server/Appender.lua")
    include("log4g/core/server/Layout.lua")
    AddCSLuaFile("log4g/core/client/Gui.lua")
elseif CLIENT then
    file.CreateDir("log4g/client")
    include("log4g/core/client/Gui.lua")
end