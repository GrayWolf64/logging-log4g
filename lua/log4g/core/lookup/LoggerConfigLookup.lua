--- The LoggerConfig Lookup.
-- @script LoggerConfigLookup
-- @license Apache License 2.0
-- @copyright GrayWolf64
local LoggerConfigLookup = Log4g.Core.Config.LoggerConfig.Lookup

--- Add a LoggerConfig item to LoggerConfig Lookup.
-- @param name The name of the LoggerConfig
function LoggerConfigLookup.AddConfig(name)
    if not sql.QueryRow("SELECT * FROM Log4g_Lookup WHERE Name = 'LoggerConfig';") then
        sql.Query("INSERT INTO Log4g_Lookup (Name, Content) VALUES('LoggerConfig', " .. sql.SQLStr(util.TableToJSON({
            [name] = {}
        }, true)) .. ")")
    else
        local tbl = sql.QueryRow("SELECT Content FROM Log4g_Lookup WHERE Name = 'LoggerConfig';")
        tbl[name] = {}
        sql.Query("UPDATE Log4g_Lookup SET Content = " .. sql.SQLStr(util.TableToJSON(tbl, true)) .. " WHERE Name = 'LoggerConfig';")
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