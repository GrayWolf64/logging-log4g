--- The LoggerConfig Lookup.
-- Now it stores all the LoggerConfigs' names in a table which is converted to JSON then stored in SQL.
-- @script LoggerConfigLookup
-- @license Apache License 2.0
-- @copyright GrayWolf64
local sql = sql
local SQLQueryNamedRow = Log4g.Util.SQLQueryNamedRow
local SQLQueryValue = Log4g.Util.SQLQueryValue
local LoggerConfigLookup = Log4g.Core.Config.LoggerConfig.Lookup

local function UpdateLookup(tbl)
	sql.Query(
		"UPDATE Log4g_Lookup SET Content = "
			.. sql.SQLStr(util.TableToJSON(tbl, true))
			.. " WHERE Name = 'LoggerConfig';"
	)
end

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
		UpdateLookup(tbl)
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

	UpdateLookup(tbl)
end
