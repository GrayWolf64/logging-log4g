--- Initialization of Log4g on server and client.
-- @script Log4g
-- @license Apache License 2.0
-- @copyright GrayWolf64
local include = include
local fileExists = file.Exists
local MMC = "log4g/mmc-gui/MMC.lua"

local function checkAndInclude(filename, addcslf)
    if fileExists(filename, "lsv") then
        include(filename)
        if addcslf ~= true then return end
        AddCSLuaFile(filename)
    end
end

if SERVER then
    local isstring = isstring
    local pairs = pairs
    --- The global table for the logging system.
    -- It provides easy access to some functions for other components of the logging system that require them.
    -- @table Log4g
    -- @field Core
    -- @field Level
    Log4g = Log4g or {}
    local packages = {}

    function Log4g.RegisterPackage(name, ver)
        if not isstring(name) or not isstring(ver) then return end
        packages[name] = ver
    end

    function Log4g.HasPackage(name)
        if not isstring(name) then return end

        for k in pairs(packages) do
            if k == name then return true end
        end

        return false
    end

    function Log4g.GetPackageVer(name)
        if not isstring(name) then return end

        return packages[name]
    end

    checkAndInclude("log4g/core/Core.lua")
    checkAndInclude("log4g/api/API.lua")
    checkAndInclude(MMC, true)
    checkAndInclude("log4g/core-test/CoreTest.lua")
elseif CLIENT then
    checkAndInclude(MMC)
end