--- The LoggerContext Lookup.
-- This type of LoggerContext Lookups contains LoggerContext names and associated LoggerConfig names in the form of a table.
-- @script LoggerContextLookup
-- @license Apache License 2.0
-- @copyright GrayWolf64
local sql = sql
local HasKey = Log4g.Util.HasKey
local LoggerContextLookup = Log4g.Core.LoggerContext.Lookup

local function UpdateLookup(tbl)
	sql.Query(
		"UPDATE Log4g_Lookup SET Content = "
			.. sql.SQLStr(util.TableToJSON(tbl, true))
			.. " WHERE Name = 'LoggerContext';"
	)
end

--- Add a LoggerContext item to LoggerContext Lookup.
-- @param name The name of the LoggerContext
function LoggerContextLookup.AddContext(name)
	if not sql.QueryRow("SELECT * FROM Log4g_Lookup WHERE Name = 'LoggerContext';") then
		sql.Query("INSERT INTO Log4g_Lookup (Name, Content) VALUES('LoggerContext', " .. sql.SQLStr(util.TableToJSON({
			[name] = {},
		}, true)) .. ")")
	else
		local tbl = util.JSONToTable(sql.QueryValue("SELECT Content FROM Log4g_Lookup WHERE Name = 'LoggerContext';"))
		tbl[name] = {}
		UpdateLookup(tbl)
	end
end

--- Remove a LoggerContext name item from the LoggerContext Lookup.
-- The child LoggerConfig names will be removed at the same time.
-- @param name The name of the LoggerContext to find and remove from the Lookup table
function LoggerContextLookup.RemoveContext(name)
	if not sql.QueryRow("SELECT * FROM Log4g_Lookup WHERE Name = 'LoggerContext';") then
		return
	end
	local tbl = util.JSONToTable(sql.QueryValue("SELECT Content FROM Log4g_Lookup WHERE Name = 'LoggerContext';"))

	for k, _ in pairs(tbl) do
		if k == name then
			tbl[k] = nil
		end
	end

	UpdateLookup(tbl)
end

--- Add a LoggerConfig name item to LoggerContext Lookup depending on its LoggerContext name.
-- If the LoggerContext Lookup file doesn't exist, a new file will be created and data will be written into.
-- If the file exists, new data will be written into while keeping the previous data.
-- @param context The LoggerContext name to put the LoggerConfig in
-- @param config The LoggerConfig name to write
function LoggerContextLookup.AddConfig(context, config)
	if not sql.QueryRow("SELECT * FROM Log4g_Lookup WHERE Name = 'LoggerContext';") then
		sql.Query("INSERT INTO Log4g_Lookup (Name, Content) VALUES('LoggerContext', " .. sql.SQLStr(util.TableToJSON({
			[context] = { config },
		}, true)) .. ")")
	else
		local tbl = util.JSONToTable(sql.QueryValue("SELECT Content FROM Log4g_Lookup WHERE Name = 'LoggerContext';"))
		local bool, key = HasKey(tbl, context)

		if bool then
			table.insert(tbl[key], config)
		else
			tbl[context] = { config }
		end

		UpdateLookup(tbl)
	end
end

--- Remove a LoggerConfig name item from the LoggerContext Lookup.
-- @param context The name of the LoggerContext that the LoggerConfig is in
-- @param config The name of the LoggerConfig to find and remove from the Lookup table
function LoggerContextLookup.RemoveConfig(context, config)
	if not sql.QueryRow("SELECT * FROM Log4g_Lookup WHERE Name = 'LoggerContext';") then
		return
	end
	local tbl = util.JSONToTable(sql.QueryValue("SELECT Content FROM Log4g_Lookup WHERE Name = 'LoggerContext';"))

	for k, v in pairs(tbl) do
		if k == context then
			for i, j in ipairs(v) do
				if j == config then
					table.remove(v, i)
				end
			end
		end
	end

	UpdateLookup(tbl)
end
