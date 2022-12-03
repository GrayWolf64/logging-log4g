Log4g = Log4g or {}
file.CreateDir("log4g")

if SERVER then
    file.CreateDir("log4g/server")
    file.CreateDir("log4g/server/loggercontext")
    AddCSLuaFile("log4g/core/client/gui.lua")
    include("log4g/core/server/util.lua")
    include("log4g/core/server/config.lua")
    include("log4g/core/server/level.lua")
    include("log4g/core/server/logger.lua")
    include("log4g/core/server/appender.lua")
elseif CLIENT then
    file.CreateDir("log4g/client")
    include("log4g/core/client/gui.lua")
end