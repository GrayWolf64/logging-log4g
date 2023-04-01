--- The core implementation of the Logger interface.
-- @classmod Logger
-- @license Apache License 2.0
-- @copyright GrayWolf64
Log4g.Core.Logger = Log4g.Core.Logger or {}
local Object = Log4g.Core.Object.GetClass()
local Logger = Object:subclass("Logger")
local GetCtx = Log4g.Core.LoggerContext.Get
local StringUtil = include("log4g/core/util/StringUtil.lua")
local QualifyName, StripDotExtension = StringUtil.QualifyName, StringUtil.StripDotExtension
local TypeUtil = include("log4g/core/util/TypeUtil.lua")
local IsLoggerConfig, IsLoggerContext = TypeUtil.IsLoggerConfig, TypeUtil.IsLoggerContext
local IsLevel = TypeUtil.IsLevel
TypeUtil, StringUtil = nil, nil
local sfind = string.find
local thasvalue = table.HasValue
local HasLoggerConfig = Log4g.Core.Config.LoggerConfig.HasLoggerConfig
local GenerateAncestorsN = Log4g.Core.Config.LoggerConfig.GenerateAncestorsN
local Root = GetConVar("log4g.root"):GetString()

function Logger:Initialize(name, context)
    Object.Initialize(self)
    self:SetPrivateField("ctx", context:GetName())
    self:SetName(name)
end

function Logger:GetContext()
    return self:GetPrivateField("ctx")
end

--- Sets the LoggerConfig name for the Logger.
-- @param name String name
function Logger:SetLoggerConfig(name)
    self:SetPrivateField("lc", name)
end

function Logger:GetLoggerConfigN()
    return self:GetPrivateField("lc")
end

--- Get the LoggerConfig of the Logger.
-- @return object loggerconfig
function Logger:GetLoggerConfig()
    return GetCtx(self:GetContext()):GetConfiguration():GetLoggerConfig(self:GetLoggerConfigN())
end

function Logger:SetLevel(level)
    if not IsLevel(level) then return end
    self:GetLoggerConfig():SetLevel(level)
end

function Logger:GetLevel()
    return self:GetLoggerConfig():GetLevel()
end

--- Construct a log event that will always be logged.
function Logger:Always()
end

function Logger:AtTrace()
end

function Logger:AtDebug()
end

function Logger:AtInfo()
end

function Logger:AtWarn()
end

function Logger:AtError()
end

function Logger:AtFatal()
end

function Logger:Trace()
end

function Logger:Debug()
end

function Logger:Info()
end

function Logger:Warn()
end

function Logger:Error()
end

function Logger:Fatal()
end

function Log4g.Core.Logger.Create(name, context, loggerconfig)
    if not IsLoggerContext(context) then return end
    if context:HasLogger(name) or not QualifyName(name) then return end
    local logger = Logger(name, context)

    if sfind(name, "%.") then
        if loggerconfig and IsLoggerConfig(loggerconfig) then
            if loggerconfig:GetName() == name then
                logger:SetLoggerConfig(name)
            else
                if thasvalue(GenerateAncestorsN(name), loggerconfig:GetName()) then
                    logger:SetLoggerConfig(loggerconfig:GetName())
                else
                    logger:SetLoggerConfig(Root)
                end
            end
        else
            local lc = name

            while true do
                if HasLoggerConfig(lc) then
                    logger:SetLoggerConfig(lc)
                    break
                end

                lc = StripDotExtension(lc)

                if not sfind(lc, "%.") and not HasLoggerConfig(lc) then
                    logger:SetLoggerConfig(Root)
                    break
                end
            end
        end
    else
        if loggerconfig and IsLoggerConfig(loggerconfig) and loggerconfig:GetName() == name then
            logger:SetLoggerConfig(name)
        else
            logger:SetLoggerConfig(Root)
        end
    end

    context:GetLoggers()[name] = logger
end

function Log4g.Core.Logger.GetClass()
    return Logger
end