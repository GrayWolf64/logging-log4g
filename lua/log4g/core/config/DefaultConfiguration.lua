Log4g.Core.Config.DEFAULT_NAME = "Default"
local DEFAULT_NAME = Log4g.Core.Config.DEFAULT_NAME
local Configuration = Log4g.Core.Config.Configuration.GetClass()
local DefaultConfiguration = Configuration:subclass("DefaultConfiguration")
local CreateConsoleAppender, CreatePatternLayout = Log4g.Core.Appender.CreateConsoleAppender, Log4g.Core.Layout.CreatePatternLayout

function DefaultConfiguration:Initialize(name)
    Configuration.Initialize(self)
    self.name = name
end

function Log4g.Core.Config.GetDefaultConfiguration()
    local configuration = DefaultConfiguration(DEFAULT_NAME)
    configuration:AddAppender(CreateConsoleAppender(DEFAULT_NAME .. "Appender", CreatePatternLayout(DEFAULT_NAME .. "Layout")))

    return configuration
end