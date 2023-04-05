Log4g.API.Simple.SimpleLoggerContextFactory = Log4g.API.Simple.SimpleLoggerContextFactory or {}
local RegisterSimpleLoggerContext = Log4g.API.Simple.SimpleLoggerContext.Register

function Log4g.API.Simple.SimpleLoggerContextFactory.GetContext(name)
    return RegisterSimpleLoggerContext(name)
end