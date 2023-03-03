--- Interface that must be implemented to create a Configuration.
-- Subclassing `LifeCycle`.
-- @classmod Configuration
Log4g.Core.Config.Configuration = Log4g.Core.Config.Configuration or {}
local LifeCycle = Log4g.Core.LifeCycle.Class()
local Configuration = LifeCycle:subclass("Configuration")

--- A weak table which stores some private attributes of the Configuration object.
-- It keeps every Configuration's Appenders, LoggerConfigs, LoggerContext name and start time.
-- @local
-- @table PRIVATE
local PRIVATE = PRIVATE or setmetatable({}, {
    __mode = "k"
})

function Configuration:Initialize(name)
    LifeCycle.Initialize(self)
    self.name = name

    PRIVATE[self] = {
        appender = {},
        lc = {},
        start = SysTime()
    }
end

--- Sets the LoggerContext name for the Configuration.
-- This is meant to be used internally when creating a LoggerContext,
-- and associating the DefaultConfiguration with it, then the Configuration will have a string field of the LoggerContext's name.
-- @param name ctxname
function Configuration:SetContext(name)
    PRIVATE[self].context = name
end

function Configuration:GetContext()
    return PRIVATE[self].context
end

--- Adds a Appender to the Configuration.
-- @param appender The Appender to add
-- @bool ifsuccessfullyadded
function Configuration:AddAppender(appender)
    if not istable(appender) then return end
    if PRIVATE[self].appender[appender.name] then return false end
    PRIVATE[self].appender[appender.name] = appender

    return true
end

function Configuration:RemoveAppender(name)
    PRIVATE[self].appender[name] = nil
end

function Configuration:AddLogger(name, lc)
    PRIVATE[self].lc[name] = lc
end

--- Locates the appropriate LoggerConfig name for a Logger name.
-- @param name The Logger name
-- @return string lcname
function Configuration:GetLoggerConfig(name)
    if PRIVATE[self].lc[name] then return PRIVATE[self].lc[name] end
end

function Configuration:GetLoggerConfigs()
    return PRIVATE[self].lc
end

--- Gets all the Appenders in the Configuration.
-- Keys are the names of Appenders and values are the Appenders themselves.
-- @return table appenders
function Configuration:GetAppenders()
    return PRIVATE[self].appender
end

--- Gets how long since this Configuration initialized.
-- @return int uptime
function Configuration:GetUpTime()
    return SysTime() - PRIVATE[self].start
end

--- Register a Configuration.
-- @param name The name of the Configuration
-- @return object configuration
function Log4g.Core.Config.Configuration.Register(name)
    return Configuration(name)
end