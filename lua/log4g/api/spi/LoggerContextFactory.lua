--- A factory that creates LoggerContext objects.
-- @script LoggerContextFactory
local RegisterLoggerContext = Log4g.Core.LoggerContext.RegisterLoggerContext
--- This is where all the LoggerContexts are stored.
-- LoggerContexts may include some Loggers which may also include Appender, Level objects and so on.
-- @local
-- @table Instances
local Instances = Instances or {}

function Log4g.API.GetContext(name)
    RegisterLoggerContext(Instances, name)
end