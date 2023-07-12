--- Interface that must be implemented to create a Configuration.
-- Subclassing `LifeCycle`, mixin-ing `SetContext()` and `GetContext()`.
-- @classmod Configuration
-- @license Apache License 2.0
-- @copyright GrayWolf64
local LifeCycle = Log4g.Core.LifeCycle.getClass()
local checkClass = include"../util/TypeUtil.lua".checkClass
local Configuration = Configuration or LifeCycle:subclass"Configuration"
Configuration:include(Log4g.Core.Object.contextualMixins)

function Configuration:Initialize()
    LifeCycle.Initialize(self)
    self:SetPrivateField(0x0015, {})
    self:SetPrivateField(0x0013, {})
    self:SetPrivateField(0x00AB, SysTime())
end

--- Gets all the Appenders in the Configuration.
-- Keys are the names of Appenders and values are the Appenders themselves.
-- @return table appenders
function Configuration:GetAppenders()
    return self:GetPrivateField(0x0015)
end

--- Adds a Appender to the Configuration.
-- @param appender The Appender to add
-- @return bool ifsuccessful
function Configuration:AddAppender(ap)
    assert(checkClass(ap, "Appender"), "appender must be Log4g Appender object")
    local name = ap:GetName()
    assert(not self:GetAppenders()[name], "appender with the same name already added")
    self:GetAppenders()[name] = ap

    return true
end

function Configuration:RemoveAppender(name)
    self:GetAppenders()[name] = nil
end

function Configuration:GetLoggerConfigs()
    return self:GetPrivateField(0x0013)
end

function Configuration:AddLogger(name, lc)
    self:GetLoggerConfigs()[name] = lc
end

--- Locates the appropriate LoggerConfig name for a Logger name.
-- @param name The Logger name
-- @return object loggerconfig
function Configuration:GetLoggerConfig(name)
    return self:GetLoggerConfigs()[name]
end

function Configuration:GetRootLogger()
    return self:GetLoggerConfigs()[GetConVar("log4g_rootLoggerName"):GetString()]
end

--- Gets how long since this Configuration initialized.
-- @return int uptime
function Configuration:GetUpTime()
    return SysTime() - self:GetPrivateField(0x00AB)
end

Log4g.Core.Config.Configuration = {
    getClass = function() return Configuration end,
    create = function(name)
        assert(type(name) == "string", "configuration name must be string")
        return Configuration(name)
    end
}