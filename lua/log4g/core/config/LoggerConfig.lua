--- The LoggerConfig.
-- Subclassing `LifeCycle`.
-- @classmod LoggerConfig
-- @license Apache License 2.0
-- @copyright GrayWolf64
Log4g.Core.Config.LoggerConfig = Log4g.Core.Config.LoggerConfig or {}
local Accessor = Log4g.Core.Config.LoggerConfig
Accessor.ROOT = "root"
local LifeCycle = Log4g.Core.LifeCycle.Class()
local LoggerConfig = LifeCycle:subclass("LoggerConfig")
local GetCtx, GetAllCtx = Log4g.Core.LoggerContext.Get, Log4g.Core.LoggerContext.GetAll
local pairs, ipairs = pairs, ipairs
local STRL, STRR, STREXPL, STRF, STRS = string.Left, string.Right, string.Explode, string.find, string.sub
local TBLINS, TBLCON = table.insert, table.concat

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
    if self.name == Accessor.ROOT then return end

    if isstring(T) then
        if T == Accessor.ROOT then
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
    if self.name == Accessor.ROOT then return end

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
    TBLINS(PRIVATE[self].appenderref, appender.name)

    return GetCtx(self:GetContext()):GetConfiguration():AddAppender(appender, self.name)
end

--- Returns all Appenders configured by this LoggerConfig in a form of table.
-- @return table appenders
function LoggerConfig:GetAppenders()
    local appenders = {}

    for _, v in pairs(PRIVATE[self].appenderref) do
        local appender = GetCtx(self:GetContext()):GetConfiguration():GetAppenders()[v]

        if appender then
            TBLINS(appenders, appender)
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

    table.Empty(PRIVATE[self].appenderref)
end

local RootLoggerConfig = LoggerConfig(Accessor.ROOT)
RootLoggerConfig:SetLevel(Log4g.Level.GetLevel("INFO"))

function Accessor.GetRootLoggerConfig()
    return RootLoggerConfig
end

local function ValidateAncestors(name)
    local nodes, ancestors = STREXPL(".", STRS(name, 1, #name - STRF(string.reverse(name), "%."))), {}

    for k, _ in ipairs(nodes) do
        local ancestor = {}

        for i = 1, k do
            TBLINS(ancestor, nodes[i])
        end

        TBLINS(ancestors, TBLCON(ancestor, "."))
    end

    local function HasEveryLoggerConfig(tbl)
        for _, v in pairs(tbl) do
            if not HasLoggerConfig(v) then return false end
        end

        return true
    end

    if HasEveryLoggerConfig(ancestors) then return true, TBLCON(nodes, ".") end

    return false
end

--- Factory method to create a LoggerConfig.
-- @param name The name for the Logger
-- @param config The Configuration
-- @param level The Logging Level
-- @return object loggerconfig
function Accessor.Create(name, config, level)
    if not isstring(name) or not istable(config) or name == Accessor.ROOT then return end
    local loggerconfig = LoggerConfig(name)
    loggerconfig:SetContext(config:GetContext())

    if STRF(name, "%.") then
        if STRL(name, 1) == "." or STRR(name, 1) == "." then return end
        local valid, parent = ValidateAncestors(name)
        if not valid then return end

        if level and istable(level) then
            loggerconfig:SetLevel(level)
        else
            loggerconfig:SetLevel(GetLoggerConfig(parent):GetLevel())
        end

        loggerconfig:SetParent(parent)
    else
        loggerconfig:SetLevel(RootLoggerConfig:GetLevel())
        loggerconfig:SetParent(Accessor.ROOT)
    end

    config:AddLogger(name, loggerconfig)

    return loggerconfig
end