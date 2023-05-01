--- The LoggerContext, which is the anchor for the logging system.
-- Subclassing `LifeCycle`.
-- It maintains a list of all the loggers requested by users and a reference to the Configuration.
-- @classmod LoggerContext
-- @license Apache License 2.0
-- @copyright GrayWolf64
local LifeCycle = Log4g.GetPkgClsFuncs("log4g-core", "LifeCycle").getClass()
local TypeUtil = Log4g.GetPkgClsFuncs("log4g-core", "TypeUtil")
local IsAppender = TypeUtil.IsAppender
local PropertiesPlugin = Log4g.GetPkgClsFuncs("log4g-core", "PropertiesPlugin")
--- Interface that must be implemented to create a Configuration.
-- @type Configuration
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
local function CreateConfiguration(name)
    if type(name) ~= "string" then return end

    return Configuration(name)
end

local function GetConfigurationClass()
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

--- Gets a DefaultConfiguration.
-- @section end
local function GetDefaultConfiguration()
    local name = PropertiesPlugin.getProperty("configurationDefaultName", true)
    local configuration = DefaultConfiguration(name)
    configuration:AddAppender(CreateConsoleAppender(name .. "Appender", CreatePatternLayout(name .. "Layout")))

    return configuration
end

local LoggerContext = LifeCycle:subclass"LoggerContext"
local IsLoggerContext, IsConfiguration = TypeUtil.IsLoggerContext, TypeUtil.IsConfiguration
TypeUtil = nil
local getContextDict = Log4g.Core.getContextDict
local addToContextDict = Log4g.Core.addToContextDict
local pairs = pairs
local type = type

function LoggerContext:Initialize(name)
    LifeCycle.Initialize(self)
    self:SetPrivateField("logger", {})
    self:SetName(name)
end

--- Sets the Configuration source for the LoggerContext.
-- @param src String source
function LoggerContext:SetConfigurationSource(src)
    self:SetPrivateField("source", src)
end

--- Gets where this LoggerContext is declared.
-- @return table source
function LoggerContext:GetConfigurationSource()
    return self:GetPrivateField"source"
end

--- Gets a Logger from the Context.
-- @param name The name of the Logger
function LoggerContext:GetLogger(name)
    return self:GetPrivateField"logger"[name]
end

--- Gets a table of the current loggers.
-- @return table loggers
function LoggerContext:GetLoggers()
    return self:GetPrivateField"logger"
end

function LoggerContext:AddLogger(name, logger)
    self:GetPrivateField"logger"[name] = logger
end

--- Returns the current Configuration of the LoggerContext.
-- @return object configuration
function LoggerContext:GetConfiguration()
    return self:GetPrivateField"config"
end

--- Sets the Configuration to be used.
-- @param config Configuration
function LoggerContext:SetConfiguration(config)
    if not IsConfiguration(config) then return end
    if self:GetConfiguration() == config then return end
    config:SetContext(self:GetName())
    self:SetPrivateField("config", config)
end

function LoggerContext:__tostring()
    return "LoggerContext: [name:" .. self:GetName() .. "]"
end

--- Terminate the LoggerContext.
function LoggerContext:Terminate()
    local name = self:GetName()
    self:DestroyPrivateTable()
    getContextDict()[name] = nil
end

--- Determines if the specified Logger exists.
-- @param name The name of the Logger to check
-- @return bool haslogger
function LoggerContext:HasLogger(name)
    if self:GetLogger(name) then return true end

    return false
end

--- Get all LoggerContexts.
local function GetAllContexts()
    return getContextDict()
end

--- Get the LoggerContext with the right name.
-- @param name String name
-- @return object loggercontext
local function GetContext(name)
    return getContextDict()[name]
end

--- Register a LoggerContext.
-- @lfunction Register
-- @param name The name of the LoggerContext
-- @param withconfig Whether or not come with a DefaultConfiguration, leaving it nil will make it come with one
-- @return object loggercontext
local function RegisterContext(name, withconfig)
    if type(name) ~= "string" then return end
    local ctxdict = getContextDict()
    local ctx = ctxdict[name]
    if IsLoggerContext(ctx) then return ctx end
    ctx = LoggerContext(name)

    if withconfig or withconfig == nil then
        ctx:SetConfiguration(GetDefaultConfiguration())
    end

    addToContextDict(name, ctx)

    return ctx
end

--- Get the number of Loggers across all the LoggerContexts.
-- @lfunction GetLoggerCount
-- @return number count
local function GetLoggerCount()
    local num, tableCount = 0, table.Count

    for _, v in pairs(getContextDict()) do
        num = num + tableCount(v:GetLoggers())
    end

    return num
end

--- Get LoggerContext class.
-- @lfunction GetClass
local function GetLoggerContextClass()
    return LoggerContext
end

Log4g.RegisterPackageClass("log4g-core", "LoggerContext", {
    getConfigurationClass = GetConfigurationClass,
    getLoggerContextClass = GetLoggerContextClass,
    createConfiguration = CreateConfiguration,
    getDefaultConfiguration = GetDefaultConfiguration,
    getLoggerCount = GetLoggerCount,
    register = RegisterContext,
    getContext = GetContext,
    getAllContexts = GetAllContexts
})