Log4g.Core.LoggerContext.Lookup = Log4g.Core.LoggerContext.Lookup or {}
local HasKey = Log4g.Util.HasKey
local File = "log4g/server/loggercontext/lookup_loggercontext.json"

function Log4g.Core.LoggerContext.Lookup.Add(contextname, configname)
    if not file.Exists(File, "DATA") then
        file.Write(File, util.TableToJSON({
            [contextname] = {configname}
        }, true))
    else
        local tbl = util.JSONToTable(file.Read(File, "DATA"))
        local bool, Key = HasKey(tbl, contextname)

        if bool then
            table.insert(tbl[Key], configname)
        else
            tbl[contextname] = {configname}
        end

        file.Write(File, util.TableToJSON(tbl, true))
    end
end

function Log4g.Core.LoggerContext.Lookup.RemoveLoggerContext(name)
    local tbl = util.JSONToTable(file.Read(File, "DATA"))

    for k, _ in pairs(tbl) do
        if k == name then
            tbl[k] = nil
        end
    end

    file.Write(File, util.TableToJSON(tbl))
end