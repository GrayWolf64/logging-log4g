--- Interface that must be implemented to create a Configuration.
-- Subclassing `LifeCycle`.
-- @classmod Configuration
-- @license Apache License 2.0
-- @copyright GrayWolf64
Log4g.Core.Config.Configuration = Log4g.Core.Config.Configuration or {}
local LifeCycle = Log4g.Core.LifeCycle.GetClass()
local Configuration = LifeCycle:subclass("Configuration")
local isstring = isstring
local SysTime = SysTime

function Configuration:Initialize(name)
    LifeCycle.Initialize(self)
    self:SetPrivateField("ap", {})
    self:SetPrivateField("lc", {})
    self:SetPrivateField("start", SysTime())
    self.name = name
end

--- Sets the LoggerContext name for the Configuration.
-- This is meant to be used internally when creating a LoggerContext,
-- and associating the DefaultConfiguration with it, then the Configuration will have a string field of the LoggerContext's name.
-- @param name ctxname
function Configuration:SetContext(name)
    self:SetPrivateField("ctx", name)
end

function Configuration:GetContext()
    return self:GetPrivateField("ctx")
end

--- Adds a Appender to the Configuration.
-- @param appender The Appender to add
-- @bool ifsuccessfullyadded
function Configuration:AddAppender(appender)
    if not istable(appender) then return end
    if self:GetPrivateField("ap")[appender.name] then return false end
    self:GetPrivateField("ap")[appender.name] = appender

    return true
end

function Configuration:RemoveAppender(name)
    self:GetPrivateField("ap")[name] = nil
end

--- Gets all the Appenders in the Configuration.
-- Keys are the names of Appenders and values are the Appenders themselves.
-- @return table appenders
function Configuration:GetAppenders()
    return self:GetPrivateField("ap")
end

function Configuration:AddLogger(name, lc)
    self:GetPrivateField("lc")[name] = lc
end

--- Locates the appropriate LoggerConfig name for a Logger name.
-- @param name The Logger name
-- @return string lcname
function Configuration:GetLoggerConfig(name)
    if not isstring(name) then return end

    return self:GetPrivateField("lc")[name]
end

function Configuration:GetLoggerConfigs()
    return self:GetPrivateField("lc")
end

function Configuration:GetRootLogger()
    return self:GetPrivateField("lc")[LOG4G_ROOT]
end

--- Gets how long since this Configuration initialized.
-- @return int uptime
function Configuration:GetUpTime()
    return SysTime() - self:GetPrivateField("start")
end

function Log4g.Core.Config.Configuration.GetClass()
    return Configuration
end

--- Create a Configuration.
-- @param name The name of the Configuration
-- @return object configuration
function Log4g.Core.Config.Configuration.Create(name)
    return Configuration(name)
end