--- Version handler.
-- @script Version.lua
Log4g._Version = Log4g._Version or {}
Log4g._Version.LastCommit = "3a53f34448fb4afa1425c04f3dad1de78fb0bb8b"

concommand.Add("Log4g_Version", function()
    MsgC("Log4g Version (Last Commit): " .. Log4g._Version.LastCommit .. "\n")
end)