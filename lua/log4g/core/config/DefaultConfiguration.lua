--- The default configuration writes all output to the console using the default logging level.
-- @classmod DefaultConfiguration
local Configuration = Log4g.Core.Config.Configuration.getClass()
local DefaultConfiguration = Configuration:subclass"DefaultConfiguration"
local CreateConsoleAppender, CreatePatternLayout = Log4g.GetPkgClsFuncs("log4g-core", "ConsoleAppender").createConsoleAppender, Log4g.GetPkgClsFuncs("log4g-core", "PatternLayout").createDefaultLayout
CreateConVar("log4g_configuration_default_name", "default", FCVAR_NOTIFY):GetString()
CreateConVar("log4g_configuration_default_level", "DEBUG", FCVAR_NOTIFY):GetString()

function DefaultConfiguration:Initialize(name)
    Configuration.Initialize(self, name)
    -- self:SetPrivateField("defaultlevel", GetConVar"log4g_configuration_default_level":GetString())
end

function Log4g.Core.Config.GetDefaultConfiguration()
    local name = GetConVar"log4g_configuration_default_name":GetString()
    local configuration = DefaultConfiguration(name)
    configuration:AddAppender(CreateConsoleAppender(name .. "Appender", CreatePatternLayout(name .. "Layout")))

    return configuration
end