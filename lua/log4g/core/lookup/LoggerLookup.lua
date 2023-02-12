--- The Logger Lookup.
-- Logger Lookups contain active loggers' names and associated LoggerContext names and LoggerConfig file paths.
-- @script LoggerLookup
-- @license Apache License 2.0
-- @copyright GrayWolf64
local LoggerLookup = Log4g.Core.Logger.Lookup
local SQLQueryRow = Log4g.Util.SQLQueryRow
local SQLQueryValue = Log4g.Util.SQLQueryValue
local SQLInsert = Log4g.Util.SQLInsert
local UpdateLookup = Log4g.Util.SQLUpdateValue

--- Add a table item to Logger Lookup whose key is Logger name and its content are the associated names of LoggerContext and file paths of LoggerConfig.
-- If the Lookup doesn't exist, it will create one and write into it.
-- @param loggername The name of the Logger to write
-- @param contextname The name of the LoggerContext to write
function LoggerLookup.AddItem(loggername, contextname)
    if not SQLQueryRow("Log4g_Lookup", "Logger") then
        SQLInsert("Log4g_Lookup", "Logger", sql.SQLStr(util.TableToJSON({
            [loggername] = {
                loggercontext = contextname,
            },
        }, true)))
    else
        local tbl = util.JSONToTable(SQLQueryValue("Log4g_Lookup", "Logger"))

        tbl[loggername] = {
            loggercontext = contextname,
        }

        UpdateLookup("Log4g_Lookup", "Logger", util.TableToJSON(tbl))
    end
end

--- Remove any Logger items whose LoggerContext's name is the given contextname.
-- @param contextname The LoggerContext's name
function LoggerLookup.RemoveLoggerViaContext(contextname)
    if not SQLQueryRow("Log4g_Lookup", "Logger") then return end
    local tbl = util.JSONToTable(SQLQueryValue("Log4g_Lookup", "Logger"))
    if table.IsEmpty(tbl) then return end

    for k, v in pairs(tbl) do
        if v.loggercontext == contextname then
            tbl[k] = nil
        end
    end

    UpdateLookup("Log4g_Lookup", "Logger", util.TableToJSON(tbl))
end

--- Remove a Logger item from LoggerLookup.
-- @param contextname The LoggerContext's name
-- @param loggername The Logger's name
function LoggerLookup.RemoveLogger(contextname, loggername)
    if not SQLQueryRow("Log4g_Lookup", "Logger") then return end
    local tbl = util.JSONToTable(SQLQueryValue("Log4g_Lookup", "Logger"))
    if table.IsEmpty(tbl) then return end

    for k, v in pairs(tbl) do
        if k == loggername and v.loggercontext == contextname then
            tbl[k] = nil
        end
    end

    UpdateLookup("Log4g_Lookup", "Logger", util.TableToJSON(tbl))
end