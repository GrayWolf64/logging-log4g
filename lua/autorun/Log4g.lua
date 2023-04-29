--- Initialization of Log4g on server and client.
-- @script Log4g
-- @license Apache License 2.0
-- @copyright GrayWolf64
local fileExists = file.Exists
local MMC = "log4g/mmc-gui/MMC.lua"

local function checkAndInclude(provider, filename, addcslf)
    if fileExists(filename, "lsv") then
        include(filename)
        print(provider, "successfully included", filename, ".")
        if addcslf ~= true then return end
        AddCSLuaFile(filename)
        print(provider, "successfully sent", filename, "to client.")
    else
        print(provider, "tried to include", filename, "but failed due to non-existence.")
    end
end

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
    function Log4g.RegisterPackage(name, ver)
        if type(name) ~= "string" or type(ver) ~= "string" then return end

        Packages[name] = {
            version = ver,
            classes = {}
        }
    end

    function Log4g.RegisterPackageClass(pname, cname, tbl)
        if type(pname) ~= "string" or type(cname) ~= "string" or type(tbl) ~= "table" then return end
        if not Packages[pname] then return end
        Packages[pname].classes[cname] = tbl
    end

    function Log4g.HasPackage(name)
        if type(name) ~= "string" then return end
        if Packages[name] then return true end

        return false
    end

    function Log4g.GetPackageVer(name)
        if type(name) ~= "string" then return end

        return Packages[name].version
    end

    function Log4g.GetPkgClsFuncs(pname, cname)
        if type(pname) ~= "string" or type(cname) ~= "string" then return end
        local p = Packages[pname]
        if not p then return end

        return p.classes[cname]
    end

    function Log4g.GetAllPackages()
        return Packages
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