--- The anchor point for the Log4g logging system.
-- @script LogManager
Log4g.API.LogManager = Log4g.API.LogManager or {}
local GetAllContexts = Log4g.GetPkgClsFuncs("log4g-core", "LoggerContext").getAll
local next, pairs = next, pairs

function Log4g.API.LogManager.Exists()
    return false
end

local impl = impl or ""

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
        if type(name) ~= "string" or not next(ctxs) then return end

        for _, v in pairs(ctxs) do
            if v:HasLogger(name) then return true end
        end

        return false
    end
elseif ULx and ULib then
    local ulx, ulib = "ULx", "ULib"
    setCurrentLoggingImpl(ulx .. " " .. ULib.pluginVersionStr(ulx) .. " & " .. ulib .. " " .. ULib.pluginVersionStr(ulib))
end