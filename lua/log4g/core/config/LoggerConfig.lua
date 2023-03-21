--- The LoggerConfig.
-- Logger object that is created via configuration.
-- Subclassing `LifeCycle`.
-- @classmod LoggerConfig
-- @license Apache License 2.0
-- @copyright GrayWolf64
Log4g.Core.Config.LoggerConfig = Log4g.Core.Config.LoggerConfig or {}
Log4g.Core.Config.LoggerConfig.ROOT = Log4g.ROOT
local ROOT = Log4g.Core.Config.LoggerConfig.ROOT
local LifeCycle = Log4g.Core.LifeCycle.GetClass()
local LoggerConfig = LifeCycle:subclass("LoggerConfig")
local GetCtx, GetAllCtx = Log4g.Core.LoggerContext.Get, Log4g.Core.LoggerContext.GetAll
local GetLevel = Log4g.Level.GetLevel
local istable = istable
local pairs, ipairs = pairs, ipairs
local sfind = string.find
local tinsert, tconcat, TEmpty = table.insert, table.concat, table.Empty
local StripDotExtension = Log4g.Util.StripDotExtension

--- Stores some private attributes of the LoggerConfig object.
-- @local
-- @table PRIVATE
local PRIVATE = PRIVATE or setmetatable({}, {
    __mode = "k"
})

--- Initialize the LoggerConfig object.
-- This is meant to be used internally.
-- @param name The name of the LoggerConfig
-- @param level The Level object
function LoggerConfig:Initialize(name)
    LifeCycle.Initialize(self)
    PRIVATE[self] = {}
    PRIVATE[self].appenderref = {}
    self.name = name
end

function LoggerConfig:__tostring()
    return "LoggerConfig: [name:" .. self.name .. "]"
end

--- Sets the logging Level.
-- @param level The Logging Level
function LoggerConfig:SetLevel(level)
    PRIVATE[self].level = level
end

function LoggerConfig:GetLevel()
    return PRIVATE[self].level
end

local function HasLoggerConfig(name)
    for _, v in pairs(GetAllCtx()) do
        if v:GetConfiguration():GetLoggerConfig(name) then return true end
    end

    return false
end

local function GetLoggerConfig(name)
    for _, v in pairs(GetAllCtx()) do
        local lc = v:GetConfiguration():GetLoggerConfig(name)
        if lc then return lc end
    end
end

--- Sets the parent of this LoggerConfig.
-- @param T LoggerConfig object or LoggerConfig name
function LoggerConfig:SetParent(T)
    if isstring(T) then
        if T == ROOT then
            PRIVATE[self].parent = T
        else
            if not HasLoggerConfig(T) then return end
            PRIVATE[self].parent = T
        end
    elseif istable(T) then
        PRIVATE[self].parent = T.name
    end
end

--- Gets the parent of this LoggerConfig.
-- @return string lcname
function LoggerConfig:GetParent()
    return PRIVATE[self].parent
end

--- Sets the Context name for the LoggerConfig.
-- @param ctx LoggerContext object
function LoggerConfig:SetContext(name)
    if not isstring(name) then return end
    PRIVATE[self].ctx = name
end

function LoggerConfig:GetContext()
    return PRIVATE[self].ctx
end

function LoggerConfig:GetAppenderRef()
    return PRIVATE[self].appenderref
end

--- Adds an Appender to the LoggerConfig.
-- It adds the Appender name to the LoggerConfig's private `appenderref` table field,
-- then adds the Appender object to the Configuration's(the only one which owns this LoggerConfig) private `appender` table field.
-- @param appender Appender object
-- @return bool ifsuccessfullyadded
function LoggerConfig:AddAppender(appender)
    if not istable(appender) then return end
    tinsert(PRIVATE[self].appenderref, appender.name)

    return GetCtx(self:GetContext()):GetConfiguration():AddAppender(appender, self.name)
end

--- Returns all Appenders configured by this LoggerConfig in a form of table.
-- @return table appenders
function LoggerConfig:GetAppenders()
    local appenders = {}

    for _, v in pairs(PRIVATE[self].appenderref) do
        local appender = GetCtx(self:GetContext()):GetConfiguration():GetAppenders()[v]

        if appender then
            tinsert(appenders, appender)
        end
    end

    return appenders
end

--- Removes all Appenders configured by this LoggerConfig.
function LoggerConfig:ClearAppenders()
    local config = GetCtx(self:GetContext()):GetConfiguration()

    for _, v in pairs(PRIVATE[self].appenderref) do
        if config:GetAppenders()[v] then
            config:RemoveAppender(v)
        end
    end

    TEmpty(PRIVATE[self].appenderref)
end

local RootLoggerConfig = LoggerConfig:subclass("LoggerConfig.RootLogger")

function RootLoggerConfig:Initialize()
    LoggerConfig.Initialize(self, ROOT)
    self:SetLevel(GetLevel("INFO"))
end

--- Overrides `LoggerConfig:__tostring()`.
function RootLoggerConfig:__tostring()
    return "RootLoggerConfig: [name:" .. self.name .. "]"
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

local function GenerateParentNames(name)
    local nodes, ancestors = StripDotExtension(name, false), {}

    for k in ipairs(nodes) do
        local ancestor = {}

        for i = 1, k do
            tinsert(ancestor, nodes[i])
        end

        tinsert(ancestors, tconcat(ancestor, "."))
    end

    return ancestors, nodes
end

local function ValidateAncestors(name)
    local ancestors, nodes = GenerateParentNames(name)

    local function HasEveryLoggerConfig(tbl)
        for _, v in pairs(tbl) do
            if not HasLoggerConfig(v) then return false end
        end

        return true
    end

    if HasEveryLoggerConfig(ancestors) then return true, tconcat(nodes, ".") end

    return false
end

--- Factory method to create a LoggerConfig.
-- @param name The name for the Logger
-- @param config The Configuration
-- @param level The Logging Level
-- @return object loggerconfig
function Log4g.Core.Config.LoggerConfig.Create(name, config, level)
    if not istable(config) or name == ROOT then return end
    local loggerconfig = LoggerConfig(name)
    local ctxname = config:GetContext()
    loggerconfig:SetContext(ctxname)

    if sfind(name, "%.") then
        local valid, parent = ValidateAncestors(name)
        if not valid then return end

        if level and istable(level) then
            loggerconfig:SetLevel(level)
        else
            loggerconfig:SetLevel(GetLoggerConfig(parent):GetLevel())
        end

        loggerconfig:SetParent(parent)
    else
        if level and istable(level) then
            loggerconfig:SetLevel(level)
        else
            loggerconfig:SetLevel(config:GetRootLogger():GetLevel())
        end

        loggerconfig:SetParent(ROOT)
    end

    config:AddLogger(name, loggerconfig)

    return loggerconfig
end

function Log4g.Core.Config.LoggerConfig.GetRootLoggerConfigClass()
    return RootLoggerConfig
end

Log4g.Core.Config.LoggerConfig.HasLoggerConfig = HasLoggerConfig
Log4g.Core.Config.LoggerConfig.GenerateParentNames = GenerateParentNames