--- Initialization of Log4g on server and client.
-- This bootstrap can't execute if `gmod` table doesn't exist.
-- @script Log4g
-- @license Apache License 2.0
-- @copyright GrayWolf64
local fileExists = file.Exists
local MMC = "log4g/mmc-gui/MMC.lua"

local function checkAndInclude(provider, fileName, addCSLuaFile)
    if fileExists(fileName, "lsv") then
        include(fileName)
        print(provider, "successfully included", fileName)
        if addCSLuaFile ~= true then return end
        AddCSLuaFile(fileName)
        print(provider, "successfully sent", fileName, "to client")
    else
        print(provider, "tried to include", fileName, "but failed due to non-existence")
    end
end

if not gmod then return end

if SERVER then
    local type = type
    --- The global table for the logging system.
    -- It provides easy access to some functions for other components of the logging system that require them.
    -- @table Log4g
    -- @field Core
    -- @field Level
    Log4g = Log4g or {}
    --- The installed Log4g packages.
    -- Keys are the names of packages, and values are tables that hold the versions and classes for the particular package.
    -- The `classes` table in one package's named table may contain some functions and so on.
    -- @local
    -- @table Packages
    local Packages = Packages or {}

    --- Register a package for use with Log4g.
    -- @param name The name of the package to register
    -- @param ver The version string of the given package
    function Log4g.RegisterPackage(packageName, ver)
        if type(packageName) ~= "string" or type(ver) ~= "string" then return end

        Packages[packageName] = {
            _ver = ver,
            Classes = {}
        }
    end

    function Log4g.HasPackage(name)
        if type(name) ~= "string" then return end
        if Packages[name] then return true end

        return false
    end

    function Log4g.GetPackageVer(name)
        if type(name) ~= "string" then return end

        return Packages[name]._ver
    end

    --- Execute the given function and see how long it takes.
    -- @param func Function
    -- @return number Precise time
    function Log4g.timeit(func)
        if type(func) ~= "function" then return end
        local SysTime = SysTime
        local startTime = SysTime()
        func()
        local endTime = SysTime()

        return endTime - startTime
    end

    checkAndInclude("Log4g sv-init", "log4g/core/Core.lua")
    checkAndInclude("Log4g sv-init", "log4g/api/API.lua")
    checkAndInclude("Log4g sv-init", MMC, true)
    checkAndInclude("Log4g sv-init", "log4g/core-test/CoreTest.lua")
elseif CLIENT then
    checkAndInclude("Log4g cl-init", MMC)
end