--- A factory that creates LoggerContext objects.
-- @script LoggerContextFactory
Log4g.API.LoggerContextFactory = Log4g.API.LoggerContextFactory or {}
local RegisterLoggerContext = Log4g.Core.LoggerContext.Register

--- Create a LoggerContext.
-- @param name String name
-- @param withconfig Whether or not come with a DefaultConfiguration, nil will be treated the same way as true
-- @return object loggercontext
function Log4g.API.LoggerContextFactory.GetContext(name, withconfig)
    if not isstring(name) then return end

    return RegisterLoggerContext(name, withconfig)
end