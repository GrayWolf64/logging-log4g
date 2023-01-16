--- Version handler.
-- @script Version.lua
Log4g._Version = Log4g._Version or {}
concommand.Add("Log4g_Version", function()
    MsgC("Log4g Version Check\n")
end)