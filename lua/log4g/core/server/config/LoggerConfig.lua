Log4g.LoggerConfigs = {}
local Object = include("log4g/core/server/Class.lua")
local LoggerConfig = Object:Extend()

function LoggerConfig:New(name, tbl, file)
    self.name = name or ""

    self.content = {
        eventname = tbl.eventname or "",
        uid = tbl.uid or "",
        loggercontext = tbl.loggercontext or "",
        level = tbl.level or "",
        appender = tbl.appender or "",
        layout = tbl.layout or ""
    }

    self.file = file or ""
end

function LoggerConfig:Delete()
    self.name = nil
    self.content = nil
    self.file = nil
end

function Log4g.NewLoggerConfig(name, tbl, file)
    local loggerconfig = LoggerConfig(name, tbl, file)
    table.insert(Log4g.LoggerConfigs, loggerconfig)

    return loggerconfig
end