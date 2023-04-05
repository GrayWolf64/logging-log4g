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
local IsLevel, IsLogEvent = TypeUtil.IsLevel, TypeUtil.IsLogEvent
TypeUtil, StringUtil = nil, nil
local GetLevel = Log4g.Level.GetLevel
local isstring, next = isstring, next
local HasLoggerConfig = Log4g.Core.Config.LoggerConfig.HasLoggerConfig
local GenerateAncestorsN = Log4g.Core.Config.LoggerConfig.GenerateAncestorsN
local LogEventBuilder = Log4g.Core.LogEvent.Builder
local Root = GetConVar("log4g.root"):GetString()

function Logger:Initialize(name, context)
    Object.Initialize(self)
    self:SetPrivateField("ctx", context:GetName())
    self:SetName(name)
end

--- Gets the LoggerContext of the Logger.
-- @param ex True for getting the object, false or nil for getting the name
-- @return string ctxname
-- @return object ctx
function Logger:GetContext(ex)
    if not ex or ex == false then
        return self:GetPrivateField("ctx")
    else
        return GetCtx(self:GetContext())
    end
end

function Logger:__tostring()
    return "Logger: [name:" .. self:GetName() .. "][ctx:" .. self:GetContext() .. "]"
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
    return self:GetContext(true):GetConfiguration():GetLoggerConfig(self:GetLoggerConfigN())
end

function Logger:SetLevel(level)
    if not IsLevel(level) then return end
    self:GetLoggerConfig():SetLevel(level)
end

function Logger:GetLevel()
    return self:GetLoggerConfig():GetLevel()
end

function Logger:CallAppenders(event)
    if not IsLogEvent(event) then return end
    local aps = self:GetLoggerConfig():GetAppenders()
    if not next(aps) then return end

    for k in pairs(aps) do
        k:Append(event)
    end
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

--- Logs a message if the specified level is active.
local function LogIfEnabled(self, level, msg)
    level = GetLevel(level)
    if not isstring(msg) or self:GetLevel():IntLevel() < level:IntLevel() then return end
    self:CallAppenders(LogEventBuilder(self:GetName(), level, msg))
end

function Logger:Trace(msg)
    LogIfEnabled(self, "TRACE", msg)
end

function Logger:Debug(msg)
    LogIfEnabled(self, "DEBUG", msg)
end

function Logger:Info(msg)
    LogIfEnabled(self, "INFO", msg)
end

function Logger:Warn(msg)
    LogIfEnabled(self, "WARN", msg)
end

function Logger:Error(msg)
    LogIfEnabled(self, "ERROR", msg)
end

function Logger:Fatal(msg)
    LogIfEnabled(self, "FATAL", msg)
end

function Log4g.Core.Logger.Create(name, context, loggerconfig)
    if not IsLoggerContext(context) or IsLoggerContext(context, true) then return end
    if context:HasLogger(name) or not QualifyName(name) then return end
    local logger = Logger(name, context)

    if name:find("%.") then
        if loggerconfig and IsLoggerConfig(loggerconfig) then
            local lcn = loggerconfig:GetName()

            if lcn == name then
                logger:SetLoggerConfig(name)
            else
                if GenerateAncestorsN(name)[lcn] then
                    logger:SetLoggerConfig(lcn)
                else
                    logger:SetLoggerConfig(Root)
                end
            end
        else
            local lc = name

            while true do
                if HasLoggerConfig(lc, context) then
                    logger:SetLoggerConfig(lc)
                    break
                end

                lc = StripDotExtension(lc)

                if not lc:find("%.") and not HasLoggerConfig(lc, context) then
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

    return logger
end

function Log4g.Core.Logger.GetClass()
    return Logger
end