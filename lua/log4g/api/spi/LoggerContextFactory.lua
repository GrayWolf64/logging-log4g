--- A factory that creates LoggerContext objects.
-- @script LoggerContextFactory
Log4g.API.LoggerContextFactory = Log4g.API.LoggerContextFactory or {}
local RegisterLoggerContext = Log4g.Core.LoggerContext.Register
local GetRootLoggerConfigClass = Log4g.Core.Config.LoggerConfig.GetRootLoggerConfigClass
local ROOT = Log4g.Core.Config.LoggerConfig.ROOT

--- Create a LoggerContext.
-- This is meant to be used in Programmatic Configuration.
-- @param name String name
-- @param withconfig Whether or not come with a DefaultConfiguration, nil will be treated the same way as true
-- @return object loggercontext
function Log4g.API.LoggerContextFactory.GetContext(name, withconfig)
    if not isstring(name) then return end
    local ctx = RegisterLoggerContext(name, withconfig)
    ctx:SetConfigurationSource(debug.getinfo(2, "S"))

    if withconfig ~= false then
        local rootlogger = GetRootLoggerConfigClass()()
        rootlogger:SetContext(name)
        ctx:GetConfiguration():AddLogger(ROOT, rootlogger)
    end

    return ctx
end