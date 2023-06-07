--- The LoggerContext, which is the anchor for the logging system.
-- Subclassing `LifeCycle`.
-- It maintains a list of all the loggers requested by users and a reference to the Configuration.
-- @classmod LoggerContext
-- @license Apache License 2.0
-- @copyright GrayWolf64
local LifeCycle = Log4g.Core.LifeCycle.getClass()
local checkClass = include("log4g/core/util/TypeUtil.lua").checkClass
local LoggerContext = LifeCycle:subclass"LoggerContext"
local GetDefaultConfiguration = Log4g.Core.Config.GetDefaultConfiguration
local getContextDict = Log4g.Core.getContextDict
local addToContextDict = Log4g.Core.addToContextDict
local pairs = pairs
local type = type

function LoggerContext:Initialize(name)
    LifeCycle.Initialize(self)
    self:SetPrivateField(0x0014, {})
    self:SetName(name)
end

--- Sets the Configuration source for the LoggerContext.
-- @param src String source
function LoggerContext:SetConfigurationSource(src)
    self:SetPrivateField(0x00A1, src)
end

--- Gets where this LoggerContext is declared.
-- @return table source
function LoggerContext:GetConfigurationSource()
    return self:GetPrivateField(0x00A1)
end

--- Gets a Logger from the Context.
-- @name The name of the Logger
function LoggerContext:GetLogger(name)
    return self:GetPrivateField(0x0014)[name]
end

--- Gets a table of the current loggers.
-- @return table loggers
function LoggerContext:GetLoggers()
    return self:GetPrivateField(0x0014)
end

function LoggerContext:AddLogger(name, logger)
    self:GetPrivateField(0x0014)[name] = logger
end

--- Returns the current Configuration of the LoggerContext.
-- @return object configuration
function LoggerContext:GetConfiguration()
    return self:GetPrivateField(0x0011)
end

--- Sets the Configuration to be used.
-- @param config Configuration
function LoggerContext:SetConfiguration(config)
    if not checkClass(config, "Configuration") then return end
    if self:GetConfiguration() == config then return end
    config:SetContext(self:GetName())
    self:SetPrivateField(0x0011, config)
end

function LoggerContext:__tostring()
    return "LoggerContext: [name:" .. self:GetName() .. "]"
end

--- Terminate the LoggerContext.
function LoggerContext:Terminate()
    local name = self:GetName()
    self:DestroyPrivateTable()
    getContextDict()[name] = nil
end

--- Determines if the specified Logger exists.
-- @param The name of the Logger to check
-- @return bool haslogger
function LoggerContext:HasLogger(name)
    if self:GetLogger(name) then return true end

    return false
end

local function GetAll()
    return getContextDict()
end

--- Get the LoggerContext with the right name.
-- @param name String name
-- @return object loggercontext
local function Get(name)
    return getContextDict()[name]
end

--- Register a LoggerContext.
-- @param name The name of the LoggerContext
-- @param withconfig Whether or not come with a DefaultConfiguration, leaving it nil will make it come with one
-- @return object loggercontext
local function Register(name, withconfig)
    if type(name) ~= "string" then return end
    local ctxdict = getContextDict()
    local ctx = ctxdict[name]
    if checkClass(ctx, "LoggerContext") then return ctx end
    ctx = LoggerContext(name)

    if withconfig or withconfig == nil then
        ctx:SetConfiguration(GetDefaultConfiguration())
    end

    addToContextDict(name, ctx)

    return ctx
end

--- Get the number of Loggers across all the LoggerContexts.
-- @return number count
local function GetLoggerCount()
    local num, tableCount = 0, table.Count

    for _, v in pairs(getContextDict()) do
        num = num + tableCount(v:GetLoggers())
    end

    return num
end

local function GetClass()
    return LoggerContext
end

Log4g.Core.LoggerContext = {
    getClass = GetClass,
    getLoggerCount = GetLoggerCount,
    register = Register,
    get = Get,
    getAll = GetAll
}