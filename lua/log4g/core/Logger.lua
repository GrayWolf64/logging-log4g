--- The Logger.
-- @classmod Logger
Log4g.Core.Logger = Log4g.Core.Logger or {}
local Logger = include("log4g/core/impl/MiddleClass.lua")("Logger")
local GetCtx = Log4g.Core.LoggerContext.Get
local QualifyName = Log4g.Util.QualifyName
local istable = istable
local sfind = string.find
local thasvalue = table.HasValue
local StripDotExtension = Log4g.Util.StripDotExtension
local ROOT = Log4g.ROOT
local HasLoggerConfig = Log4g.Core.Config.LoggerConfig.HasLoggerConfig
local GenerateParentNames = Log4g.Core.Config.LoggerConfig.GenerateParentNames

local PRIVATE = PRIVATE or setmetatable({}, {
    __mode = "k"
})

function Logger:Initialize(name, context)
    PRIVATE[self] = {}
    PRIVATE[self].ctx = context.name
    self.name = name
end

function Logger:GetContext()
    return PRIVATE[self].ctx
end

function Logger:SetLoggerConfigN(name)
    PRIVATE[self].lc = name
end

function Logger:GetLoggerConfigN()
    return PRIVATE[self].lc
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
                logger:SetLoggerConfigN(name)
            else
                local ancestors = GenerateParentNames(name)

                if thasvalue(ancestors, loggerconfig.name) then
                    logger:SetLoggerConfigN(loggerconfig.name)
                end
            end
        else
            local lc = name

            for i = 1, math.huge do
                if HasLoggerConfig(lc) then
                    logger:SetLoggerConfigN(lc)
                    break
                end

                lc = StripDotExtension(lc)

                if not sfind(lc, "%.") and not HasLoggerConfig(lc) then
                    logger:SetLoggerConfigN(ROOT)
                    break
                end
            end
        end
    else
        if loggerconfig and istable(loggerconfig) and loggerconfig.name == name then
            logger:SetLoggerConfigN(name)
        else
            logger:SetLoggerConfigN(ROOT)
        end
    end

    context:GetLoggers()[name] = logger
end