--- The core implementation of the Logger interface.
-- @classmod Logger
-- @license Apache License 2.0
-- @copyright GrayWolf64
local Object = Log4g.GetPkgClsFuncs("log4g-core", "Object").getClass()
local Logger = Object:subclass("Logger")
local GetCtx = Log4g.GetPkgClsFuncs("log4g-core", "LoggerContext").get
local HasLoggerConfig = Log4g.GetPkgClsFuncs("log4g-core", "LoggerConfig").hasLoggerConfig
local EnumerateAncestors = Log4g.GetPkgClsFuncs("log4g-core", "Object").enumerateAncestors
local GetLevel = Log4g.GetPkgClsFuncs("log4g-core", "Level").getLevel
local TypeUtil, StringUtil = include("log4g/core/util/TypeUtil.lua"), include("log4g/core/util/StringUtil.lua")
local QualifyName, StripDotExtension = StringUtil.QualifyName, StringUtil.StripDotExtension
local IsLoggerConfig, IsLoggerContext = TypeUtil.IsLoggerConfig, TypeUtil.IsLoggerContext
local IsLevel, IsLogEvent = TypeUtil.IsLevel, TypeUtil.IsLogEvent
TypeUtil, StringUtil = nil, nil
local next, pairs = next, pairs
local isstring, isbool = isstring, isbool
local LogEventBuilder = Log4g.Core.LogEvent.Builder

function Logger:Initialize(name, context)
    Object.Initialize(self)
    self:SetPrivateField("ctx", context:GetName())
    self:SetName(name)
    self:SetAdditive(true)
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

function Logger:SetAdditive(bool)
    if not isbool(bool) then return end
    self:SetPrivateField("additive", bool)
end

function Logger:IsAdditive()
    return self:GetPrivateField("additive")
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
    return LogEventBuilder(self:GetName(), GetLevel("ALL"))
end

--- Construct a trace log event.
function Logger:AtTrace()
    return LogEventBuilder(self:GetName(), GetLevel("TRACE"))
end

--- Construct a debug log event.
function Logger:AtDebug()
    return LogEventBuilder(self:GetName(), GetLevel("DEBUG"))
end

--- Construct a info log event.
function Logger:AtInfo()
    return LogEventBuilder(self:GetName(), GetLevel("INFO"))
end

--- Construct a warn log event.
function Logger:AtWarn()
    return LogEventBuilder(self:GetName(), GetLevel("WARN"))
end

--- Construct a error log event.
function Logger:AtError()
    return LogEventBuilder(self:GetName(), GetLevel("ERROR"))
end

--- Construct a fatal log event.
function Logger:AtFatal()
    return LogEventBuilder(self:GetName(), GetLevel("FATAL"))
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

local function Create(name, context, loggerconfig)
    if not IsLoggerContext(context) then return end
    if context:HasLogger(name) or not QualifyName(name) then return end
    local logger, root = Logger(name, context), GetConVar("log4g_rootLogger"):GetString()

    if name:find("%.") then
        if loggerconfig and IsLoggerConfig(loggerconfig) then
            local lcn = loggerconfig:GetName()

            if lcn == name then
                logger:SetLoggerConfig(name)
            else
                if EnumerateAncestors(name)[lcn] then
                    logger:SetLoggerConfig(lcn)
                else
                    logger:SetLoggerConfig(root)
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
                    logger:SetLoggerConfig(root)
                    break
                end
            end
        end
    else
        if loggerconfig and IsLoggerConfig(loggerconfig) and loggerconfig:GetName() == name then
            logger:SetLoggerConfig(name)
        else
            logger:SetLoggerConfig(root)
        end
    end

    context:GetLoggers()[name] = logger

    return logger
end

local function GetClass()
    return Logger
end

Log4g.RegisterPackageClass("log4g-core", "Logger", {
    getClass = GetClass,
    create = Create
})