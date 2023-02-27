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

function Logger:Initialize(name, context, level)
    PRIVATE[self] = {}
    self.name = name
    PRIVATE[self].ctx = context.name
    PRIVATE[self].lc = CreateLoggerConfig(name, context:GetConfiguration(), level)
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

function Log4g.Core.Logger.Create(name, context, level)
    if context:HasLogger(name) then return end
    context:GetLoggers()[name] = Logger(name, context, level)
end