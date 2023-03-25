--- Version handler.
-- @script Version
concommand.Add("Log4g_Version", function()
    http.Fetch("https://raw.githubusercontent.com/GrayWolf64/gmod-logging-log4g/main/VERSION.txt", function(body)
        print(body)
    end, function(msg)
        print(msg)
    end)
end)