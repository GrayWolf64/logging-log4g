--- A factory that creates LoggerContext objects.
-- @script LoggerContextFactory
Log4g.API.LoggerContextFactory = Log4g.API.LoggerContextFactory or {}
local RegisterLoggerContext = Log4g.Core.LoggerContext.Register

--- Create a LoggerContext.
-- @param name String name
-- @return object loggercontext
function Log4g.API.LoggerContextFactory.GetContext(name)
    if not isstring(name) then return end

    return RegisterLoggerContext(T)
end