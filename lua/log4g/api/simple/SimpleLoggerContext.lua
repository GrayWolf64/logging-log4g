--- A simple LoggerContext implementation.
-- @classmod SimpleLoggerContext
local Class = include("log4g/core/impl/MiddleClass.lua")
local SimpleLoggerContext = Class("SimpleLoggerContext")
--- This is where all the SimpleLoggerContexts are stored.
-- @local
-- @table INSTANCES
local INSTANCES = INSTANCES or {}

function SimpleLoggerContext:Initialize(name)
    self.name = name
    self.logger = {}
end

function SimpleLoggerContext:__tostring()
    return "SimpleLoggerContext: [name:" .. self.name .. "]"
end

--- Determines if the specified Logger exists.
-- @param The name of the Logger to check
-- @return bool haslogger
function SimpleLoggerContext:HasLogger(name)
    if self.logger[name] then return true end

    return false
end

function Log4g.API.Simple.SimpleLoggerContext.GetAll()
    return INSTANCES
end

--- Get the SimpleLoggerContext with the right name.
-- @param name string name
-- @return object SimpleLoggerContext
function Log4g.API.Simple.SimpleLoggerContext.Get(name)
    if not isstring(name) then return end
    if INSTANCES[name] then return INSTANCES[name] end
end

--- Register a SimpleLoggerContext.
-- @param name The name of the SimpleLoggerContext
-- @return object SimpleLoggerContext
function Log4g.API.Simple.SimpleLoggerContext.Register(name)
    if INSTANCES[name] then return INSTANCES[name] end
    INSTANCES[name] = SimpleLoggerContext(name)

    return INSTANCES[name]
end