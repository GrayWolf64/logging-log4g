--- The anchor point for the Log4g logging system.
-- @script LogManager
Log4g.API.LogManager = Log4g.API.LogManager or {}
local GetAllContexts = Log4g.Core.LoggerContext.GetAll
local GetContext = Log4g.API.LoggerContextFactory.GetContext
local GetSimpleContext = Log4g.API.SimpleLoggerContextFactory.GetContext
local isstring, next, pcall = isstring, next, pcall

--- Detects if a Logger with the specified name exists.
-- @param name The name of the Logger
-- @return bool haslogger
function Log4g.API.LogManager.Exists(name)
    local ctxs = GetAllContexts()
    if not isstring(name) or not next(ctxs) then return end

    for _, v in pairs(ctxs) do
        if v:HasLogger(name) then return true end
    end

    return false
end

function Log4g.API.LogManager.GetContext(name)
    if not isstring(name) then return end
    if not pcall(function() return GetContext(name, true) end) then return GetSimpleContext(name) end
end