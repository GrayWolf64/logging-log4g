local RegisterConfiguration = Log4g.Core.Config.Configuration.Register

function Log4g.Core.Config.GetDefaultConfiguration()
    local configuration = RegisterConfiguration("DEFAULT")

    return configuration
end