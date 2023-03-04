local CreateConfiguration = Log4g.Core.Config.Configuration.Create

function Log4g.Core.Config.GetDefaultConfiguration()
    local configuration = CreateConfiguration("DEFAULT")

    return configuration
end