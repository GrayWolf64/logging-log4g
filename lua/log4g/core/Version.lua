--- Version handler.
-- @script Version
Log4g._VERSION = Log4g._VERSION or {}

concommand.Add("Log4g_Version", function()
    http.Fetch("https://raw.githubusercontent.com/GrayWolf64/gmod-logging-log4g/main/VERSION.txt", function(body)
        print(body)
    end, function(msg)
        print(msg)
    end)
end)