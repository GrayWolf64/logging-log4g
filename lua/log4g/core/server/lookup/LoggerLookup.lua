--- The Logger Lookup.
-- Logger Lookups contain active loggers' names and associated LoggerContext and LoggerConfig names.
Log4g.Logger.Lookup = Log4g.Logger.Lookup or {}
local File = "log4g/server/loggercontext/lookup_logger.json"

--- Add a table item to Logger Lookup whose key is Logger name and its content are the associated names of LoggerContext and LoggerConfig.
-- If the Lookup doesn't exist, it will create one and write into it.
-- @param loggername The name of the Logger to write
-- @param contextname The name of the LoggerContext to write
-- @param configfile The string filepath of the Logger's associated LoggerConfig to write
function Log4g.Logger.Lookup.AddItem(loggername, contextname, configfile)
    if not file.Exists(File, "DATA") then
        file.Write(File, util.TableToJSON({
            [loggername] = {
                loggercontext = contextname,
                configfile = configfile
            }
        }, true))
    else
        local tbl = util.JSONToTable(file.Read(File, "DATA"))

        tbl[loggername] = {
            loggercontext = contextname,
            configfile = configfile
        }

        file.Write(File, util.TableToJSON(tbl, true))
    end
end

function Log4g.Logger.Lookup.RemoveLoggerViaContext(contextname)
end