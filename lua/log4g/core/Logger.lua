--- The core implementation of the Logger interface.
-- @classmod Logger
-- @license Apache License 2.0
-- @copyright GrayWolf64
local Object = Log4g.GetPkgClsFuncs("log4g-core", "Object")
local LoggerContext = Log4g.GetPkgClsFuncs("log4g-core", "LoggerContext")
local GetLevel = Log4g.GetPkgClsFuncs("log4g-core", "Level").getLevel
local TypeUtil = Log4g.GetPkgClsFuncs("log4g-core", "TypeUtil")
local StringUtil = include("log4g/core/util/StringUtil.lua")
local PropertiesPlugin = Log4g.GetPkgClsFuncs("log4g-core", "PropertiesPlugin")
local LifeCycle = Log4g.GetPkgClsFuncs("log4g-core", "LifeCycle").getClass()
local GetCtx, GetAllCtx = LoggerContext.get, LoggerContext.getAll
local EnumerateAncestors = Object.enumerateAncestors
local QualifyName, StripDotExtension = StringUtil.QualifyName, StringUtil.StripDotExtension
local IsLoggerConfig, IsLoggerContext = TypeUtil.IsLoggerConfig, TypeUtil.IsLoggerContext
local IsAppender, IsConfiguration = TypeUtil.IsAppender, TypeUtil.IsConfiguration
local IsLevel, IsLogEvent = TypeUtil.IsLevel, TypeUtil.IsLogEvent
TypeUtil, StringUtil = nil, nil
local tableConcat = table.concat
local next, pairs, type = next, pairs, type
PropertiesPlugin.registerProperty("rootLoggerName", "root", true)
--- Logger object that is created via configuration.
-- @type LoggerConfig
local LoggerConfig = LifeCycle:subclass"LoggerConfig"
LoggerConfig:include(Object.contextualMixins)

function LoggerConfig:Initialize(name)
    LifeCycle.Initialize(self)
    self:SetPrivateField("apref", {})
    self:SetName(name)
end

function LoggerConfig:__tostring()
    return "LoggerConfig: [name:" .. self:GetName() .. "]"
end

--- Sets the log Level.
-- @param level The Logging Level
function LoggerConfig:SetLevel(level)
    if not IsLevel(level) then return end
    if self:GetPrivateField"level" == level then return end
    self:SetPrivateField("level", level)
end

function LoggerConfig:GetLevel()
    return self:GetPrivateField"level"
end

local function HasLoggerConfig(name, context)
    local getlc = function(ctx, lcn) return ctx:GetConfiguration():GetLoggerConfig(lcn) end

    if not IsLoggerContext(context) then
        for _, v in pairs(GetAllCtx()) do
            if getlc(v, name) then return true end
        end
    else
        if getlc(context, name) then return true end
    end

    return false
end

local function GetLoggerConfig(name)
    for _, v in pairs(GetAllCtx()) do
        local loggerConfig = v:GetConfiguration():GetLoggerConfig(name)
        if loggerConfig then return loggerConfig end
    end
end

--- Sets the parent of this LoggerConfig.
-- @param T LoggerConfig object or LoggerConfig name
function LoggerConfig:SetParent(T)
    if type(T) == "string" then
        if not HasLoggerConfig(T, GetCtx(self:GetContext())) then return end
        self:SetPrivateField("parent", T)
    elseif IsLoggerConfig(T) and T:GetContext() == self:GetContext() then
        self:SetPrivateField("parent", T:GetName())
    end
end

--- Gets the parent of this LoggerConfig.
-- @return string lcname
function LoggerConfig:GetParent()
    return self:GetPrivateField"parent"
end

function LoggerConfig:GetAppenderRef()
    return self:GetPrivateField"apref"
end

