--- The LoggerContext, which is the anchor for the logging system.
-- Subclassing `LifeCycle`.
-- It maintains a list of all the loggers requested by users and a reference to the Configuration.
-- @classmod LoggerContext
-- @license Apache License 2.0
-- @copyright GrayWolf64
local LifeCycle               = Log4g.Core.LifeCycle.getClass()
local checkClass              = include"util/TypeUtil.lua".checkClass
local LoggerContext           = LoggerContext or LifeCycle:subclass"LoggerContext"
local GetDefaultConfiguration = Log4g.Core.Config.GetDefaultConfiguration
local getLContextRepo         = Log4g.Core.Repository.getLContextRepo
LoggerContext:include(Log4g.Core.Object.namedMixins)

function LoggerContext:Initialize(name)
    LifeCycle.Initialize(self)
    self.__loggerRepo = {}
    self:SetName(name)
end

--- Sets the Configuration source for the LoggerContext.
-- @param src String source
function LoggerContext:SetConfigurationSource(src)
    self.__configSrc = src
end

--- Gets where this LoggerContext is declared.
-- @return table source
function LoggerContext:GetConfigurationSource()
    return self.__configSrc
end

--- Gets a Logger from the Context.
-- @param name The name of the Logger
function LoggerContext:GetLogger(name)
    return self.__loggerRepo[name]
end

--- Gets a table of the current loggers.
-- @return table loggers
function LoggerContext:GetLoggers()
    return self.__loggerRepo
end

function LoggerContext:AddLogger(name, logger)
    self.__loggerRepo[name] = logger
end

--- Returns the current Configuration of the LoggerContext.
-- @return object configuration
function LoggerContext:GetConfiguration()
    return self.__config
end

--- Sets the Configuration to be used.
-- @param config Configuration
function LoggerContext:SetConfiguration(config)
    assert(checkClass(config, "Configuration"), "config must be Log4g Configuration object")

    if self:GetConfiguration() == config then return end
    config:SetContext(self:GetName())
    self.__config = config
end

function LoggerContext:__tostring()
    return "LoggerContext: [name:" .. self:GetName() .. "]"
end

--- Terminate the LoggerContext.
function LoggerContext:Terminate()
    self:SetStopped()
    getLContextRepo():Access()[self:GetName()] = nil
end

--- Determines if the specified Logger exists.
-- @param name The name of the Logger to check
-- @return bool haslogger
function LoggerContext:HasLogger(name)
    if self:GetLogger(name) then return true end

    return false
end

--- Register a LoggerContext.
-- @param name The name of the LoggerContext
-- @param withconfig Whether or not come with a DefaultConfiguration, leaving it nil will make it come with one
-- @return object loggercontext
local function registerLContext(name, withconfig)
    assert(type(name) == "string", "name must be string for a LContext")

    local ctxdict = getLContextRepo():Access()
    local ctx = ctxdict[name]
    if checkClass(ctx, "LoggerContext") then return ctx end
    ctx = LoggerContext(name)

    if withconfig or withconfig == nil then
        ctx:SetConfiguration(GetDefaultConfiguration())
    end

    getLContextRepo():InsertKVPair(name, ctx)

    return ctx
end

--- Get the number of Loggers across all the LoggerContexts.
-- @return number count
local function getLoggerCount()
    local num = 0

    local function count(tab)
        local n = 0 for _ in pairs(tab) do n = n + 1 end return n
    end

    for _, v in pairs(getLContextRepo():Access()) do
        num = num + count(v:GetLoggers())
    end

    return num
end

Log4g.Core.LoggerContext = {
    getClass = function() return LoggerContext end,
    getAll = function() return getLContextRepo():Access() end,
    get = function(name) return getLContextRepo():Access()[name] end,
    getLoggerCount = getLoggerCount,
    register = registerLContext
}