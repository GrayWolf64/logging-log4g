--- The Logger Lookup.
-- Logger Lookups contain active loggers' names and associated LoggerContext names and LoggerConfig file paths.
-- @script LoggerLookup
-- @license Apache License 2.0
-- @copyright GrayWolf64
local File = "log4g/server/loggercontext/lookup_logger.json"

--- Add a table item to Logger Lookup whose key is Logger name and its content are the associated names of LoggerContext and file paths of LoggerConfig.
-- If the Lookup doesn't exist, it will create one and write into it.
-- @param loggername The name of the Logger to write
-- @param contextname The name of the LoggerContext to write
-- @param configfile The string filepath of the Logger's associated LoggerConfig to write
function Log4g.Core.Logger.Lookup.AddItem(loggername, contextname, configfile)
	if not file.Exists(File, "DATA") then
		file.Write(
			File,
			util.TableToJSON({
				[loggername] = {
					loggercontext = contextname,
					configfile = configfile,
				},
			}, true)
		)
	else
		local tbl = util.JSONToTable(file.Read(File, "DATA"))

		tbl[loggername] = {
			loggercontext = contextname,
			configfile = configfile,
		}

		file.Write(File, util.TableToJSON(tbl, true))
	end
end

--- Remove any Logger items whose LoggerContext's name is the given contextname.
-- @param contextname The LoggerContext's name
function Log4g.Core.Logger.Lookup.RemoveLoggerViaContext(contextname)
	if not file.Exists(File, "DATA") then
		return
	end
	local tbl = util.JSONToTable(file.Read(File, "DATA"))
	if table.IsEmpty(tbl) then
		return
	end

	for k, v in pairs(tbl) do
		if v.loggercontext == contextname then
			tbl[k] = nil
		end
	end

	file.Write(File, util.TableToJSON(tbl, true))
end

--- Remove a Logger item from LoggerLookup.
-- @param contextname The LoggerContext's name
-- @param loggername The Logger's name
function Log4g.Core.Logger.Lookup.RemoveLogger(contextname, loggername)
	if not file.Exists(File, "DATA") then
		return
	end
	local tbl = util.JSONToTable(file.Read(File, "DATA"))
	if table.IsEmpty(tbl) then
		return
	end

	for k, v in pairs(tbl) do
		if k == loggername and v.loggercontext == contextname then
			tbl[k] = nil
		end
	end

	file.Write(File, util.TableToJSON(tbl, true))
end
