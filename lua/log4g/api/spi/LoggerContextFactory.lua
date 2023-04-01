--- A factory that creates LoggerContext objects.
-- @script LoggerContextFactory
Log4g.API.LoggerContextFactory = Log4g.API.LoggerContextFactory or {}
local RegisterLoggerContext = Log4g.Core.LoggerContext.Register
local RootLoggerConfigClass = Log4g.Core.Config.LoggerConfig.GetRootLoggerConfigClass

--- Create a LoggerContext.
-- This is meant to be used in Programmatic Configuration.
-- @param name String name
-- @param withconfig Whether or not come with a DefaultConfiguration, nil will be treated the same way as true
-- @return object loggercontext
function Log4g.API.LoggerContextFactory.GetContext(name, withconfig)
    if not isstring(name) then return end
    local ctx = RegisterLoggerContext(name, withconfig)

    if withconfig or withconfig == nil then
        ctx:SetConfigurationSource(debug.getinfo(2, "S"))
        local rootlc = RootLoggerConfigClass()()
        ctx:GetConfiguration():AddLogger(rootlc:GetName(), rootlc)
    end

    return ctx
end