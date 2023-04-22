--- The anchor point for the Log4g logging system.
-- @script LogManager
Log4g.API.LogManager = Log4g.API.LogManager or {}
local GetAllContexts = Log4g.Core.LoggerContext.GetAll
local isstring = isstring
local next, pairs = next, pairs

function Log4g.API.LogManager.Exists()
    return false
end

local impl

local function setCurrentLoggingImpl(name)
    impl = name
end

function Log4g.getCurrentLoggingImpl()
    return impl
end

local core = "log4g-core"

if Log4g.HasPackage(core) then
    setCurrentLoggingImpl(core .. " " .. Log4g.GetPackageVer(core))

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
elseif ULx and ULib then
    local ulx, ulib = "ULx", "ULib"
    setCurrentLoggingImpl(ulx .. " " .. ULib.pluginVersionStr(ulx) .. " & " .. ulib .. " " .. ULib.pluginVersionStr(ulib))
end