--- Adds an Appender to the LoggerConfig.
-- It adds the Appender name to the LoggerConfig's private `apref` table field,
-- then adds the Appender object to the Configuration's(the only one which owns this LoggerConfig) private `appender` table field.
-- @param ap Appender object
-- @return bool ifadded
function LoggerConfig:AddAppender(ap)
    if not IsAppender(ap) then return end
    self:GetAppenderRef()[ap:GetName()] = true

    return GetCtx(self:GetContext()):GetConfiguration():AddAppender(ap, self:GetName())
end

--- Returns all Appenders configured by this LoggerConfig in a form of table (keys are Appenders, values are booleans).
-- @return table appenders
function LoggerConfig:GetAppenders()
    local appenders, config, apref = {}, GetCtx(self:GetContext()):GetConfiguration(), self:GetAppenderRef()
    if not next(apref) then return end

    for appenderName in pairs(apref) do
        appenders[config:GetAppenders()[appenderName]] = true
    end

    return appenders
end

--- Removes all Appenders configured by this LoggerConfig.
function LoggerConfig:ClearAppenders()
    local config, apref = GetCtx(self:GetContext()):GetConfiguration(), self:GetAppenderRef()
    if not next(apref) then return end

    for appenderName in pairs(apref) do
        config:RemoveAppender(appenderName)
        self:GetAppenderRef()[appenderName] = nil
    end
end

--- The root LoggerConfig.
-- @type LoggerConfig.RootLogger
local RootLoggerConfig = LoggerConfig:subclass"LoggerConfig.RootLogger"

function RootLoggerConfig:Initialize()
    LoggerConfig.Initialize(self, PropertiesPlugin.getProperty("rootLoggerName", true))
    self:SetLevel(GetLevel"INFO")
end

function RootLoggerConfig:__tostring()
    return "RootLoggerConfig: [name:" .. self:GetName() .. "]"
end

--- Overrides `LoggerConfig:SetParent()`.
-- @return bool false
function RootLoggerConfig:SetParent()
    return false
end

--- Overrides `LoggerConfig:GetParent()`.
-- @return bool false
function RootLoggerConfig:GetParent()
    return false
end

-- @section end
local function GetRootLoggerConfigClass()
    return RootLoggerConfig
end

--- Check if a LoggerConfig's ancestors exist and return its desired parent name.
-- @param loggerConfig LoggerConfig object
-- @return bool valid
-- @return string parent name
local function ValidateAncestors(loggerConfig)
    local ancestors, nodes = EnumerateAncestors(loggerConfig:GetName())

    local function HasEveryLoggerConfig(tbl)
        local ctx = GetCtx(loggerConfig:GetContext())

        for k in pairs(tbl) do
            if not HasLoggerConfig(k, ctx) then return false end
        end

        return true
    end

    if HasEveryLoggerConfig(ancestors) then return true, tableConcat(nodes, ".") end

    return false
end

--- Factory method to create a LoggerConfig.
-- @param name The name for the Logger
-- @param config The Configuration
-- @param level The Logging Level
-- @return object loggerconfig
local function CreateLoggerConfig(name, config, level)
    local root = PropertiesPlugin.getProperty("rootLoggerName", true)
    if not IsConfiguration(config) or name == root then return end
    local loggerConfig = LoggerConfig(name)
    loggerConfig:SetContext(config:GetContext())

    local setLevelAndParent = function(o, level1, level2, parent)
        if IsLevel(level1) then
            o:SetLevel(level1)
        else
            o:SetLevel(level2)
        end

        o:SetParent(parent)
    end

    if name:find"%." then
        local valid, parent = ValidateAncestors(loggerConfig)
        if not valid then return end
        setLevelAndParent(loggerConfig, level, GetLoggerConfig(parent):GetLevel(), parent)
    else
        setLevelAndParent(loggerConfig, level, config:GetRootLogger():GetLevel(), root)
    end

    config:AddLogger(name, loggerConfig)

    return loggerConfig
end

Object = Object.getClass()
local Logger = Object:subclass("Logger")

