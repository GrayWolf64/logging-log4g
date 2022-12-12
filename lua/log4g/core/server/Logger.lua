Log4g.Loggers = {}
local Logger = include("log4g/core/server/impl/Class.lua"):Extend()

function Logger:New(name, func, loggerconfig, layout)
    self.name = name or ""
    self.func = func or ""
    self.loggerconfig = loggerconfig or ""
    self.layout = layout or ""
end