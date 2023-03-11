local Accessor = Log4g.Core.Config
Accessor.DEFAULT_NAME = "Default"
local Configuration = Log4g.Core.Config.Configuration.GetClass()
local DefaultConfiguration = Configuration:subclass("DefaultConfiguration")
local CreateConsoleAppender, CreatePatternLayout = Log4g.Core.Appender.CreateConsoleAppender, Log4g.Core.Layout.CreatePatternLayout

function DefaultConfiguration:Initialize(name)
    Configuration.Initialize(self)
    self.name = name
end

function Accessor.GetDefaultConfiguration()
    local configuration = DefaultConfiguration(Accessor.DEFAULT_NAME)
    configuration:AddAppender(CreateConsoleAppender(Accessor.DEFAULT_NAME .. "Appender", CreatePatternLayout(Accessor.DEFAULT_NAME .. "Layout")))

    return configuration
end