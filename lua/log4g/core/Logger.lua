--- The Logger.
-- @classmod Logger
Log4g.Core.Logger = Log4g.Core.Logger or {}
local Logger = include("log4g/core/impl/MiddleClass.lua")("Logger")
local GetCtx = Log4g.Core.LoggerContext.Get
local QualifyName = Log4g.Util.QualifyName
local istable, isstring = istable, isstring
local HasLoggerConfig = Log4g.Core.Config.LoggerConfig.HasLoggerConfig
local StripDotExtension = Log4g.Util.StripDotExtension

local PRIVATE = PRIVATE or setmetatable({}, {
    __mode = "k"
})

function Logger:Initialize(name, context, loggerconfig)
    PRIVATE[self] = {}
    PRIVATE[self].ctx = context.name
    self.name = name

    if loggerconfig and istable(loggerconfig) then
        self:SetLoggerConfigN(loggerconfig.name)

        if name == loggerconfig.name then
            context:GetConfiguration():AddLogger(name, loggerconfig)
        end
    else
        if string.find(name, "%.") then
            local lc = StripDotExtension(name)

            if not HasLoggerConfig(lc) then
                if not string.find(lc, "%.") then
                    self:SetLoggerConfigN(Log4g.ROOT)

                    return
                end

                while not HasLoggerConfig(lc) do
                    lc = StripDotExtension(lc)

                    if not string.find(lc, "%.") then
                        self:SetLoggerConfigN(Log4g.ROOT)
                    end

                    if HasLoggerConfig(lc) then
                        self:SetLoggerConfigN(lc)
                        break
                    end
                end
            end
        else
            self:SetLoggerConfigN(Log4g.ROOT)
        end
    end
end

function Logger:GetContext()
    return PRIVATE[self].ctx
end

function Logger:SetLoggerConfigN(name)
    if not isstring(name) then return end
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
    context:GetLoggers()[name] = Logger(name, context, loggerconfig)
end