--- A simple LoggerContext implementation.
-- @classmod SimpleLoggerContext
Log4g.API.Simple.SimpleLoggerContext = Log4g.API.Simple.SimpleLoggerContext or {}
local LoggerContext = Log4g.Core.LoggerContext.GetClass()
local SimpleLoggerContext = LoggerContext:subclass("SimpleLoggerContext")
local INSTANCES = INSTANCES or {}

function SimpleLoggerContext:Initialize(name)
    SimpleLoggerContext.Initialize(self, name)
end

function SimpleLoggerContext:__tostring()
    return "SimpleLoggerContext: [name:" .. self.name .. "]"
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