--- The default configuration writes all output to the console using the default logging level.
-- @classmod DefaultConfiguration
local Configuration = Log4g.Core.Config.Configuration.getClass()
local DefaultConfiguration = DefaultConfiguration or Configuration:subclass"DefaultConfiguration"
local CreateConsoleAppender, CreatePatternLayout = Log4g.Core.Appender.ConsoleAppender.createConsoleAppender, Log4g.Core.Layout.PatternLayout.createDefaultLayout
CreateConVar("log4g_configuration_default_level", "DEBUG", FCVAR_NOTIFY):GetString()

function DefaultConfiguration:Initialize()
    Configuration.Initialize(self)
    -- self:SetPrivateField("defaultlevel", GetConVar"log4g_configuration_default_level":GetString())
end

function Log4g.Core.Config.GetDefaultConfiguration()
    local configuration = DefaultConfiguration()
    configuration:AddAppender(CreateConsoleAppender("Appender", CreatePatternLayout("Layout")))

    return configuration
end