--- The LoggerContext Lookup.
-- This type of LoggerContext Lookups contains LoggerContext names and associated LoggerConfig names in the form of a table.
-- @script LoggerContextLookup
-- @license Apache License 2.0
-- @copyright GrayWolf64
local HasKey              = Log4g.Util.HasKey
local File                = "log4g/server/loggercontext/lookup_loggercontext.json"
local LoggerContextLookup = Log4g.Core.LoggerContext.Lookup

--- Add a LoggerContext item to LoggerContext Lookup.
-- @param name The name of the LoggerContext
function LoggerContextLookup.AddContext(name)
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

--- Add a LoggerConfig name item to LoggerContext Lookup depending on its LoggerContext name.
-- If the LoggerContext Lookup file doesn't exist, a new file will be created and data will be written into.
-- If the file exists, new data will be written into while keeping the previous data.
-- @param context The LoggerContext name to put the LoggerConfig in
-- @param config The LoggerConfig name to write
function LoggerContextLookup.AddConfig(context, config)
    if not file.Exists(File, "DATA") then
        file.Write(File, util.TableToJSON({
            [context] = {config}
        }, true))
    else
        local tbl = util.JSONToTable(file.Read(File, "DATA"))
        local bool, key = HasKey(tbl, context)

        if bool then
            table.insert(tbl[key], config)
        else
            tbl[context] = {config}
        end

        file.Write(File, util.TableToJSON(tbl, true))
    end
end

--- Remove a LoggerContext name item from the LoggerContext Lookup.
-- The child LoggerConfig names will be removed at the same time.
-- @param name The name of the LoggerContext to find and remove from the Lookup table
function LoggerContextLookup.RemoveContext(name)
    if not file.Exists(File, "DATA") then return end
    local tbl = util.JSONToTable(file.Read(File, "DATA"))

    for k, _ in pairs(tbl) do
        if k == name then
            tbl[k] = nil
        end
    end

    file.Write(File, util.TableToJSON(tbl))
end

--- Remove a LoggerConfig name item from the LoggerContext Lookup.
-- @param context The name of the LoggerContext that the LoggerConfig is in
-- @param config The name of the LoggerConfig to find and remove from the Lookup table
function LoggerContextLookup.RemoveConfig(context, config)
    if not file.Exists(File, "DATA") then return end
    local tbl = util.JSONToTable(file.Read(File, "DATA"))

    for k, v in pairs(tbl) do
        if k == context then
            for i, j in ipairs(v) do
                if j == config then
                    table.remove(v, i)
                end
            end
        end
    end

    file.Write(File, util.TableToJSON(tbl))
end