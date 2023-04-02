--- The LoggerConfig.
-- Logger object that is created via configuration.
-- Subclassing `LifeCycle`.
-- @classmod LoggerConfig
-- @license Apache License 2.0
-- @copyright GrayWolf64
Log4g.Core.Config.LoggerConfig = Log4g.Core.Config.LoggerConfig or {}
local LifeCycle = Log4g.Core.LifeCycle.GetClass()
local LoggerConfig = LifeCycle:subclass("LoggerConfig")
local GetCtx, GetAllCtx = Log4g.Core.LoggerContext.Get, Log4g.Core.LoggerContext.GetAll
local GetLevel = Log4g.Level.GetLevel
local next = next
local pairs, ipairs = pairs, ipairs
local string_find, isstring = string.find, isstring
local table_insert, table_concat = table.insert, table.concat
local TypeUtil = include("log4g/core/util/TypeUtil.lua")
local IsAppender, IsLoggerConfig = TypeUtil.IsAppender, TypeUtil.IsLoggerConfig
local IsConfiguration, IsLevel = TypeUtil.IsConfiguration, TypeUtil.IsLevel
TypeUtil = nil
local StripDotExtension = include("log4g/core/util/StringUtil.lua").StripDotExtension
CreateConVar("log4g.root", "root", FCVAR_NOTIFY)

function LoggerConfig:Initialize(name)
    LifeCycle.Initialize(self)
    self:SetPrivateField("apref", {})
    self:SetName(name)
end

function LoggerConfig:IsLoggerConfig()
    return true
end

function LoggerConfig:__tostring()
    return "LoggerConfig: [name:" .. self:GetName() .. "]"
end

--- Sets the log Level.
-- @param level The Logging Level
function LoggerConfig:SetLevel(level)
    if not IsLevel(level) then return end
    if self:GetPrivateField("level") == level then return end
    self:SetPrivateField("level", level)
end

function LoggerConfig:GetLevel()
    return self:GetPrivateField("level")
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
        if T == GetConVar("log4g.root"):GetString() then
            self:SetPrivateField("parent", T)
        else
            if not HasLoggerConfig(T) then return end
            self:SetPrivateField("parent", T)
        end
    elseif IsLoggerConfig(T) then
        self:SetPrivateField("parent", T:GetName())
    end
end

--- Gets the parent of this LoggerConfig.
-- @return string lcname
function LoggerConfig:GetParent()
    return self:GetPrivateField("parent")
end

--- Sets the Context name for the LoggerConfig.
-- @param ctx LoggerContext object
function LoggerConfig:SetContext(name)
    if not isstring(name) then return end
    self:SetPrivateField("ctx", name)
end

function LoggerConfig:GetContext()
    return self:GetPrivateField("ctx")
end

function LoggerConfig:GetAppenderRef()
    return self:GetPrivateField("apref")
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

local RootLoggerConfig = LoggerConfig:subclass("LoggerConfig.RootLogger")

function RootLoggerConfig:Initialize(name)
    LoggerConfig.Initialize(self, name)
    self:SetLevel(GetLevel("INFO"))
end

--- Overrides `LoggerConfig:__tostring()`.
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

local function GenerateAncestorsN(name)
    local nodes, ancestors = StripDotExtension(name, false), {}

    for k in ipairs(nodes) do
        local ancestor = {}

        for i = 1, k do
            table_insert(ancestor, nodes[i])
        end

        ancestors[table_concat(ancestor, ".")] = true
    end

    return ancestors, nodes
end

local function ValidateAncestors(name)
    local ancestors, nodes = GenerateAncestorsN(name)

    local function HasEveryLoggerConfig(tbl)
        for k in pairs(tbl) do
            if not HasLoggerConfig(k) then return false end
        end

        return true
    end

    if HasEveryLoggerConfig(ancestors) then return true, table_concat(nodes, ".") end

    return false
end

--- Factory method to create a LoggerConfig.
-- @param name The name for the Logger
-- @param config The Configuration
-- @param level The Logging Level
-- @return object loggerconfig
function Log4g.Core.Config.LoggerConfig.Create(name, config, level)
    local Root = GetConVar("log4g.root"):GetString()
    if not IsConfiguration(config) or name == Root then return end
    local lc = LoggerConfig(name)
    lc:SetContext(config:GetContext())

    if string_find(name, "%.") then
        local valid, parent = ValidateAncestors(name)
        if not valid then return end

        if level and IsLevel(level) then
            lc:SetLevel(level)
        else
            lc:SetLevel(GetLoggerConfig(parent):GetLevel())
        end

        lc:SetParent(parent)
    else
        if level and IsLevel(level) then
            lc:SetLevel(level)
        else
            lc:SetLevel(config:GetRootLogger():GetLevel())
        end

        lc:SetParent(Root)
    end

    config:AddLogger(name, lc)

    return lc
end

function Log4g.Core.Config.LoggerConfig.GetRootLoggerConfigClass()
    return RootLoggerConfig
end

Log4g.Core.Config.LoggerConfig.HasLoggerConfig = HasLoggerConfig
Log4g.Core.Config.LoggerConfig.GenerateAncestorsN = GenerateAncestorsN