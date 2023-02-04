--- Reconfiguration (SaveRestore) system for the Logging environment.
-- @script Reconfiguration
-- @license Apache License 2.0
-- @copyright GrayWolf64
local CreateLoggerContext = Log4g.API.LoggerContextFactory.GetContext
local GetAllLoggerContexts = Log4g.Core.LoggerContext.GetAll
local RegisterLoggerConfig = Log4g.Core.Config.LoggerConfig.RegisterLoggerConfig
local GetAllLoggerConfigs = Log4g.Core.Config.LoggerConfig.GetAll
local IsStarted = Log4g.Core.LifeCycle.IsStarted
local GetCustomLevel = Log4g.Level.GetCustomLevel
local RegisterCustomLevel = Log4g.Level.RegisterCustomLevel
local UnstartedLoggerConfigSaveFile = "log4g/server/saverestore_loggerconfig_unstarted.json"

--- Save all the LoggerContexts' names into JSON and store it in SQL.
-- @lfunction SaveLoggerContext
local function SaveLoggerContext()
	local LoggerContexts = GetAllLoggerContexts()
	if table.IsEmpty(LoggerContexts) then
		return
	end
	local result = {}

	for k, _ in pairs(LoggerContexts) do
		table.insert(result, k)
	end

	sql.Query(
		"INSERT INTO Log4g_Reconfig (Name, Content) VALUES('LoggerContext', "
			.. sql.SQLStr(util.TableToJSON(result, true))
			.. ")"
	)
end

--- Save all the Unstarted LoggerConfigs' names and associated LoggerContexts' names into a JSON file.
-- @lfunction SaveUnstartedLoggerConfig
local function SaveUnstartedLoggerConfig()
	local configs = GetAllLoggerConfigs()
	if table.IsEmpty(configs) then
		return
	end
	local result = {}

	for k, v in pairs(configs) do
		if not IsStarted(v) then
			table.insert(result, {
				name = k,
				loggercontext = v.loggercontext,
			})
		end
	end

	file.Write(UnstartedLoggerConfigSaveFile, util.TableToJSON(result, true))
end

--- Save all the previously registered Custom Levels.
-- @lfunction SaveCustomLevel
local function SaveCustomLevel()
	local customlevel = GetCustomLevel()
	if table.IsEmpty(customlevel) then
		return
	end
	local result = {}

	for k, v in pairs(customlevel) do
		table.insert(result, {
			name = k,
			int = v.int,
		})
	end

	sql.Query(
		"INSERT INTO Log4g_Reconfig (Name, Content) VALUES('CustomLevel', "
			.. sql.SQLStr(util.TableToJSON(result, true))
			.. ")"
	)
end

local function Save()
	SaveLoggerContext()
	SaveUnstartedLoggerConfig()
	SaveCustomLevel()
end

hook.Add("ShutDown", "Log4g_SaveLogEnvironment", Save)

--- Restore all the LoggerContexts using previously stored names.
-- Their timestarted will be the time when they were restored.
-- @lfunction RestoreLoggerContext
local function RestoreLoggerContext()
	if not sql.QueryRow("SELECT * FROM Log4g_Reconfig WHERE Name = 'LoggerContext';") then
		return
	end
	local tbl = util.JSONToTable(sql.QueryValue("SELECT Content FROM Log4g_Reconfig WHERE Name = 'LoggerContext';"))

	for _, v in pairs(tbl) do
		CreateLoggerContext(v)
	end

	sql.Query("DELETE FROM Log4g_Reconfig WHERE Name = 'LoggerContext';")
end

--- Re-register all the previously unstarted LoggerConfigs.
-- @lfunction RestoreUnstartedLoggerConfig
local function RestoreUnstartedLoggerConfig()
	if not file.Exists(UnstartedLoggerConfigSaveFile, "DATA") then
		return
	end
	local tbl = util.JSONToTable(file.Read(UnstartedLoggerConfigSaveFile, "DATA"))

	for _, v in pairs(tbl) do
		local save = "log4g/server/loggercontext/" .. v.loggercontext .. "/loggerconfig/" .. v.name .. ".json"
		if not file.Exists(save, "DATA") then
			return
		end
		RegisterLoggerConfig(util.JSONToTable(file.Read(save, "DATA")))
	end

	file.Delete(UnstartedLoggerConfigSaveFile)
end

--- Restore all the previously saved Custom Levels.
-- @lfunction RestoreCustomLevel
local function RestoreCustomLevel()
	if not sql.QueryRow("SELECT * FROM Log4g_Reconfig WHERE Name = 'CustomLevel';") then
		return
	end
	local tbl = util.JSONToTable(sql.QueryValue("SELECT Content FROM Log4g_Reconfig WHERE Name = 'CustomLevel';"))

	for _, v in pairs(tbl) do
		RegisterCustomLevel(v.name, v.int)
	end

	sql.Query("DELETE FROM Log4g_Reconfig WHERE Name = 'CustomLevel';")
end

local function Restore()
	RestoreLoggerContext()
	RestoreUnstartedLoggerConfig()
	RestoreCustomLevel()
end

hook.Add("PostGamemodeLoaded", "Log4g_RestoreLogEnvironment", Restore)
