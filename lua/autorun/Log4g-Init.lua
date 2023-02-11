--- Initialization of Log4g on server and client.
-- @script Log4g-Init
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
	Log4g.Core = Log4g.Core or {}
	Log4g.Core.Config = Log4g.Core.Config or {}
	Log4g.Core.Config.Builder = Log4g.Core.Config.Builder or {}
	Log4g.Core.Config.LoggerConfig = Log4g.Core.Config.LoggerConfig or {}
	Log4g.Core.Config.LoggerConfig.Lookup = Log4g.Core.Config.LoggerConfig.Lookup or {}
	Log4g.Core.LoggerContext = Log4g.Core.LoggerContext or {}
	Log4g.Core.LoggerContext.Lookup = Log4g.Core.LoggerContext.Lookup or {}
	Log4g.Level = Log4g.Level or {}
	Log4g.Core.Logger = Log4g.Core.Logger or {}
	Log4g.Core.Logger.Lookup = Log4g.Core.Logger.Lookup or {}
	sql.Query("CREATE TABLE IF NOT EXISTS Log4g_Lookup(Name TEXT NOT NULL UNIQUE, Content TEXT NOT NULL UNIQUE)")
	sql.Query("CREATE TABLE IF NOT EXISTS Log4g_LoggerConfig(Name TEXT NOT NULL UNIQUE, Content TEXT NOT NULL UNIQUE)")
	include("log4g/core/Version.lua")
	include("log4g/core/Util.lua")
	include("log4g/core/LifeCycle.lua")
	include("log4g/core/Level.lua")
	include("log4g/core/Layout.lua")
	include("log4g/core/Appender.lua")
	include("log4g/core/lookup/LoggerContextLookup.lua")
	include("log4g/core/lookup/LoggerConfigLookup.lua")
	include("log4g/core/config/LoggerConfig.lua")
	include("log4g/core/LoggerContext.lua")
	include("log4g/core/Logger.lua")
	include("log4g/core/lookup/LoggerLookup.lua")

	if file.Exists(API, "lsv") then
		include(API)
	else
		return
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
