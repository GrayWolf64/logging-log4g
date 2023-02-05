--- Automatic reconfiguration (SaveRestore) system for the Logging environment.
-- @script AutoReconfiguration
-- @license Apache License 2.0
-- @copyright GrayWolf64
local sql = sql
local CreateLoggerContext = Log4g.API.LoggerContextFactory.GetContext
local GetAllLoggerContexts = Log4g.Core.LoggerContext.GetAll
local RegisterLoggerConfig = Log4g.Core.Config.LoggerConfig.RegisterLoggerConfig
local GetAllLoggerConfigs = Log4g.Core.Config.LoggerConfig.GetAll
local IsStarted = Log4g.Core.LifeCycle.IsStarted
local GetCustomLevel = Log4g.Level.GetCustomLevel
local RegisterCustomLevel = Log4g.Level.RegisterCustomLevel

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
		"INSERT INTO Log4g_AutoReconfig (Name, Content) VALUES('LoggerContext', "
			.. sql.SQLStr(util.TableToJSON(result, true))
			.. ")"
	)
end

--- Save all the LoggerConfigs' names and associated LoggerContexts' names into a JSON file.
-- @lfunction SaveLoggerConfig
local function SaveLoggerConfig()
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

	sql.Query(
		"INSERT INTO Log4g_AutoReconfig (Name, Content) VALUES('LoggerConfig', "
			.. sql.SQLStr(util.TableToJSON(result, true))
			.. ")"
	)
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
		"INSERT INTO Log4g_AutoReconfig (Name, Content) VALUES('CustomLevel', "
			.. sql.SQLStr(util.TableToJSON(result, true))
			.. ")"
	)
end

local function Save()
	SaveLoggerContext()
	SaveLoggerConfig()
	SaveCustomLevel()
end

hook.Add("ShutDown", "Log4g_SaveLogEnvironment", Save)

--- Restore all the LoggerContexts using previously stored names.
-- Their timestarted will be the time when they were restored.
-- @lfunction RestoreLoggerContext
local function RestoreLoggerContext()
	if not sql.QueryRow("SELECT * FROM Log4g_AutoReconfig WHERE Name = 'LoggerContext';") then
		return
	end
	local tbl = util.JSONToTable(sql.QueryValue("SELECT Content FROM Log4g_AutoReconfig WHERE Name = 'LoggerContext';"))

	for _, v in pairs(tbl) do
		CreateLoggerContext(v)
	end

	sql.Query("DELETE FROM Log4g_AutoReconfig WHERE Name = 'LoggerContext';")
end

--- Re-register all the LoggerConfigs.
-- @lfunction RestoreLoggerConfig
local function RestoreLoggerConfig()
	if not sql.QueryRow("SELECT * FROM Log4g_AutoReconfig WHERE Name = 'LoggerConfig';") then
		return
	end
	local tbl = util.JSONToTable(sql.QueryValue("SELECT Content FROM Log4g_AutoReconfig WHERE Name = 'LoggerConfig';"))

	for _, v in pairs(tbl) do
		local config = sql.QueryValue("SELECT Content FROM Log4g_LoggerConfig WHERE Name = '" .. v.name .. "';")
		if not config then
			return
		end
		RegisterLoggerConfig(util.JSONToTable(config))
	end

	sql.Query("DELETE FROM Log4g_AutoReconfig WHERE Name = 'LoggerConfig';")
end

--- Restore all the previously saved Custom Levels.
-- @lfunction RestoreCustomLevel
local function RestoreCustomLevel()
	if not sql.QueryRow("SELECT * FROM Log4g_AutoReconfig WHERE Name = 'CustomLevel';") then
		return
	end
	local tbl = util.JSONToTable(sql.QueryValue("SELECT Content FROM Log4g_AutoReconfig WHERE Name = 'CustomLevel';"))

	for _, v in pairs(tbl) do
		RegisterCustomLevel(v.name, v.int)
	end

	sql.Query("DELETE FROM Log4g_AutoReconfig WHERE Name = 'CustomLevel';")
end

local function Restore()
	RestoreLoggerContext()
	RestoreLoggerConfig()
	RestoreCustomLevel()
end

hook.Add("PostGamemodeLoaded", "Log4g_RestoreLogEnvironment", Restore)
