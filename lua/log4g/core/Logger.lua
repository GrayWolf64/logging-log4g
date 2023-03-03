--- The Logger.
-- @classmod Logger
Log4g.Core.Logger = Log4g.Core.Logger or {}
local Class = include("log4g/core/impl/MiddleClass.lua")
local Logger = Class("Logger")
local CreateLoggerConfig = Log4g.Core.Config.LoggerConfig.Create

--- A weak table which stores some private attributes of the Logger object.
-- @local
-- @table PRIVATE
local PRIVATE = PRIVATE or setmetatable({}, {
    __mode = "k"
})

function Logger:Initialize(name, context, level, newConfig)
    PRIVATE[self] = {}
    self.name = name
    PRIVATE[self].ctx = context.name

    if newConfig then
        PRIVATE[self].lc = CreateLoggerConfig(name, context:GetConfiguration(), level)
    end
end

--- Get the LoggerConfig of the Logger.
-- @return object loggerconfig
function Logger:GetLoggerConfig()
    return PRIVATE[self].lc
end

--- Terminate the Logger.
function Logger:Terminate()
    PRIVATE[self] = nil
end

function Log4g.Core.Logger.Create(name, context, level, newConfig)
    if context:HasLogger(name) then return end
    context:GetLoggers()[name] = Logger(name, context, level, newConfig)
end