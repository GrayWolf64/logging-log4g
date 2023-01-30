--- The LoggerContext Lookup.
-- LoggerContext Lookups contain LoggerContext names and associated LoggerConfig (not started) names in the form of a table.
-- If a LoggerConfig has started (been built and applied to a Logger), it will be removed from LoggerContext Lookup.
-- This is currently used for populating client's LoggerConfig DTree.
-- @script LoggerContextLookup
-- @license Apache License 2.0
-- @copyright GrayWolf64
      Log4g.Core.LoggerContext.Lookup = Log4g.Core.LoggerContext.Lookup or {}
local HasKey                          = Log4g.Util.HasKey
local File                            = "log4g/server/loggercontext/lookup_loggercontext.json"

--- Add a string item to LoggerContext Lookup whether it's the name of a LoggerContext or LoggerConfig.
-- If the LoggerContext Lookup file doesn't exist, a new file will be created and data will be written into.
-- If the file exists, new data will be written into while keeping the previous data.
-- @param contextname The LoggerContext name to write
-- @param configname The LoggerConfig name to write
function Log4g.Core.LoggerContext.Lookup.AddItem(contextname, configname)
    if not file.Exists(File, "DATA") then
        file.Write(File, util.TableToJSON({
            [contextname] = {configname}
        }, true))
    else
        local tbl = util.JSONToTable(file.Read(File, "DATA"))
        local bool, key = HasKey(tbl, contextname)

        if bool then
            table.insert(tbl[key], configname)
        else
            tbl[contextname] = {configname}
        end

        file.Write(File, util.TableToJSON(tbl, true))
    end
end

--- Remove a LoggerContext name item from the LoggerContext Lookup.
-- The child LoggerConfig names will be removed at the same time.
-- @param name The name of the LoggerContext to find and remove from the Lookup table
function Log4g.Core.LoggerContext.Lookup.RemoveLoggerContext(name)
    local tbl = util.JSONToTable(file.Read(File, "DATA"))

    for k, _ in pairs(tbl) do
        if k == name then
            tbl[k] = nil
        end
    end

    file.Write(File, util.TableToJSON(tbl))
end

--- Remove a LoggerConfig name item from the LoggerContext Lookup.
-- @param contextname The name of the LoggerContext that the LoggerConfig is in
-- @param configname The name of the LoggerConfig to find and remove from the Lookup table
function Log4g.Core.LoggerContext.Lookup.RemoveLoggerConfig(contextname, configname)
    local tbl = util.JSONToTable(file.Read(File, "DATA"))

    for k, v in pairs(tbl) do
        if k == contextname then
            for i, j in ipairs(v) do
                if j == configname then
                    table.remove(v, i)
                end
            end
        end
    end

    file.Write(File, util.TableToJSON(tbl))
end