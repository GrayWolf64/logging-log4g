--- The anchor point for the Log4g logging system.
-- @script LogManager
Log4g.API.LogManager = Log4g.API.LogManager or {}
local HasKey = Log4g.Util.HasKey
local GetAllLoggers = Log4g.Core.Logger.GetAll

--- Detects if a Logger with the specified name exists.
-- @param name The name of the Logger
-- @return bool haslogger
function Log4g.API.LogManager.Exists(name)
    if HasKey(GetAllLoggers(), name) then return true end

    return false
end