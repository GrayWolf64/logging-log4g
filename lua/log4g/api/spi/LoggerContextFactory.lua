--- A factory that creates LoggerContext objects.
-- @script LoggerContextFactory
Log4g.API.LoggerContextFactory = Log4g.API.LoggerContextFactory or {}
local HasKey = Log4g.Util.HasKey
local RegisterLoggerContext = Log4g.Core.LoggerContext.Register
--- This is where all the LoggerContexts are stored.
-- LoggerContexts may include some Loggers which may also include Appender, Level objects and so on.
-- @local
-- @table INSTANCES
local INSTANCES = INSTANCES or {}

--- Create a LoggerContext.
-- @param name The name of the LoggerContext
function Log4g.API.LoggerContextFactory.GetContext(name)
    RegisterLoggerContext(INSTANCES, name)
end

--- Check if a LoggerContext with the given name exists.
-- If the LoggerContext exists, return true.
-- @param name The name of the LoggerContext
-- @return bool hascontext
function Log4g.API.LoggerContextFactory.HasContext(name)
    return HasKey(INSTANCES, name)
end

--- Get all the LoggerContexts.
-- @return table instances
function Log4g.API.LoggerContextFactory.GetContextAll()
    return INSTANCES
end