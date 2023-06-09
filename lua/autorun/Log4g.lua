--- Initialization of Log4g on server and client.
-- This bootstrap can't execute if `gmod` table doesn't exist.
-- @script Log4g
-- @license Apache License 2.0
-- @copyright GrayWolf64
if not gmod then return end

local MMC = "log4g/mmc-gui/MMC.lua"

local function checkAndInclude(provider, fileName, addCSLuaFile, path)
    if not file.Exists(fileName, path) then return end
    include(fileName)
    print(provider .. ": included " .. fileName)
    if addCSLuaFile ~= true then return end
    AddCSLuaFile(fileName)
    print(provider .. ": sent " .. fileName .. " to cl")
end

if SERVER then
    --- The global table for the logging system.
    -- It provides easy access to some functions for other components of the logging system.
    -- @table Log4g
    Log4g = Log4g or {}

    function Log4g.includeFromDir(dir)
        for _, fileName in pairs(file.Find(dir .. "*", "lsv")) do
            include(dir .. fileName)
        end
    end

    checkAndInclude("log4g sv-init", "log4g/core/Core.lua", false, "lsv")
    checkAndInclude("log4g sv-init", "log4g/api/API.lua", false, "lsv")
    checkAndInclude("log4g sv-init", MMC, true, "lsv")
    checkAndInclude("log4g sv-init", "log4g/core-test/CoreTest.lua", false, "lsv")
elseif CLIENT then
    checkAndInclude("log4g cl-init", MMC, false, "lcl")
end