--- The core implementation of the Logger interface.
-- @classmod Logger
-- @license Apache License 2.0
-- @copyright GrayWolf64
Log4g.Core.Logger = Log4g.Core.Logger or {}
local Logger = include("log4g/core/impl/MiddleClass.lua")("Logger")
local GetCtx = Log4g.Core.LoggerContext.Get
local StringUtils = include("log4g/core/util/StringUtils.lua")
local QualifyName, StripDotExtension = StringUtils.QualifyName, StringUtils.StripDotExtension
local istable = istable
local sfind = string.find
local thasvalue = table.HasValue
local ROOT = Log4g.ROOT
local HasLoggerConfig = Log4g.Core.Config.LoggerConfig.HasLoggerConfig
local GenerateParentNames = Log4g.Core.Config.LoggerConfig.GenerateParentNames
local mathhuge = math.huge

function Logger:Initialize(name, context)
    self.ctx = context.name
    self.name = name
end

function Logger:GetContext()
    return self.ctx
end

--- Sets the LoggerConfig name for the Logger.
-- @param name String name
function Logger:SetLoggerConfig(name)
    self.lc = name
end

function Logger:GetLoggerConfigN()
    return self.lc
end

--- Get the LoggerConfig of the Logger.
-- @return object loggerconfig
function Logger:GetLoggerConfig()
    local lc = GetCtx(self:GetContext()):GetConfiguration():GetLoggerConfig(self:GetLoggerConfigN())
    if lc then return lc end
end

function Log4g.Core.Logger.Create(name, context, loggerconfig)
    if not istable(context) then return end
    if context:HasLogger(name) or not QualifyName(name) then return end
    local logger = Logger(name, context)

    if sfind(name, "%.") then
        if loggerconfig and istable(loggerconfig) then
            if loggerconfig.name == name then
                logger:SetLoggerConfig(name)
            else
                if thasvalue(GenerateParentNames(name), loggerconfig.name) then
                    logger:SetLoggerConfig(loggerconfig.name)
                else
                    logger:SetLoggerConfig(ROOT)
                end
            end
        else
            local lc = name

            for i = 1, mathhuge do
                if HasLoggerConfig(lc) then
                    logger:SetLoggerConfig(lc)
                    break
                end

                lc = StripDotExtension(lc)

                if not sfind(lc, "%.") and not HasLoggerConfig(lc) then
                    logger:SetLoggerConfig(ROOT)
                    break
                end
            end
        end
    else
        if loggerconfig and istable(loggerconfig) and loggerconfig.name == name then
            logger:SetLoggerConfig(name)
        else
            logger:SetLoggerConfig(ROOT)
        end
    end

    context:GetLoggers()[name] = logger
end