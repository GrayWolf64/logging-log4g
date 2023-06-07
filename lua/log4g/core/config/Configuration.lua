--- Interface that must be implemented to create a Configuration.
-- Subclassing `LifeCycle`, mixin-ing `SetContext()` and `GetContext()`.
-- @classmod Configuration
-- @license Apache License 2.0
-- @copyright GrayWolf64
local LifeCycle = Log4g.LifeCycle.getClass()
local IsAppender = Log4g.GetPkgClsFuncs("log4g-core", "TypeUtil").IsAppender
local PropertiesPlugin = Log4g.GetPkgClsFuncs("log4g-core", "PropertiesPlugin")
local Configuration = LifeCycle:subclass"Configuration"
Configuration:include(Log4g.Object.contextualMixins)
local SysTime = SysTime

function Configuration:Initialize(name)
    LifeCycle.Initialize(self)
    self:SetPrivateField(0x0015, {})
    self:SetPrivateField(0x0013, {})
    self:SetPrivateField(0x00AB, SysTime())
    self:SetName(name)
end

function Configuration:__tostring()
    return "Configuration: [name:" .. self:GetName() .. "]"
end

function Configuration:IsConfiguration()
    return true
end

--- Adds a Appender to the Configuration.
-- @param appender The Appender to add
-- @bool ifsuccessfullyadded
function Configuration:AddAppender(ap)
    if not IsAppender(ap) then return end
    if self:GetPrivateField(0x0015)[ap:GetName()] then return false end
    self:GetPrivateField(0x0015)[ap:GetName()] = ap

    return true
end

function Configuration:RemoveAppender(name)
    self:GetPrivateField(0x0015)[name] = nil
end

--- Gets all the Appenders in the Configuration.
-- Keys are the names of Appenders and values are the Appenders themselves.
-- @return table appenders
function Configuration:GetAppenders()
    return self:GetPrivateField(0x0015)
end

function Configuration:AddLogger(name, lc)
    self:GetPrivateField(0x0013)[name] = lc
end

--- Locates the appropriate LoggerConfig name for a Logger name.
-- @param name The Logger name
-- @return object loggerconfig
function Configuration:GetLoggerConfig(name)
    return self:GetPrivateField(0x0013)[name]
end

function Configuration:GetLoggerConfigs()
    return self:GetPrivateField(0x0013)
end

function Configuration:GetRootLogger()
    return self:GetPrivateField(0x0013)[PropertiesPlugin.getProperty("rootLoggerName", true)]
end

--- Gets how long since this Configuration initialized.
-- @return int uptime
function Configuration:GetUpTime()
    return SysTime() - self:GetPrivateField(0x00AB)
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

Log4g.RegisterPackageClass("log4g-core", "Configuration", {
    getClass = GetClass,
    create = Create
})