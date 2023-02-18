--- Initialization of Log4g on server and client.
-- @script Log4g-Init
local Core = "log4g/core/Core-Init.lua"
local API = "log4g/api/API-Init.lua"
local MMC = "log4g/mmc-gui/MMC-Init.lua"
local CoreTest = "log4g/core-test/Core-Test-Init.lua"
file.CreateDir("log4g")

if SERVER then
    --- The global table for the logging system.
    -- It provides easy access to some functions for other components of the logging system that require them.
    -- @table Log4g
    -- @field Core
    -- @field Level
    -- @field Util
    -- @field _VERSION
    Log4g = Log4g or {}

    if file.Exists(Core, "lsv") then
        include(Core)
    end

    if file.Exists(API, "lsv") then
        include(API)
    end

    if file.Exists(MMC, "lsv") then
        include(MMC)
        AddCSLuaFile(MMC)
    end

    if file.Exists(CoreTest, "lsv") then
        include(CoreTest)
    end
elseif CLIENT then
    if file.Exists(MMC, "lcl") then
        include(MMC)
    end
end