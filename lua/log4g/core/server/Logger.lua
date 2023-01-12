--- The Logger.
-- @classmod Logger
Log4g.Logger = Log4g.Logger or {}
Log4g.Inst._Loggers = Log4g.Inst._Loggers or {}
local Logger = include("log4g/core/impl/Class.lua"):Extend()

function Logger:New(name, func, loggerconfig, layout)
    self.name = name or ""
    self.func = func or ""
    self.loggerconfig = loggerconfig or ""
end