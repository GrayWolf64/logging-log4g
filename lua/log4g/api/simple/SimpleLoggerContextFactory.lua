local RegisterSimpleLoggerContext = Log4g.API.Simple.SimpleLoggerContext.Register

function Log4g.API.SimpleLoggerContextFactory.GetContext(name)
    return RegisterSimpleLoggerContext(name)
end