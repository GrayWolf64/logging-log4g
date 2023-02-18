--- A factory that creates LoggerContext objects.
-- @script LoggerContextFactory
Log4g.API.LoggerContextFactory = Log4g.API.LoggerContextFactory or {}
local RegisterLoggerContext = Log4g.Core.LoggerContext.Register
local GetCurrentFQSN = Log4g.Util.GetCurrentFQSN

--- Create a LoggerContext.
-- @param T String name or a function to get FQSN
function Log4g.API.LoggerContextFactory.GetContext(T)
    if isstring(T) then
        return RegisterLoggerContext(T)
    elseif isfunction(T) then
        return RegisterLoggerContext(GetCurrentFQSN(T))
    end
end