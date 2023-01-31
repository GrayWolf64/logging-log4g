--- The LoggerConfig Lookup.
-- @script LoggerConfigLookup
-- @license Apache License 2.0
-- @copyright GrayWolf64
local File               = "log4g/server/loggercontext/lookup_loggerconfig.json"
local LoggerConfigLookup = Log4g.Core.Config.LoggerConfig.Lookup

--- Add a LoggerContext item to LoggerContext Lookup.
-- @param name The name of the LoggerContext
function LoggerConfigLookup.AddConfig(name)
    if not file.Exists(File, "DATA") then
        file.Write(File, util.TableToJSON({
            [name] = {}
        }, true))
    else
        local tbl = util.JSONToTable(file.Read(File, "DATA"))
        tbl[name] = {}
        file.Write(File, util.TableToJSON(tbl, true))
    end
end