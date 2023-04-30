--- The LoggerConfig.
-- Logger object that is created via configuration.
-- Subclassing `LifeCycle`.
-- @classmod LoggerConfig
-- @license Apache License 2.0
-- @copyright GrayWolf64
local LifeCycle = Log4g.GetPkgClsFuncs("log4g-core", "LifeCycle").getClass()
local LoggerContext = Log4g.GetPkgClsFuncs("log4g-core", "LoggerContext")
local EnumerateAncestors = Log4g.GetPkgClsFuncs("log4g-core", "Object").enumerateAncestors
local GetLevel = Log4g.GetPkgClsFuncs("log4g-core", "Level").getLevel
local TypeUtil = Log4g.GetPkgClsFuncs("log4g-core", "TypeUtil")
local PropertiesPlugin = Log4g.GetPkgClsFuncs("log4g-core", "PropertiesPlugin")
local LoggerConfig = LifeCycle:subclass"LoggerConfig"
local IsAppender, IsLoggerConfig = TypeUtil.IsAppender, TypeUtil.IsLoggerConfig
local IsLoggerContext = TypeUtil.IsLoggerContext
local IsConfiguration, IsLevel = TypeUtil.IsConfiguration, TypeUtil.IsLevel
TypeUtil, StringUtil = nil, nil
local tableConcat = table.concat
local GetCtx, GetAllCtx = LoggerContext.get, LoggerContext.getAll
local pairs, next = pairs, next
local type = type
PropertiesPlugin.registerProperty("log4g_rootLogger", "root", true)

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

--- Sets the Context name for the LoggerConfig.
-- @param ctx LoggerContext object
function LoggerConfig:SetContext(name)
    if type(name) ~= "string" then return end
    self:SetPrivateField("ctx", name)
end

function LoggerConfig:GetContext()
    return self:GetPrivateField"ctx"
end

function LoggerConfig:GetAppenderRef()
    return self:GetPrivateField"apref"
end

--- Adds an Appender to the LoggerConfig.
-- It adds the Appender name to the LoggerConfig's private `apref` table field,
-- then adds the Appender object to the Configuration's(the only one which owns this LoggerConfig) private `appender` table field.
-- @param appender Appender object
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

    for k in pairs(apref) do
        appenders[config:GetAppenders()[k]] = true
    end

    return appenders
end

--- Removes all Appenders configured by this LoggerConfig.
function LoggerConfig:ClearAppenders()
    local config, apref = GetCtx(self:GetContext()):GetConfiguration(), self:GetAppenderRef()
    if not next(apref) then return end

    for k in pairs(apref) do
        config:RemoveAppender(k)
        self:GetAppenderRef()[k] = nil
    end
end

local RootLoggerConfig = LoggerConfig:subclass"LoggerConfig.RootLogger"

function RootLoggerConfig:Initialize()
    LoggerConfig.Initialize(self, PropertiesPlugin.getProperty("log4g_rootLogger", true))
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

local function GetRootLoggerConfigClass()
    return RootLoggerConfig
end

--- Check if a LoggerConfig's ancestors exist and return its desired parent name.
-- @lfunction ValidateAncestors
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
local function Create(name, config, level)
    local root = PropertiesPlugin.getProperty("log4g_rootLogger", true)
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

Log4g.RegisterPackageClass("log4g-core", "LoggerConfig", {
    create = Create,
    getRootLoggerConfigClass = GetRootLoggerConfigClass,
    hasLoggerConfig = HasLoggerConfig
})