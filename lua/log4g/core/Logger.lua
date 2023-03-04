--- The Logger.
-- @classmod Logger
Log4g.Core.Logger = Log4g.Core.Logger or {}
local Logger = include("log4g/core/impl/MiddleClass.lua")("Logger")
local CreateLoggerConfig = Log4g.Core.Config.LoggerConfig.Create
local GetCtx = Log4g.Core.LoggerContext.Get

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
        PRIVATE[self].lc = name
        context:GetConfiguration():AddLogger(name, CreateLoggerConfig(name, context:GetConfiguration(), level))
    end
end

--- Get the LoggerConfig of the Logger.
-- @return object loggerconfig
function Logger:GetLoggerConfig()
    local lc = GetCtx(PRIVATE[self].ctx):GetConfiguration():GetLoggerConfig(PRIVATE[self].lc)
    if lc then return lc end
end

function Log4g.Core.Logger.Create(name, context, level, newConfig)
    if context:HasLogger(name) then return end
    context:GetLoggers()[name] = Logger(name, context, level, newConfig)
end