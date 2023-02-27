--- The LoggerConfig.
-- @classmod LoggerConfig
Log4g.Core.Config.LoggerConfig = Log4g.Core.Config.LoggerConfig or {}
local Class = include("log4g/core/impl/MiddleClass.lua")
local LoggerConfig = Class("LoggerConfig")

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
    PRIVATE[self] = {}
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
    else
        PRIVATE[self].parent = T.name
    end
end

function LoggerConfig:GetParent()
    return PRIVATE[self].parent
end

--- Factory method to create a LoggerConfig.
-- @param loggername The name for the Logger
-- @param config The Configuration
-- @param level The Logging Level
-- @return object loggerconfig
function Log4g.Core.Config.LoggerConfig.Create(loggername, config, level)
    local char = string.ToTable(loggername)
    local loggerconfig

    if table.HasValue(char, ".") then
        if char[1] == "." or char[#char] == "." then return end
        table.remove(char, #char)
        table.remove(char, #char)

        for k, v in pairs(char) do
            if v == "." then
                table.remove(char, k)
            end
        end

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
        loggerconfig = LoggerConfig(loggername)
        loggerconfig:SetLevel(level)
        loggerconfig:SetParent(table.concat(char, "."))
        config:AddLogger(loggername, loggerconfig)
    else
        loggerconfig = LoggerConfig(loggername)
        loggerconfig:SetLevel(level)
        config:AddLogger(loggername, loggerconfig)
    end

    return loggerconfig
end