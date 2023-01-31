--- The LoggerConfig Lookup.
-- @script LoggerConfigLookup
-- @license Apache License 2.0
-- @copyright GrayWolf64
local File               = "log4g/server/loggercontext/lookup_loggerconfig.json"
local LoggerConfigLookup = Log4g.Core.Config.LoggerConfig.Lookup

--- Add a LoggerConfig item to LoggerConfig Lookup.
-- @param name The name of the LoggerConfig
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

--- Remove the LoggerConfig item from LoggerConfig Lookup.
-- @param name The name of the LoggerConfig
function LoggerConfigLookup.RemoveConfig(name)
    if not file.Exists(File, "DATA") then return end
    local tbl = util.JSONToTable(file.Read(File, "DATA"))

    for k, _ in pairs(tbl) do
        if k == name then
            tbl[k] = nil
        end
    end

    file.Write(File, util.TableToJSON(tbl))
end