--- The LoggerConfig.
-- Logger object that is created via configuration.
-- Subclassing `LifeCycle`.
-- @classmod LoggerConfig
-- @license Apache License 2.0
-- @copyright GrayWolf64
local _M = {}
local LifeCycle = include"log4g/core/LifeCycle.lua".GetClass()
local LoggerConfig = LifeCycle:subclass("LoggerConfig")
local LoggerContext = include"log4g/core/LoggerContext.lua"
local GetLevel = include"log4g/core/Level.lua".GetLevel
local TypeUtil = include"log4g/core/util/TypeUtil.lua"
local StringUtil = include"log4g/core/util/StringUtil.lua"
local pairs, isstring, next = pairs, isstring, next
local concat = table.concat
local IsAppender, IsLoggerConfig = TypeUtil.IsAppender, TypeUtil.IsLoggerConfig
local IsLoggerContext = TypeUtil.IsLoggerContext
local IsConfiguration, IsLevel = TypeUtil.IsConfiguration, TypeUtil.IsLevel
local QualifyName = StringUtil.QualifyName
local EnumerateAncestors = Log4g.Core.Object.EnumerateAncestors

cvars.AddChangeCallback(CreateConVar("log4g_rootLogger", "root", FCVAR_NOTIFY):GetName(), function(cvarn)
    if not QualifyName(newn, false) or next(LoggerContext.GetAll()) then
        GetConVar(cvarn):Revert()
    end
end)

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
    if self:GetPrivateField("level") == level then return end
    self:SetPrivateField("level", level)
end

function LoggerConfig:GetLevel()
    return self:GetPrivateField("level")
end

local function HasLoggerConfig(name, context)
    local getlc = function(ctx, lcn) return ctx:GetConfiguration():GetLoggerConfig(lcn) end

    if not context or not IsLoggerContext(context) then
        for _, v in pairs(LoggerContext.GetAll()) do
            if getlc(v, name) then return true end
        end
    else
        if getlc(context, name) then return true end
    end

    return false
end

local function GetLoggerConfig(name)
    for _, v in pairs(LoggerContext.GetAll()) do
        local lc = v:GetConfiguration():GetLoggerConfig(name)
        if lc then return lc end
    end
end

--- Sets the parent of this LoggerConfig.
-- @param T LoggerConfig object or LoggerConfig name
function LoggerConfig:SetParent(T)
    if isstring(T) then
        if not HasLoggerConfig(T, LoggerContext.Get(self:GetContext())) then return end
        self:SetPrivateField("parent", T)
    elseif IsLoggerConfig(T) and T:GetContext() == self:GetContext() then
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

    return LoggerContext.Get(self:GetContext()):GetConfiguration():AddAppender(ap, self:GetName())
end

--- Returns all Appenders configured by this LoggerConfig in a form of table (keys are Appenders, values are booleans).
-- @return table appenders
function LoggerConfig:GetAppenders()
    local appenders, config, apref = {}, LoggerContext.Get(self:GetContext()):GetConfiguration(), self:GetAppenderRef()
    if not next(apref) then return end

    for k in pairs(apref) do
        appenders[config:GetAppenders()[k]] = true
    end

    return appenders
end

--- Removes all Appenders configured by this LoggerConfig.
function LoggerConfig:ClearAppenders()
    local config, apref = LoggerContext.Get(self:GetContext()):GetConfiguration(), self:GetAppenderRef()
    if not next(apref) then return end

    for k in pairs(apref) do
        config:RemoveAppender(k)
        self:GetAppenderRef()[k] = nil
    end
end

local RootLoggerConfig = LoggerConfig:subclass("LoggerConfig.RootLogger")

function RootLoggerConfig:Initialize()
    LoggerConfig.Initialize(self, GetConVar("log4g_rootLogger"):GetString())
    self:SetLevel(GetLevel("INFO"))
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

function _M.GetRootLoggerConfigClass()
    return RootLoggerConfig
end

--- Check if a LoggerConfig's ancestors exist and return its desired parent name.
-- @lfunction ValidateAncestors
-- @param lc LoggerConfig object
-- @return bool valid
-- @return string parent name
local function ValidateAncestors(lc)
    local ancestors, nodes = EnumerateAncestors(lc:GetName())

    local function HasEveryLoggerConfig(tbl)
        local ctx = LoggerContext.Get(lc:GetContext())

        for k in pairs(tbl) do
            if not HasLoggerConfig(k, ctx) then return false end
        end

        return true
    end

    if HasEveryLoggerConfig(ancestors) then return true, concat(nodes, ".") end

    return false
end

--- Factory method to create a LoggerConfig.
-- @param name The name for the Logger
-- @param config The Configuration
-- @param level The Logging Level
-- @return object loggerconfig
function _M.Create(name, config, level)
    local root = GetConVar("log4g_rootLogger"):GetString()
    if not IsConfiguration(config) or name == root then return end
    local lc = LoggerConfig(name)
    lc:SetContext(config:GetContext())

    local setlvp = function(o, l1, l2, p)
        if l1 and IsLevel(l1) then
            o:SetLevel(l1)
        else
            o:SetLevel(l2)
        end

        o:SetParent(p)
    end

    if name:find("%.") then
        local valid, parent = ValidateAncestors(lc)
        if not valid then return end
        setlvp(lc, level, GetLoggerConfig(parent):GetLevel(), parent)
    else
        setlvp(lc, level, config:GetRootLogger():GetLevel(), root)
    end

    config:AddLogger(name, lc)

    return lc
end

_M.HasLoggerConfig = HasLoggerConfig

return _M