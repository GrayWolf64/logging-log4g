--- The core implementation of the Logger interface.
-- @classmod Logger
-- @license Apache License 2.0
-- @copyright GrayWolf64
local Object             = Log4g.Core.Object.getClass()
local Logger             = Logger or Object:subclass("Logger")
local GetCtx             = Log4g.Core.LoggerContext.get
local HasLoggerConfig    = Log4g.Core.Config.LoggerConfig.hasLoggerConfig
local EnumerateAncestors = Log4g.Core.Object.enumerateAncestors
local GetLevel           = Log4g.Core.Level.getLevel
local checkClass         = include"util/TypeUtil.lua".checkClass
local StringUtil         = include"util/StringUtil.lua"
local checkName,          StripDotExtension = StringUtil.checkName, StringUtil.StripDotExtension
local next,               pairs             = next,                 pairs
local LogEventBuilder    = Log4g.Core.LogEvent.Builder
Logger:include(Log4g.Core.Object.namedMixins)

function Logger:Initialize(name, context)
    Object.Initialize(self)
    self.__lContextName = context:GetName()
    self:SetName(name)
    self:SetAdditive(true)
end

--- Gets the LoggerContext of the Logger.
-- @param ex True for getting the object, false or nil for getting the name
-- @return string ctxname
-- @return object ctx
function Logger:GetContext(ex)
    if not ex then
        return self.__lContextName
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
    self.__lConfigName = name
end

function Logger:GetLoggerConfigN()
    return self.__lConfigName
end

--- Get the LoggerConfig of the Logger.
-- @return object loggerconfig
function Logger:GetLoggerConfig()
    return self:GetContext(true):GetConfiguration():GetLoggerConfig(self:GetLoggerConfigN())
end

function Logger:SetAdditive(additive)
    assert(type(additive) == "boolean", "additive flag must be bool")
    self.__additive = additive
end

function Logger:IsAdditive()
    return self.__additive
end

function Logger:SetLevel(level)
    assert(checkClass(level, "Level"), "level to be set must be Log4g Level")
    self:GetLoggerConfig():SetLevel(level)
end

function Logger:GetLevel()
    return self:GetLoggerConfig():GetLevel()
end

function Logger:CallAppenders(event)
    assert(checkClass(event, "LogEvent"), "event must be Log4g LogEvent")
    local aps = self:GetLoggerConfig():GetAppenders()
    if not next(aps) then return end

    for k in pairs(aps) do
        k:Append(event)
    end
end

local function buildEvent(o, level)
    return LogEventBuilder(o:GetName(), GetLevel(level))
end

--- Construct a log event that will always be logged.
-- @return object LogEvent
function Logger:Always()
    return buildEvent(self, "ALL")
end

--- Construct a trace log event.
function Logger:AtTrace()
    return buildEvent(self, "TRACE")
end

--- Construct a debug log event.
function Logger:AtDebug()
    return buildEvent(self, "DEBUG")
end

--- Construct a info log event.
function Logger:AtInfo()
    return buildEvent(self, "INFO")
end

--- Construct a warn log event.
function Logger:AtWarn()
    return buildEvent(self, "WARN")
end

--- Construct a error log event.
function Logger:AtError()
    return buildEvent(self, "ERROR")
end

--- Construct a fatal log event.
function Logger:AtFatal()
    return buildEvent(self, "FATAL")
end

--- Logs a message if the specified level is active.
local function LogIfEnabled(self, level, msg)
    level = GetLevel(level)
    if type(msg) ~= "string" or self:GetLevel():IntLevel() < level:IntLevel() then return end
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

local function createLogger(loggerName, context, loggerconfig)
    assert(checkClass(context, "LoggerContext"), "context must be Log4g LoggerContext object")
    assert(not context:HasLogger(loggerName), "given context already has a Logger with the same given name")
    assert(checkName(loggerName), "given Logger name doesn't meet up with standard")

    local logger, root = Logger(loggerName, context), GetConVar("log4g_rootLoggerName"):GetString()

    if loggerName:find"%." then
        if checkClass(loggerconfig, "LoggerConfig") then
            local loggerconfigName = loggerconfig:GetName()

            if loggerconfigName == loggerName then
                logger:SetLoggerConfig(loggerName)
            else
                if EnumerateAncestors(loggerName)[loggerconfigName] then
                    logger:SetLoggerConfig(loggerconfigName)
                else
                    logger:SetLoggerConfig(root)
                end
            end
        else -- Provided 'LoggerConfig' isn't an actual LoggerConfig, automatically assign one.
            local autoLoggerConfigName = loggerName

            while true do
                if HasLoggerConfig(autoLoggerConfigName, context) then
                    logger:SetLoggerConfig(autoLoggerConfigName)
                    break
                end

                autoLoggerConfigName = StripDotExtension(autoLoggerConfigName)

                if not autoLoggerConfigName:find"%." and not HasLoggerConfig(autoLoggerConfigName, context) then
                    logger:SetLoggerConfig(root)
                    break
                end
            end
        end
    else
        if checkClass(loggerconfig, "LoggerConfig") and loggerconfig:GetName() == loggerName then
            logger:SetLoggerConfig(loggerName)
        else
            logger:SetLoggerConfig(root)
        end
    end

    context:AddLogger(loggerName, logger)

    return logger
end

Log4g.Core.Logger = {
    getClass = function() return Logger end,
    create = createLogger
}