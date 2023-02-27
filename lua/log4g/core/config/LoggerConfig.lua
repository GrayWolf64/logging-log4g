--- The LoggerConfig.
-- Subclassing `LifeCycle`.
-- @classmod LoggerConfig
-- @license Apache License 2.0
-- @copyright GrayWolf64
Log4g.Core.Config.LoggerConfig = Log4g.Core.Config.LoggerConfig or {}
local LifeCycle = Log4g.Core.LifeCycle.Class()
local LoggerConfig = LifeCycle:subclass("LoggerConfig")

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

local GetAllCtx = Log4g.Core.LoggerContext.GetAll

--- Check if a LoggerConfig exists.
-- @lfunction HasLoggerConfig
-- @param name The name of the LoggerConfig to check
-- @return bool ifhaslc
local function HasLoggerConfig(name)
    for _, v in pairs(GetAllCtx()) do
        for _, j in pairs(v:GetLoggers()) do
            if j:GetLoggerConfig().name == name then return true end
        end
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

--- Sets the Configuration name for the LoggerConfig.
-- @param config Configuration object
function LoggerConfig:SetConfig(config)
    if not istable(config) then return end
    PRIVATE[self].config = config.name
end

--- Gets the Configuration name of the LoggerConfig.
-- @return string cname
function LoggerConfig:GetConfig()
    return PRIVATE[self].config
end

--- Adds an Appender to the LoggerConfig.
-- It adds the Appender name to the LoggerConfig's private `appenderref` table field,
-- then adds the Appender object to the Configuration's(the only one which owns this LoggerConfig) private `appender` table field.
-- @param appender Appender object
-- @return bool ifsuccessfullyadded
function LoggerConfig:AddAppender(appender)
    if not istable(appender) then return end
    table.insert(PRIVATE[self].appenderref, appender.name)

    for _, v in pairs(GetAllCtx()) do
        local config = v:GetConfiguration()
        if config.name == self:GetConfig() then return config:AddAppender(appender) end
    end

    return false
end

--- Factory method to create a LoggerConfig.
-- @param name The name for the Logger
-- @param config The Configuration
-- @param level The Logging Level
-- @return object loggerconfig
function Log4g.Core.Config.LoggerConfig.Create(name, config, level)
    if not isstring(name) or not istable(config) or not istable(level) then return end
    local char = string.ToTable(name)
    local loggerconfig

    if string.find(name, "%.") then
        if string.sub(name, 1, 1) == "." or string.sub(name, #name, #name) == "." then return end
        char = string.ToTable(string.sub(name, 1, #name - 2):gsub("%.", ""))
        local tocheck = {}

        for k, _ in ipairs(char) do
            local tocheck2 = {}

            for i = 1, k do
                table.insert(tocheck2, char[i])
            end

            table.insert(tocheck, table.concat(tocheck2, "."))
        end

        --- Check if all the LoggerConfigs with the provided names exists.
        -- @lfunction HasEveryLCMentioned
        -- @param tbl The table containing all the LoggerConfigs' names to check
        -- @return bool ifhaseverylc
        local function HasEveryLCMentioned(tbl)
            for _, v in pairs(tbl) do
                if not HasLoggerConfig(v) then return false end
            end

            return true
        end

        if not HasEveryLCMentioned(tocheck) then return end
        loggerconfig = LoggerConfig(name)
        loggerconfig:SetLevel(level)
        loggerconfig:SetParent(table.concat(char, "."))
        loggerconfig:SetConfig(config)
        config:AddLogger(name, loggerconfig)
    else
        loggerconfig = LoggerConfig(name)
        loggerconfig:SetLevel(level)
        loggerconfig:SetConfig(config)
        config:AddLogger(name, loggerconfig)
    end

    return loggerconfig
end