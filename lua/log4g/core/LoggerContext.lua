--- The LoggerContext, which is the anchor for the logging system.
-- Subclassing `LifeCycle`.
-- It maintains a list of all the loggers requested by users and a reference to the Configuration.
-- @classmod LoggerContext
-- @license Apache License 2.0
-- @copyright GrayWolf64
local LifeCycle = Log4g.GetPkgClsFuncs("log4g-core", "LifeCycle").getClass()
local LoggerContext = LifeCycle:subclass("LoggerContext")
local GetDefaultConfiguration = Log4g.Core.Config.GetDefaultConfiguration
local isstring = isstring
local pairs = pairs
local TypeUtil = include("log4g/core/util/TypeUtil.lua")
local IsLoggerContext, IsConfiguration = TypeUtil.IsLoggerContext, TypeUtil.IsConfiguration
TypeUtil = nil
--- A dictionary for storing LoggerContext objects.
-- Only one ContextDictionary exists in the logging system.
-- @local
-- @table ContextDict
local ContextDict = ContextDict or {}

function LoggerContext:Initialize(name)
    LifeCycle.Initialize(self)
    self:SetPrivateField("logger", {})
    self:SetName(name)
end

function LoggerContext:SetConfigurationSource(src)
    self:SetPrivateField("source", src)
end

--- Gets where this LoggerContext is declared.
-- @return table source
function LoggerContext:GetConfigurationSource()
    return self:GetPrivateField("source")
end

--- Gets a Logger from the Context.
-- @name The name of the Logger
function LoggerContext:GetLogger(name)
    if not isstring(name) then return end

    return self:GetPrivateField("logger")[name]
end

--- Gets a table of the current loggers.
-- @return table loggers
function LoggerContext:GetLoggers()
    return self:GetPrivateField("logger")
end

--- Returns the current Configuration of the LoggerContext.
-- @return object configuration
function LoggerContext:GetConfiguration()
    return self:GetPrivateField("config")
end

--- Sets the Configuration to be used.
-- @param config Configuration
function LoggerContext:SetConfiguration(config)
    if not IsConfiguration(config) then return end
    if self:GetConfiguration() == config then return end
    config:SetContext(self:GetName())
    self:SetPrivateField("config", config)
end

function LoggerContext:__tostring()
    return "LoggerContext: [name:" .. self:GetName() .. "]"
end

--- Terminate the LoggerContext.
function LoggerContext:Terminate()
    local name = self:GetName()
    self:DestroyPrivateTable()
    ContextDict[name] = nil
end

--- Determines if the specified Logger exists.
-- @param The name of the Logger to check
-- @return bool haslogger
function LoggerContext:HasLogger(name)
    if self:GetLogger(name) then return true end

    return false
end

local function GetAll()
    return ContextDict
end

--- Get the LoggerContext with the right name.
-- @param name String name
-- @return object loggercontext
local function Get(name)
    if not isstring(name) then return end

    return ContextDict[name]
end

--- Register a LoggerContext.
-- @param name The name of the LoggerContext
-- @param withconfig Whether or not come with a DefaultConfiguration, leaving it nil will make it come with one
-- @return object loggercontext
local function Register(name, withconfig)
    local ctx = ContextDict[name]
    if ctx and IsLoggerContext(ctx) then return ctx end
    ctx = LoggerContext(name)

    if withconfig or withconfig == nil then
        ctx:SetConfiguration(GetDefaultConfiguration())
    end

    ContextDict[name] = ctx

    return ctx
end

local function GetLoggerCount()
    local num, tableCount = 0, table.Count

    for _, v in pairs(ContextDict) do
        num = num + tableCount(v:GetLoggers())
    end

    return num
end

local function GetClass()
    return LoggerContext
end

Log4g.RegisterPackageClass("log4g-core", "LoggerContext", {
    getClass = GetClass,
    getLoggerCount = GetLoggerCount,
    register = Register,
    get = Get,
    getAll = GetAll
})