function Logger:Initialize(name, context)
    Object.Initialize(self)
    self:SetPrivateField("ctx", context:GetName())
    self:SetName(name)
    self:SetAdditive(true)
end

--- Provides contextual information about a logged message.
-- A LogEvent must be Serializable so that it may be transmitted over a network connection.
-- @type LogEvent
local LogEvent = Object:subclass"LogEvent"
local SysTime, debugGetInfo = SysTime, debug.getinfo

--- Initialize the LogEvent.
-- @param ln Logger name
-- @param level Level object
-- @param time Precise time
-- @param msg Log message
-- @param src File source path
function LogEvent:Initialize(ln, level, time, msg, src)
    Object.Initialize(self)
    self:SetPrivateField("ln", ln)
    self:SetPrivateField("lv", level)
    self:SetPrivateField("time", time)
    self:SetPrivateField("msg", msg)
    self:SetPrivateField("src", src)
end

--- Gets the Logger name.
function LogEvent:GetLoggerName()
    return self:GetPrivateField"ln"
end

--- Gets the Level object.
function LogEvent:GetLevel()
    return self:GetPrivateField"lv"
end

--- Gets the File source path.
function LogEvent:GetSource()
    return self:GetPrivateField"src"
end

--- Gets the log message.
function LogEvent:GetMsg()
    return self:GetPrivateField"msg"
end

--- Sets the log message.
function LogEvent:SetMsg(msg)
    if type(msg) ~= "string" then return end
    self:SetPrivateField("msg", msg)
end

--- Gets the precise time.
function LogEvent:GetTime()
    return self:GetPrivateField"time"
end

--- Build a LogEvent.
-- @param ln Logger name
-- @param level Level object
-- @param msg String message
local function LogEventBuilder(ln, level, msg)
    if type(ln) ~= "string" or not IsLevel(level) then return end

    return LogEvent(ln, level, SysTime(), msg, debugGetInfo(4, "S").source)
end

--- Gets the LoggerContext of the Logger.
-- @section end
-- @param ex True for getting the object, false or nil for getting the name
-- @return string ctxname
-- @return object ctx
function Logger:GetContext(ex)
    if not ex or ex == false then
        return self:GetPrivateField"ctx"
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
    return self:GetPrivateField"lc"
end

--- Get the LoggerConfig of the Logger.
-- @return object loggerconfig
function Logger:GetLoggerConfig()
    return self:GetContext(true):GetConfiguration():GetLoggerConfig(self:GetLoggerConfigN())
end

function Logger:SetAdditive(bool)
    if type(bool) ~= "boolean" then return end
    self:SetPrivateField("additive", bool)
end

function Logger:IsAdditive()
    return self:GetPrivateField"additive"
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

local function CreateLogger(loggerName, context, loggerconfig)
    if not IsLoggerContext(context) then return end
    if context:HasLogger(loggerName) or not QualifyName(loggerName) then return end
    local logger, root = Logger(loggerName, context), PropertiesPlugin.getProperty("rootLoggerName", true)

    if loggerName:find"%." then
        if IsLoggerConfig(loggerconfig) then
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
        else --- Provided 'LoggerConfig' isn't an actual LoggerConfig, automatically assign one.
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
        if IsLoggerConfig(loggerconfig) and loggerconfig:GetName() == loggerName then
            logger:SetLoggerConfig(loggerName)
        else
            logger:SetLoggerConfig(root)
        end
    end

    context:AddLogger(loggerName, logger)

    return logger
end

local function GetLoggerClass()
    return Logger
end

Log4g.RegisterPackageClass("log4g-core", "Logger", {
    createLoggerConfig = CreateLoggerConfig,
    getRootLoggerConfigClass = GetRootLoggerConfigClass,
    hasLoggerConfig = HasLoggerConfig,
    getLoggerClass = GetLoggerClass,
    createLogger = CreateLogger
})