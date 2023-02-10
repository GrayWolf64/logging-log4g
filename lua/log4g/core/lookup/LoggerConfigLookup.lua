--- The LoggerConfig Lookup.
-- Now it stores all the LoggerConfigs' names in a table which is converted to JSON then stored in SQL.
-- @script LoggerConfigLookup
-- @license Apache License 2.0
-- @copyright GrayWolf64
local sql = sql
local SQLQueryNamedRow = Log4g.Util.SQLQueryNamedRow
local SQLQueryValue = Log4g.Util.SQLQueryValue
local UpdateLookup = Log4g.Util.SQLUpdateValue
local LoggerConfigLookup = Log4g.Core.Config.LoggerConfig.Lookup

--- Add a LoggerConfig item to LoggerConfig Lookup.
-- @param name The name of the LoggerConfig
function LoggerConfigLookup.AddConfig(name)
	if not SQLQueryNamedRow("Log4g_Lookup", "LoggerConfig") then
		sql.Query("INSERT INTO Log4g_Lookup (Name, Content) VALUES('LoggerConfig', " .. sql.SQLStr(util.TableToJSON({
			[name] = {},
		}, true)) .. ")")
	else
		local tbl = util.JSONToTable(SQLQueryValue("Log4g_Lookup", "LoggerConfig"))
		tbl[name] = {}
		UpdateLookup("Log4g_Lookup", "LoggerConfig", util.TableToJSON(tbl))
	end
end

--- Remove the LoggerConfig item from LoggerConfig Lookup.
-- @param name The name of the LoggerConfig
function LoggerConfigLookup.RemoveConfig(name)
	if not SQLQueryNamedRow("Log4g_Lookup", "LoggerConfig") then
		return
	end
	local tbl = util.JSONToTable(SQLQueryValue("Log4g_Lookup", "LoggerConfig"))

	for k, _ in pairs(tbl) do
		if k == name then
			tbl[k] = nil
		end
	end

	UpdateLookup("Log4g_Lookup", "LoggerConfig", util.TableToJSON(tbl))
end
