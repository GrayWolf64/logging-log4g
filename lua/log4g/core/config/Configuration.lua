--- Interface that must be implemented to create a Configuration.
-- Subclassing `LifeCycle`, mixin-ing `SetContext()` and `GetContext()`.
-- @classmod Configuration
-- @license Apache License 2.0
-- @copyright GrayWolf64
local LifeCycle = Log4g.GetPkgClsFuncs("log4g-core", "LifeCycle").getClass()
local IsAppender = Log4g.GetPkgClsFuncs("log4g-core", "TypeUtil").IsAppender
local PropertiesPlugin = Log4g.GetPkgClsFuncs("log4g-core", "PropertiesPlugin")
local Configuration = LifeCycle:subclass"Configuration"
Configuration:include(Log4g.GetPkgClsFuncs("log4g-core", "Object").contextualMixins)
local SysTime = SysTime

function Configuration:Initialize(name)
    LifeCycle.Initialize(self)
    self:SetPrivateField("ap", {})
    self:SetPrivateField("lc", {})
    self:SetPrivateField("start", SysTime())
    self:SetName(name)
end

function Configuration:__tostring()
    return "Configuration: [name:" .. self:GetName() .. "]"
end

--- Adds a Appender to the Configuration.
-- @param ap The Appender to add
-- @return bool ifsuccessfullyadded
function Configuration:AddAppender(ap)
    if not IsAppender(ap) then return end
    if self:GetPrivateField"ap"[ap:GetName()] then return false end
    self:GetPrivateField"ap"[ap:GetName()] = ap

    return true
end

function Configuration:RemoveAppender(name)
    self:GetPrivateField"ap"[name] = nil
end

--- Gets all the Appenders in the Configuration.
-- Keys are the names of Appenders and values are the Appenders themselves.
-- @return table appenders
function Configuration:GetAppenders()
    return self:GetPrivateField"ap"
end

function Configuration:AddLogger(name, lc)
    self:GetPrivateField"lc"[name] = lc
end

--- Locates the appropriate LoggerConfig name for a Logger name.
-- @param name The Logger name
-- @return object loggerconfig
function Configuration:GetLoggerConfig(name)
    return self:GetPrivateField"lc"[name]
end

function Configuration:GetLoggerConfigs()
    return self:GetPrivateField"lc"
end

function Configuration:GetRootLogger()
    return self:GetPrivateField"lc"[PropertiesPlugin.getProperty("rootLoggerName", true)]
end

--- Gets how long since this Configuration initialized.
-- @return int uptime
function Configuration:GetUpTime()
    return SysTime() - self:GetPrivateField"start"
end

--- Create a Configuration.
-- @param name The name of the Configuration
-- @return object configuration
local function Create(name)
    if type(name) ~= "string" then return end

    return Configuration(name)
end

local function GetClass()
    return Configuration
end

--- The default configuration writes all output to the Console using the default logging level.
-- @type DefaultConfiguration
local DefaultConfiguration = Configuration:subclass"DefaultConfiguration"
local Appender = Log4g.GetPkgClsFuncs("log4g-core", "Appender")
local CreateConsoleAppender, CreatePatternLayout = Appender.createConsoleAppender, Appender.createDefaultPatternLayout
PropertiesPlugin.registerProperty("configurationDefaultName", "default", true)
PropertiesPlugin.registerProperty("configurationDefaultLevel", "DEBUG", true)

--- Initialize the DefaultConfiguration.
-- @param name String name.
function DefaultConfiguration:Initialize(name)
    Configuration.Initialize(self, name)
    self:SetPrivateField("defaultlevel", PropertiesPlugin.getProperty("configurationDefaultLevel", true))
end

local function GetDefaultConfiguration()
    local name = PropertiesPlugin.getProperty("configurationDefaultName", true)
    local configuration = DefaultConfiguration(name)
    configuration:AddAppender(CreateConsoleAppender(name .. "Appender", CreatePatternLayout(name .. "Layout")))

    return configuration
end

Log4g.RegisterPackageClass("log4g-core", "Configuration", {
    getClass = GetClass,
    create = Create,
    getDefaultConfiguration = GetDefaultConfiguration
})