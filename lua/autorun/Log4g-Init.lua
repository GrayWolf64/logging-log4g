--- Initialization of Log4g on server and client.
-- @script Log4g-Init.lua
local MMC = "log4g/mmc-gui/Log4g-MMC-Init.lua"
file.CreateDir("log4g")

if SERVER then
    --- The global table for the logging system.
    -- @table Log4g
    -- @field Core
    -- @field LogManager
    -- @field Level
    -- @field Util
    -- @field _VERSION
    Log4g = Log4g or {}
    Log4g.Core = Log4g.Core or {}
    Log4g.LogManager = Log4g.LogManager or {}
    Log4g.Level = Log4g.Level or {}
    Log4g.Core.Logger = Log4g.Core.Logger or {}
    file.CreateDir("log4g/server/loggercontext")
    include("log4g/core/Version.lua")
    include("log4g/core/Util.lua")
    include("log4g/core/LifeCycle.lua")
    include("log4g/core/LoggerContext.lua")
    include("log4g/core/Level.lua")
    include("log4g/core/Logger.lua")
    include("log4g/core/lookup/LoggerContextLookup.lua")
    include("log4g/core/lookup/LoggerLookup.lua")
    include("log4g/core/config/LoggerConfig.lua")
    include("log4g/core/Appender.lua")
    include("log4g/core/Layout.lua")
    include("log4g/core/LogSaveRestore.lua")
    include("log4g/core/status/StatusLogger.lua")

    if file.Exists(MMC, "lsv") then
        include(MMC)
        AddCSLuaFile(MMC)
    end
elseif CLIENT then
    if file.Exists(MMC, "lcl") then
        include(MMC)
    end
end