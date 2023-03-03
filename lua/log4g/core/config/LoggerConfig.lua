--- The LoggerConfig.
-- Subclassing `LifeCycle`.
-- @classmod LoggerConfig
-- @license Apache License 2.0
-- @copyright GrayWolf64
Log4g.Core.Config.LoggerConfig = Log4g.Core.Config.LoggerConfig or {}
local LifeCycle = Log4g.Core.LifeCycle.Class()
local LoggerConfig = LifeCycle:subclass("LoggerConfig")
local GetAllCtx = Log4g.Core.LoggerContext.GetAll
local GetCtx = Log4g.Core.LoggerContext.Get
local ipairs = ipairs
local stringLeft = string.Left
local stringRight = string.Right
local stringExplode = string.Explode
local stringFind = string.find
local stringSub = string.sub
local tableInsert = table.insert

--- A weak table which stores some private attributes of the LoggerConfig object.
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

--- Check if a LoggerConfig exists.
-- @lfunction HasLoggerConfig
-- @param name The name of the LoggerConfig to check
-- @return bool ifhaslc
local function HasLoggerConfig(name)
    for _, v in pairs(GetAllCtx()) do
        if v:GetConfiguration():GetLoggerConfig(name) then return true end
    end

    return false
end

--- Sets the parent of this LoggerConfig.
-- @param T LoggerConfig object or LoggerConfig name
function LoggerConfig:SetParent(T)
    if isstring(T) then
        if not HasLoggerConfig(T) then return end
        PRIVATE[self].parent = T
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
    tableInsert(PRIVATE[self].appenderref, appender.name)
    appender:SetLocn(self.name)

    return GetCtx(self:GetContext()):GetConfiguration():AddAppender(appender, self.name)
end

--- Returns all Appenders configured by this LoggerConfig in a form of table.
-- @return table appenders
function LoggerConfig:GetAppenders()
    local appenders = {}

    for _, v in pairs(GetCtx(self:GetContext()):GetConfiguration():GetAppenders()) do
        if v:GetLocn() == self.name then
            tableInsert(appenders, v)
        end
    end

    return appenders
end

--- Removes all Appenders configured by this LoggerConfig.
function LoggerConfig:ClearAppenders()
    local config = GetCtx(self:GetContext()):GetConfiguration()
    table.Empty(PRIVATE[self].appenderref)

    for k, v in pairs(config:GetAppenders()) do
        if v:GetLocn() == self.name then
            config:RemoveAppender(k)
        end
    end
end

--- Factory method to create a LoggerConfig.
-- @param name The name for the Logger
-- @param config The Configuration
-- @param level The Logging Level
-- @return object loggerconfig
function Log4g.Core.Config.LoggerConfig.Create(name, config, level)
    if not isstring(name) or not istable(config) or not istable(level) then return end
    local loggerconfig = LoggerConfig(name)
    loggerconfig:SetLevel(level)
    loggerconfig:SetContext(config:GetContext())

    if stringFind(name, "%.") then
        if stringLeft(name, 1) == "." or stringRight(name, 1) == "." then return end
        local charset, tocheck = stringExplode(".", stringSub(name, 1, #name - stringFind(string.reverse(name), "%."))), {}

        for k, _ in ipairs(charset) do
            local tocheck2 = {}

            for i = 1, k do
                tableInsert(tocheck2, charset[i])
            end

            tableInsert(tocheck, table.concat(tocheck2, "."))
        end

        local function HasEveryLCMentioned(tbl)
            for _, v in pairs(tbl) do
                if not HasLoggerConfig(v) then return false end
            end

            return true
        end

        if not HasEveryLCMentioned(tocheck) then return end
        loggerconfig:SetParent(table.concat(charset, "."))
    end

    config:AddLogger(name, loggerconfig)

    return loggerconfig
end