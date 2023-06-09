--- The anchor point for the Log4g logging system.
-- @script LogManager
Log4g.API.LogManager = Log4g.API.LogManager or {}
local GetAllContexts = Log4g.Core.LoggerContext.getAll
local next, pairs = next, pairs

--- Detects if a Logger with the specified name exists.
-- @param name The name of the Logger
-- @return bool haslogger
function Log4g.API.LogManager.Exists(name)
    local ctxs = GetAllContexts()
    if type(name) ~= "string" or not next(ctxs) then return end

    for _, v in pairs(ctxs) do
        if v:HasLogger(name) then return true end
    end

    return false
end