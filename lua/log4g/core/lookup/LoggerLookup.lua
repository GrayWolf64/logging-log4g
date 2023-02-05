--- The Logger Lookup.
-- Logger Lookups contain active loggers' names and associated LoggerContext names and LoggerConfig file paths.
-- @script LoggerLookup
-- @license Apache License 2.0
-- @copyright GrayWolf64
local sql = sql
local LoggerLookup = Log4g.Core.Logger.Lookup

local function UpdateLookup(tbl)
	sql.Query(
		"UPDATE Log4g_Lookup SET Content = " .. sql.SQLStr(util.TableToJSON(tbl, true)) .. " WHERE Name = 'Logger';"
	)
end

--- Add a table item to Logger Lookup whose key is Logger name and its content are the associated names of LoggerContext and file paths of LoggerConfig.
-- If the Lookup doesn't exist, it will create one and write into it.
-- @param loggername The name of the Logger to write
-- @param contextname The name of the LoggerContext to write
-- @param configfile The string filepath of the Logger's associated LoggerConfig to write
function LoggerLookup.AddItem(loggername, contextname, configfile)
	if not sql.QueryRow("SELECT * FROM Log4g_Lookup WHERE Name = 'Logger';") then
		sql.Query("INSERT INTO Log4g_Lookup (Name, Content) VALUES('Logger', " .. sql.SQLStr(util.TableToJSON({
			[loggername] = {
				loggercontext = contextname,
				configfile = configfile,
			},
		}, true)) .. ")")
	else
		local tbl = util.JSONToTable(sql.QueryValue("SELECT Content FROM Log4g_Lookup WHERE Name = 'Logger';"))

		tbl[loggername] = {
			loggercontext = contextname,
			configfile = configfile,
		}

		UpdateLookup(tbl)
	end
end

--- Remove any Logger items whose LoggerContext's name is the given contextname.
-- @param contextname The LoggerContext's name
function LoggerLookup.RemoveLoggerViaContext(contextname)
	if not sql.QueryRow("SELECT * FROM Log4g_Lookup WHERE Name = 'Logger';") then
		return
	end
	local tbl = util.JSONToTable(sql.QueryValue("SELECT Content FROM Log4g_Lookup WHERE Name = 'Logger';"))
	if table.IsEmpty(tbl) then
		return
	end

	for k, v in pairs(tbl) do
		if v.loggercontext == contextname then
			tbl[k] = nil
		end
	end

	UpdateLookup(tbl)
end

--- Remove a Logger item from LoggerLookup.
-- @param contextname The LoggerContext's name
-- @param loggername The Logger's name
function LoggerLookup.RemoveLogger(contextname, loggername)
	if not sql.QueryRow("SELECT * FROM Log4g_Lookup WHERE Name = 'Logger';") then
		return
	end
	local tbl = util.JSONToTable(sql.QueryValue("SELECT Content FROM Log4g_Lookup WHERE Name = 'Logger';"))
	if table.IsEmpty(tbl) then
		return
	end

	for k, v in pairs(tbl) do
		if k == loggername and v.loggercontext == contextname then
			tbl[k] = nil
		end
	end

	UpdateLookup(tbl)
end
