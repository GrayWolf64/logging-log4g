--- Version handler.
-- @script Version
Log4g._VERSION = Log4g._VERSION or {}

concommand.Add("Log4g_Version", function()
    print("Version Checked.")
end)