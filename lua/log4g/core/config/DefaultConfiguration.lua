local Configuration = Log4g.Core.Config.Configuration.GetClass()
local DefaultConfiguration = Configuration:subclass("DefaultConfiguration")
local CreateConsoleAppender, CreatePatternLayout = Log4g.Core.Appender.CreateConsoleAppender, Log4g.Core.Layout.PatternLayout.CreateDefaultLayout

function DefaultConfiguration:Initialize(name)
    Configuration.Initialize(self, name)
end

function Log4g.Core.Config.GetDefaultConfiguration()
    local name = LOG4G_CONFIGURATION_DEFAULT_NAME
    local configuration = DefaultConfiguration(name)
    configuration:AddAppender(CreateConsoleAppender(name .. "Appender", CreatePatternLayout(name .. "Layout")))

    return configuration
end