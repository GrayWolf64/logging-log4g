--- The Logger.
-- @classmod Logger
Log4g.Logger = Log4g.Logger or {}
local Class = include("log4g/core/impl/MiddleClass.lua")
local Logger = Class("Logger")
local HasKey = Log4g.Util.HasKey

function Logger:Initialize(name, loggerconfig)
    self.name = name
    self.loggerconfig = loggerconfig
end

--- Delete the Logger.
function Logger:Delete()
    Log4g.Hierarchy[self.loggerconfig.loggercontext].logger[self.name] = nil
end

--- Get the Logger name.
-- @return string name
function Logger:GetName()
    return self.name
end

--- Get the Level associated with the Logger.
-- @return object level
function Logger:GetLevel()
    return self.loggerconfig.level
end

local function HasLogger(name)
    for _, v in pairs(Log4g.Hierarchy) do
        if HasKey(v.logger, name) then return true end
    end

    return false
end

--- Register a Logger.
-- If the Logger with the same name already exists, its loggerconfig will be overrode.
-- @param name The name of the Logger
-- @param loggerconfig The Loggerconfig
-- @return object logger
function Log4g.Logger.RegisterLogger(name, loggerconfig)
    if name == "" or table.IsEmpty(loggerconfig) then return end

    if not HasLogger(name) then
        local logger = Logger:New(name, loggerconfig)
        Log4g.Hierarchy[loggerconfig.loggercontext].logger[name] = logger

        return logger
    end
end