--- The default configuration writes all output to the console using the default logging level.
-- @classmod DefaultConfiguration
local Configuration = Log4g.Core.Config.Configuration.GetClass()
local DefaultConfiguration = Configuration:subclass("DefaultConfiguration")
local CreateConsoleAppender, CreatePatternLayout = Log4g.Core.Appender.CreateConsoleAppender, Log4g.Core.Layout.PatternLayout.CreateDefaultLayout
local DefaultName = CreateConVar("LOG4G_CONFIGURATION_DEFAULT_NAME", "default", FCVAR_NOTIFY, "Default name for DefaultConfiguration."):GetString()
local DefaultLevel = CreateConVar("LOG4G_CONFIGURATION_DEFAULT_LEVEL", "DEBUG", FCVAR_NOTIFY, "Default logging level for DefaultConfiguration."):GetString()

function DefaultConfiguration:Initialize(name)
    Configuration.Initialize(self, name)
    self:SetPrivateField("defaultlevel", DefaultLevel)
end

function Log4g.Core.Config.GetDefaultConfiguration()
    local configuration = DefaultConfiguration(DefaultName)
    configuration:AddAppender(CreateConsoleAppender(DefaultName .. "Appender", CreatePatternLayout(DefaultName .. "Layout")))

    return configuration
end