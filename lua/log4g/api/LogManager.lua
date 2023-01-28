--- The anchor point for the Log4g logging system.
-- @script LogManager
Log4g.API.LogManager = Log4g.API.LogManager or {}
local HasKey = Log4g.Util.HasKey
local GetAllLoggerContexts = Log4g.API.LoggerContextFactory.GetContextAll

--- Detects if a Logger with the specified name exists.
-- @param name The name of the Logger
-- @return bool haslogger
function Log4g.API.LogManager.Exists(name)
    local LoggerContexts = GetAllLoggerContexts()

    for _, v in pairs(LoggerContexts) do
        if HasKey(v.logger, name) then return true end
    end

    return false
end

function Log4g.API.LogManager.GetLogger(name)
end